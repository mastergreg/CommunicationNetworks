set ns [new Simulator]
$ns rtproto DV
set nf [open out.nam w]
$ns namtrace-all $nf

for {set i 0} {$i < 9} {incr i} {
     set n($i) [$ns node]
}

for {set i 0 } {$i < 9} {incr i} {
     $ns duplex-link $n($i) $n([expr ($i+1)%5]) 2Mb 10ms DropTail
}
$ns duplex-link $n(3) $n(0) 2Mb 40ms DropTail
$ns duplex-link $n(5) $n(8) 2Mb 40ms DropTail
$ns duplex-link $n(6) $n(7) 2Mb 30ms DropTail
$ns duplex-link $n(2) $n(7) 2Mb 20ms DropTail

$ns cost $n(3) $n(0) 4
$ns cost $n(5) $n(8) 4 
$ns cost $n(6) $n(7) 3 
$ns cost $n(2) $n(7) 2 

$ns cost $n(0) $n(3) 4
$ns cost $n(8) $n(5) 4 
$ns cost $n(7) $n(6) 3 
$ns cost $n(7) $n(2) 2 

set udp5 [new Agent/UDP]
$ns attach-agent $n(5) $udp5
$udp5 set fid_ 5
$ns color 5 red
set sink5 [new Agent/LossMonitor]
$ns attach-agent $n(5) $sink5

set udp7 [new Agent/UDP]
$ns attach-agent $n(7) $udp7
$udp7 set fid_ 7
$ns color 7 green
set sink7 [new Agent/LossMonitor]
$ns attach-agent $n(7) $sink7


# Σύνδεση των πηγών και των προορισμών
$ns connect $udp5 $sink7
$ns connect $udp7 $sink5
# Στρώμα εφαρμογής
set cbr5 [new Application/Traffic/CBR]
$cbr5 set packetSize_ 1500
$cbr5 set interval_ 0.01
$cbr5 attach-agent $udp5
set cbr7 [new Application/Traffic/CBR]
$cbr7 set packetSize_ 1500
$cbr7 set interval_ 0.01


$cbr7 attach-agent $udp7




proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exit 0
}



$ns at 0.5 "$cbr5 start"
$ns at 1 "$cbr7 start"
$ns rtmodel-at 1.2 down $n(1) $n(2)
$ns rtmodel-at 1.6 up   $n(1) $n(2)
$ns at 2 "$cbr5 stop"
$ns at 2.5 "$cbr7 stop"
$ns at 3 "finish"

$ns run
