set ns [new Simulator]
set nf [open lab5.nam w]

$ns namtrace-all $nf

set trf [open lab5.tr w]
$ns trace-all $trf

set n(0) [$ns node]
set n(1) [$ns node]

$ns at 0.0 "$n(0) label SRP_sender"
$ns at 0.0 "$n(1) label SRP_reciever"

$ns duplex-link $n(0) $n(1) 10Mb 5ms DropTail

set tcp0 [new Agent/TCP/Sack1]
$tcp0 set window_ 4
$tcp0 set windowInit_ 4
$tcp0 set syn_ false
$tcp0 set packetSize 1500
$ns attach-agent $n(0) $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $n(1) $sink0
$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

proc finish {} {
    global ns nf trf
    $ns flush-trace
    close $nf
    close $trf
    exit 0
}

$ns at 0.5 "$ftp0 start"
$ns at 3.5 "$ftp0 stop"
$ns at 4 "finish"

$ns run
