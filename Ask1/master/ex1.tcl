set ns [new Simulator]
set nf [open out.nam w]
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 10Mb 10ms DropTail

set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1500
$cbr0 set interval_ 0.01
$cbr0 attach-agent $udp0

set sink [new Agent/LossMonitor]
$ns attach-agent $n1 $sink

$ns connect $udp0 $sink



proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exit 0
}

$ns at 1 "$cbr0 start"
$ns at 9 "$cbr0 stop"

$ns at 10.0 "finish"
$ns run
