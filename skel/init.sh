#!/bin/bash

source /opt/scripts/container_functions.lib.sh

init_vars() {
    
  if [[ $ENVIRONMENT_INIT && -f $ENVIRONMENT_INIT ]]; then
      source "$ENVIRONMENT_INIT"
  fi

  if [[ ! $PARENT_HOST && $HOST ]]; then
    export PARENT_HOST="$HOST"
  fi

  export APP_NAME=${APP_NAME:-consul}
  export ENVIRONMENT=${ENVIRONMENT:-local} 
  export PARENT_HOST=${PARENT_HOST:-unknown}

  export SERVICE_LOGROTATE_CONF=${SERVICE_LOGROTATE_CONF:-/etc/logrotate.conf}
  export SERVICE_LOGSTASH_FORWARDER_CONF=${SERVICE_LOGSTASH_FORWARDER_CONF:-/opt/logstash-forwarder/consul.conf}
  export SERVICE_REDPILL_MONITOR=${SERVICE_REDPILL_MONITOR:-"consul"}
  export SERVICE_RSYSLOG=${SERVICE_RSYSLOG:-enabled}


  case "${ENVIRONMENT,,}" in
    prod|production|dev|development)
      export SERVICE_LOGROTATE=${SERVICE_LOGROTATE:-enabled}
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-enabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-enabled}
    ;;
    debug)
      export SERVICE_LOGROTATE=${SERVICE_LOGROTATE:-disabled}
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-disabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-disabled}
      export CONSUL_LOG_LEVEL=${CONSUL_LOG_LEVEL:-debug}
    ;;
    local|*)
      export SERVICE_LOGROTATE=${SERVICE_LOGROTATE:-enabled}
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-disabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-enabled}
    ;;
  esac
}

config_consul() {
  local var_name=""
  local cmd_flags=()
  local consul_cmd=""

  export CONSUL_CONFIG_DIR=${CONSUL_CONFIG_DIR:-/etc/consul/conf.d}
  export CONSUL_DATA_DIR=${CONSUL_DATA_DIR:-/var/consul/data}
  export CONSUL_SYSLOG=${CONSUL_SYSLOG:-true}
  export CONSUL_UI_DIR=${CONSUL_UI_DIR:-/var/consul/web}

  for i in $(compgen -A variable | awk '/^CONSUL_/ && !/^CONSUL_TEMPLATE/'); do
    var_name="-$(echo "$i" | awk '{print tolower(substr($1,8))}' | sed -e 's|_[0-9]\{1,3\}||' -e 's|_|-|g')"
    cmd_flags+=( "$var_name=\"${!i}\"" )
  done

  consul_cmd="consul agent ${cmd_flags[*]}"
  export SERVICE_CONSUL_CMD=${SERVICE_CONSUL_CMD:-"$(__escape_svsr_txt "$consul_cmd")"}
}


main() {

  init_vars

  echo "[$(date)][App-Name] $APP_NAME"
  echo "[$(date)][Environment] $ENVIRONMENT"

  __config_service_logrotate
  __config_service_logstash_forwarder
  __config_service_redpill
  __config_service_rsyslog
  config_consul

  echo "[$(date)][Consul][Start-Command] $SERVICE_CONSUL_CMD"

exec supervisord -n -c /etc/supervisor/supervisord.conf
}

main "$@"
