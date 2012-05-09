set ns [new Simulator]
$ns rtproto DV
set nf [open out.nam w]
set f0 [open ex3_4a1.tr w]
set f1 [open ex3_4a2.tr w]
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
set exp7 [new Application/Traffic/Exponential]
$exp7 set packetSize_ 1500
$exp7 set rate_ 1200k


$exp7 attach-agent $udp7




proc finish {} {
    global ns nf f0 f1
    $ns flush-trace
    close $nf
    close $f0
    close $f1
    exit 0
}
proc record {} {
      global sink5 sink7 f0 f1
      set ns [Simulator instance]
# Ορισμός της χρονικής περιόδου που θα ξανακληθεί η διαδικασία
      set time 0.01
# Καταγραφή των bytes
      set bw5 [$sink5 set bytes_]
      set bw7 [$sink7 set bytes_]
# Ορισμός του χρόνου της τρέχουσας καταγραφής
      set now [$ns now]
# Υπολογισμός του bandwidth και καταγραφή αυτού στο αρχείο
      puts $f0 "$now [expr (($bw5/$time)*8)/1000000]"
      puts $f1 "$now [expr (($bw7/$time)*8)/1000000]"
# Κάνει την μεταβλητή bytes 0
      $sink5 set bytes_ 0
      $sink7 set bytes_ 0
# Επαναπρογραμματισμός της διαδικασίας
      $ns at [expr $now+$time] "record"
}



$ns at 0 "record"
$ns at 0.5 "$cbr5 start"
$ns at 1 "$exp7 start"
$ns at 14 "$cbr5 stop"
$ns at 14.5 "$exp7 stop"
$ns at 15 "finish"

$ns run
