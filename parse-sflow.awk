#!/usr/bin/env awk

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
}

/^agent / {
	host = $2
	printf("host: %s\n", host)
}

/^startDatagram/ {
	print "----"
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
		printf("interface:%d inOctets:%d\n", ifIndex, inOctets)
	} else if (type == "FLOWSAMPLE") {
		if (invlan == outvlan)
			printf("flow self: %d size:%d\n", invlan, pkt)
		else
			printf("flow src:%d dst:%d size:%d\n", src, dst, pkt)
	} else {
		print "??"
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
