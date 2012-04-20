BEGIN {
	data = 0;
	packets = 0;
	}
/^r/&&/tcp/ {
	data+=$6;
	packets++;
	}
END {
	printf("Total Data received\t: %d Bytes\n", data);
	printf("Total Packets received\t: %d\n", packets);
	}
