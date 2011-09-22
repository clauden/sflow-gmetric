----
getting sflow datagrams

$ sflowtool | parse_sflow.awk

sflowtool listens on sflow port, emits text every time it receives a datagram

parse_sflow.awk must interpret text, invoke gmetric like

$ gmetric -n "port_32_in_octets" -v "21345" -t double -S 100.100.100.100:nothing

where -S is switch host (and its resolved hostname)

----
gmetad:
data_source "switch sflow data" localhost:8620

fake-gmond.conf:
cluster { 
  name = "Network" 
} 

udp_send_channel { 
  mcast_join = 239.2.11.71 
  port = 8620
  ttl = 1 
}

$ gmond -c fake-gmond.conf -d 99

This makes gmond listen for the gmetric packets on 8620

----

