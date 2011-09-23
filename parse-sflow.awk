#!/usr/bin/env awk

#
# pass -v debug=1 to enable printing
# pass -v noop=1 to disable gmetric injection
#

function gmetric_counter(host, interface, inoctets, outoctets) 
{
	device_in = sprintf("port_%d_in", interface)
	device_out = sprintf("port_%d_out", interface)
	
	cmd = sprintf("gmetric -n %s -v %d -t double -S %s:%s", device_in, inoctets, host, host)
	pdebug(cmd)
	if (!noop)
		system(cmd)
	cmd = sprintf("gmetric -n %s -v %d -t double -S %s:%s", device_out, outoctets, host, host)
	pdebug(cmd)
	if (!noop)
		system(cmd)
}

function pdebug(s) 
{
	if (debug)
		print s
	
}

BEGIN {
	agent = "0.0.0.0"
	n = 0
	ifIndex = ""
	inOctets = 0
	outOctets = 0
	type = ""
	pkt = 0
	src = 88888
	dst = 77777

	# do we need declarations, really?
	in_ports[""] = 0
	out_ports[""] = 0
}

/^agent / {
	host = $2
	pdebug(sprintf("host: %s\n", host))
}

/^startDatagram/ {
	pdebug("----")
}

/^unixSecondsUTC / {
	ts = $2
}
	
/^startSample/ {
	n = 0
	ifIndex = 99999
	inOctets = 0
	outOctets = 0
	type = ""
	pkt = 0
	src = 88888
	dst = 77777
	invlan = 66666
	outvlan = 66666
} 

/^sampleType/ {
	type = $2
}

/^endSample/ {
	if (type == "COUNTERSSAMPLE") {
		
		if (!in_ports[ifIndex])
			in_ports[ifIndex] = sprintf("%d_%d", ts, inOctets)
		if (!out_ports[ifIndex])
			out_ports[ifIndex] = sprintf("%d_%d", ts, outOctets)

		# get the last timestamp and count for this interface
		split(in_ports[ifIndex], x, "_")
		last_ts = x[1]
		if (ts < last_ts) {
			printf("out of order: %d %d %d\n", ifIndex, last_ts, ts)
		}
		last_cnt = x[2]

		delta_cnt = inOctets - last_cnt
		delta_ts = ts - last_ts
		rate_in = delta_ts > 0 ? delta_cnt / delta_ts : 0
		in_ports[ifIndex] = sprintf("%d_%d", ts, inOctets)

		pdebug(sprintf("interface:%d inOctetsDelta:%d timeDelta:%d rate:%f\n", ifIndex, delta_cnt, delta_ts, rate_in))


		split(out_ports[ifIndex], x, "_")
		last_ts = x[1]
		if (ts < last_ts) {
			printf("out of order: %d %d %d\n", ifIndex, last_ts, ts)
		}
		last_cnt = x[2]

		delta_cnt = outOctets - last_cnt
		delta_ts = ts - last_ts
		rate_out = delta_ts > 0 ? delta_cnt / delta_ts : 0
		out_ports[ifIndex] = sprintf("%d_%d", ts, outOctets)

		pdebug(sprintf("interface:%d outOctetsDelta:%d timeDelta:%d rate:%f\n", ifIndex, delta_cnt, delta_ts, rate_out))

		pdebug(sprintf("interface:%d inOctets:%d\n", ifIndex, inOctets))
		pdebug(sprintf("interface:%d outOctets:%d\n", ifIndex, outOctets))

		gmetric_counter(host, ifIndex, rate_in, rate_out)
		# gmetric_counter(host, ifIndex, inOctets, outOctets)

	} else if (type == "FLOWSAMPLE") {
		if (invlan == outvlan)
			pdebug(sprintf("flow self: %d size:%d\n", invlan, pkt))
		else
			pdebug(sprintf("flow src:%d dst:%d size:%d\n", src, dst, pkt))
	} else {
		pdebug("??")
	}
}
	

/^inputPort/ {
	src = $2
}

/^outputPort/ {
	dst = $2
}

/^in_vlan/ {
	invlan = $2
}

/^out_vlan/ {
	outvlan = $2
}

/^ifIndex/ {
	ifIndex = $2
}

/^ifInOctets/ {
	inOctets = $2
}

/^ifOutOctets/ {
	outOctets = $2
}

/^sampledPacketSize/ {
	pkt = $2
}

{
	n = n + 1
}

# startSample ----------------------
# sampleType_tag 0:2
# sampleType COUNTERSSAMPLE
# sampleSequenceNo 15711
# sourceId 0:24
# counterBlock_tag 0:2
# dot3StatsAlignmentErrors 0
# dot3StatsFCSErrors 0
# dot3StatsSingleCollisionFrames 0
# dot3StatsMultipleCollisionFrames 0
# dot3StatsSQETestErrors 0
# dot3StatsDeferredTransmissions 0
# dot3StatsLateCollisions 0
# dot3StatsExcessiveCollisions 0
# dot3StatsInternalMacTransmitErrors 0
# dot3StatsCarrierSenseErrors 0
# dot3StatsFrameTooLongs 0
# dot3StatsInternalMacReceiveErrors 0
# dot3StatsSymbolErrors 0
# counterBlock_tag 0:1
# ifIndex 24
# networkType 6
# ifSpeed 10000000000
# ifDirection 1
# ifStatus 3
# ifInOctets 21978
# ifInUcastPkts 0
# ifInMulticastPkts 0
# ifInBroadcastPkts 37
# ifInDiscards 0
# ifInErrors 0
# ifInUnknownProtos 0
# ifOutOctets 259037515
# ifOutUcastPkts 32
# ifOutMulticastPkts 1498709
# ifOutBroadcastPkts 18174
# ifOutDiscards 929338
# ifOutErrors 0
# ifPromiscuousMode 0
# endSample   ----------------------


# startSample ----------------------
# sampleType_tag 0:1
# sampleType FLOWSAMPLE
# sampleSequenceNo 4206
# sourceId 0:3
# meanSkipCount 500
# samplePool 2103000
# dropEvents 0
# inputPort 3
# outputPort 46
# flowBlock_tag 0:1001
# extendedType SWITCH
# in_vlan 101
# in_priority 0
# out_vlan 1022
# out_priority 0
# flowBlock_tag 0:1
# flowSampleType HEADER
# headerProtocol 1
# sampledPacketSize 70
# strippedBytes 4
# headerLen 66
# headerBytes 00-1C-73-10-F5-72-E8-9A-8F-23-41-9A-08-00-45-00-00-34-07-2D-40-00-2A-06-AD-3A-0C-D0-B1-05-18-BF-C5-C8-94-A7-CE-67-18-2F-29-C3-05-30-8A-A8-80-10-01-12-17-E0-00-00-01-01-08-0A-01-15-CC-78-00-0A-BE-FC
# dstMAC 001c7310f572
# srcMAC e89a8f23419a
# IPSize 52
# ip.tot_len 52
# srcIP 12.208.177.5
# dstIP 24.191.197.200
# IPProtocol 6
# IPTOS 0
# IPTTL 42
# TCPSrcPort 38055
# TCPDstPort 52839
# TCPFlags 16
# endSample   ----------------------
# endDatagram   =================================
