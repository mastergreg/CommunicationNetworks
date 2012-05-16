set ns [new Simulator]
set nf [open lab4.nam w]

$ns namtrace-all $nf


set trf [open lab4.tr w]
$ns trace-all $trf

for {set i 0} {$i < 4} {incr i} {
     set n($i) [$ns node]
}


$ns at 0.0 "$n(0) label GBN_sender"
$ns at 0.0 "$n(1) label SW_sender"
$ns at 0.0 "$n(3) label GBN_reciever"
$ns at 0.0 "$n(2) label SW_sender"






for {set i 0 } {$i < 4} {incr i} {
     $ns duplex-link $n($i) $n([expr ($i+1)%4]) 2Mb 50ms DropTail
}


$ns duplex-link-op $n(0) $n(3) orient right
$ns duplex-link-op $n(1) $n(2) orient right
$ns duplex-link-op $n(0) $n(1) orient down
$ns duplex-link-op $n(3) $n(2) orient down



# Define color index
$ns color 0 red
$ns color 1 green
# Setup go-back-n sender-receiver
set tcp0 [new Agent/TCP/Reno]
$tcp0 set window_ 50
# Disable modelling the initial SYN/SYNACK exchange
$tcp0 set syn_ false



# The initial size of the congestion window on slow-start
$tcp0 set windowInit_ 50
# Set flow ID
$tcp0 set fid_ 0
$ns attach-agent $n(0) $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n(3) $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
# Setup stop-and-wait sender-receiver
set tcp1 [new Agent/TCP/Reno]
$tcp1 set window_ 1
# Disable modelling the initial SYN/SYNACK exchange
$tcp1 set syn_ false
# The initial size of the congestion window on slow-start
$tcp1 set windowInit_ 1
# Set flow ID
$tcp1 set fid_ 1
$ns attach-agent $n(1) $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n(2) $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1


proc finish {} {
    global ns nf trf
    $ns flush-trace
    close $nf
    close $trf
    exit 0
}





$ns at 0.5 "$ftp0 produce 50"
$ns at 0.5 "$ftp1 produce 50"
$ns at 10 "finish"

$ns run
