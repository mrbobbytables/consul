docker run -d --net=host  \
-e CONSUL_ADVERTISE=127.0.0.1  \
-e CONSUL_BOOTSTRAP=true       \
-e CONSUL_SERVER=true          \
-e CONSUL_UI=true              \
mrbobbytables/consul
