#!/bin/awk

BEGIN {
    data_0=0;
    packets_0=0;
    data_1=0;
    packets_1=0;
}
/^r/&&/tcp/ {
    flow_id = $8;
    if (flow_id == 0) {
        data_0 += $6;
        packets_0++;
    }
    if (flow_id == 1) {

        data_1 += $6;
        packets_1++;
    }
}
END {
    printf("Total Data received for flow ID 0\t: %d Bytes\n", data_0);
    printf("Total Packets received for flow ID 0\t: %d\n", packets_0);
    printf("Total Data received for flow ID 1\t: %d Bytes\n", data_1);
    printf("Total Packets received for flow ID 1\t: %d\n", packets_1);
}
