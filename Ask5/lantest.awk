# Arxeio gia tin analysi dedomenon prosomoiosis pano apo
# topiko diktyo 802.3, kai gia ton ypologismo metron epidosis
#
# Ypologizetai to plithos ton paketon poy elifthisan, to plhthos
# to dedomenon pou elifthisan, kai mesi kathysterisi
#
# Gia na ektelestei to arxeio pliktrologoume
# awk -f lantest.awk < lantest.tr
#
# FileName: lantest.awk
# Author: D. J. Vergados
BEGIN {
	data=0;
	packets=0;
	buffersize=10;
	sumDelay=0;
	bufferspace=10000;
}

/^-/&&/cbr/ {
	sendtimes[$12%bufferspace]=$2
}

/^r/&&/cbr/ {
	data+=$6;
	packets++;
	sumDelay += $2 - sendtimes[$12%bufferspace];
}

END{
#	printf("Packet Size\t\t: %d Bytes\n", (data/packets)); 
	printf("Total Data received\t: %d Bytes\n", data);
	printf("Total Packets received\t: %d\n", packets);
	printf("Average Delay\t\t: %f sec\n\n", (1.0 * sumDelay)/ packets);
}
