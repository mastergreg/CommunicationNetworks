set ns [new Simulator]

#Δυναμική δρομολόγηση
$ns rtproto DV

$ns color 1 Blue
$ns color 2 Red

set nf [open out.nam w]
$ns namtrace-all $nf

set f0 [open out0.tr w]
set f1 [open out1.tr w]

proc record {} {
	global sink5 sink7 f0 f1
	set ns [Simulator instance]
	#Ορισμός της χρονικής περιόδου που θα ξανακληθεί η διαδικασία.
	set time 0.1
	#Καταγραφή των bytes
	set bw5 [$sink5 set bytes_]
	set bw7 [$sink7 set bytes_]
	#Ορισμός του χρόνου της τρέχουσας καταγραφής
	set now [$ns now]
	#Υπολογισμός του bandwidth και καταγραφή αυτού στο αρχείο.
	puts $f0 "$now [expr $bw5/$time*8/1000000]"
	puts $f1 "$now [expr $bw7/$time*8/1000000]"
	#Κάνει την τιμή bytes_ 0
	$sink5 set bytes_ 0
	$sink7 set bytes_ 0
	#Επαναπρογραμματισμός της διαδικασίας.
	$ns at [expr $now+$time] "record"
}


proc finish {} {
	global ns nf f0 f1
	$ns flush-trace
	close $nf
	close $f0
	close $f1
	exit 0
}

#Δημιουργία 9 κόμβων μέσω for loop
for {set i 0} {$i < 9} {incr i} {
	set n($i) [$ns node]
}

#Δημιουργία ζεύξεων
for {set i 0 } {$i < 9} {incr i} {
	$ns duplex-link $n($i) $n([expr ($i+1)%5]) 1Mb 10ms DropTail
}

$ns duplex-link $n(3) $n(0) 1Mb 40ms DropTail
$ns duplex-link $n(5) $n(8) 1Mb 40ms DropTail
$ns duplex-link $n(6) $n(7) 1Mb 30ms DropTail
$ns duplex-link $n(2) $n(7) 1Mb 20ms DropTail

#Ανάθεση "κόστους" ζεύξεων
$ns cost $n(0) $n(1) 1
$ns cost $n(0) $n(3) 4
$ns cost $n(0) $n(4) 1
$ns cost $n(1) $n(0) 1
$ns cost $n(1) $n(2) 1
$ns cost $n(1) $n(5) 1
$ns cost $n(2) $n(1) 1
$ns cost $n(2) $n(3) 1
$ns cost $n(2) $n(6) 1
$ns cost $n(2) $n(7) 2
$ns cost $n(3) $n(0) 4
$ns cost $n(3) $n(2) 1
$ns cost $n(3) $n(4) 1
$ns cost $n(3) $n(7) 1
$ns cost $n(4) $n(0) 1
$ns cost $n(4) $n(3) 1
$ns cost $n(4) $n(8) 1
$ns cost $n(5) $n(1) 1
$ns cost $n(5) $n(8) 4
$ns cost $n(6) $n(2) 1
$ns cost $n(6) $n(7) 3
$ns cost $n(7) $n(2) 1
$ns cost $n(7) $n(3) 1
$ns cost $n(7) $n(6) 3
$ns cost $n(8) $n(4) 1
$ns cost $n(8) $n(5) 4

#Δημιουργία και προσάρτηση UDP και Sink Agent στον κόμβο «n5» (κόκκινο)
set udp5 [new Agent/UDP]
$ns attach-agent $n(5) $udp5
$udp5 set fid_ 5
$ns color 5 red
set sink5 [new Agent/LossMonitor]
$ns attach-agent $n(5) $sink5

#Δημιουργία και προσάρτηση UDP και Sink Agent στον κόμβο «n7» (μπλέ)
set udp7 [new Agent/UDP]
$ns attach-agent $n(7) $udp7
$udp7 set fid_ 7
$ns color 7 blue
set sink7 [new Agent/LossMonitor]
$ns attach-agent $n(7) $sink7

#Σύνδεση των πηγών και των προορισμών
$ns connect $udp5 $sink7
$ns connect $udp7 $sink5

#Δημιουργία μιας πηγής κίνησης CBR traffic source και «τοποθέτησή» της στους ψudp5» και «udp7»
set cbr5 [new Application/Traffic/Exponential]
$cbr5 attach-agent $udp5
set cbr7 [new Application/Traffic/Exponential]
$cbr7 attach-agent $udp7

#Ορισμός γεγονότων
$ns at 0.0 "record"
$ns at 0.5 "$cbr5 start"
$ns at 1 "$cbr7 start"
#Διακοπή ζεύξης μεταξύ των κόμβων “1” και “2” για 0.4 sec
#$ns rtmodel-at 1.2 down $n(1) $n(2)
#$ns rtmodel-at 1.6 up $n(1) $n(2)
$ns at 15 "$cbr5 stop"
$ns at 15 "$cbr7 stop"
$ns at 15.5 "finish"
$ns run
