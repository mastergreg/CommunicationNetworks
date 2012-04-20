set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

set nf [open out.nam w]
$ns namtrace-all $nf

set f0 [open out0.tr w]
set f1 [open out1.tr w]

proc record {} {
	global sink0 sink1 f0 f1
	set ns [Simulator instance]
	#Ορισμός της χρονικής περιόδου που θα ξανακληθεί η διαδικασία.
	set time 0.1
	#Καταγραφή των bytes
	set bw0 [$sink0 set bytes_]
	set bw1 [$sink1 set bytes_]
	#Ορισμός του χρόνου της τρέχουσας καταγραφής
	set now [$ns now]
	#Υπολογισμός του bandwidth και καταγραφή αυτού στο αρχείο.
	puts $f0 "$now [expr $bw0/$time*8/1000000]"
	puts $f1 "$now [expr $bw1/$time*8/1000000]"
	#Κάνει την τιμή bytes_ 0
	$sink0 set bytes_ 0
	$sink1 set bytes_ 0
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

#Δημιουργία κόμβων
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Δημιουργία ζεύξεων
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n3 $n2 1Mb 10ms SFQ

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

$ns duplex-link-op $n2 $n3 queuePos 0.5

#Δημιουργία ενός UDP agent και «προσάρτησή» του στον κόμβο «n0»
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
$udp0 set class_ 1

#Δημιουργία μιας πηγής κίνησης CBR traffic source και «τοποθέτησή» της στον «udp0»
set cbr0 [new Application/Traffic/CBR]

#Προσδιορισμός της κίνησης δεδομένων που παράγεται στον κόμβο «n0»
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

# Δημιουργία ενός UDP agent και «προσάρτησή» του στον κόμβο «n1»
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
$udp1 set class_ 2

# Δημιουργία μιας πηγής κίνησης CBR και «τοποθέτησή» της στον «udp1»
set cbr1 [new Application/Traffic/CBR]

#Προσδιορισμός της κίνησης δεδομένων που παράγεται στον κόμβο «n1»
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1



#Δημιουργία δύο agents sink0 και sink1 για τη λήψη δεδομένων
set sink0 [new Agent/LossMonitor]
$ns attach-agent $n3 $sink0
set sink1 [new Agent/LossMonitor]
$ns attach-agent $n3 $sink1

# Σύνδεση των δύο CBR agents με τους sink agentς
$ns connect $udp0 $sink0
$ns connect $udp1 $sink1

$ns at 0.0 "record"
$ns at 0.5 "$cbr0 start"
$ns at 1.0 "$cbr1 start"
$ns at 4.0 "$cbr1 stop"
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"
$ns run

