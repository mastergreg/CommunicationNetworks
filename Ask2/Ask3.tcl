set ns [new Simulator]
#Δυναμική δρομολόγηση
$ns rtproto DV

set nf [open out.nam w]
$ns namtrace-all $nf
set f0 [open out0.tr w]

proc record {} {
	global sink0 f0
	set ns [Simulator instance]
	#Ορισμός της χρονικής περιόδου που θα ξανακληθεί η διαδικασία. >>ΑΚΡΙΒΕΙΑ<<
	set time 0.05
	#Καταγραφή των bytes
	set bw0 [$sink0 set bytes_]
	#Ορισμός του χρόνου της τρέχουσας καταγραφής
	set now [$ns now]
	#Υπολογισμός του bandwidth και καταγραφή αυτού στο αρχείο.
	puts $f0 "$now [expr $bw0/$time*8/1000000]"
	#Κάνει την τιμή bytes_ 0
	$sink0 set bytes_ 0
	#Επαναπρογραμματισμός της διαδικασίας.
	$ns at [expr $now+$time] "record"
}


proc finish {} {
	global ns nf f0
	$ns flush-trace
	close $nf
	close $f0
	exit 0
}

#Δημιουργία 7 κόμβων με for loop
for {set i 0} {$i <7} {incr i} {
	set n($i) [$ns node]
}

#Σύνδεση κάθε κόμβου με τον επόμενο
for {set i 0} {$i <7} {incr i} {
	$ns duplex-link $n($i) $n([expr ($i+1)%7]) 1Mb 10ms DropTail
}

#Δημιουργία ενός UDP agent και «προσκόλλησή» του στον κόμβο «n0»
set udp0 [new Agent/UDP]
$ns attach-agent $n(0) $udp0
# Δημιουργία μιας πηγής κίνησης CBR traffic source και «τοποθέτησή» της στον «udp0»
set cbr0 [new Application/Traffic/CBR]
#Προσδιορισμός της κίνησης δεδομένων που παράγεται στον κόμβο n0
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

#Δημιουργία του agent sink0 για τη λήψη δεδομένων και «προσάρτησή» του στον κόμβο «n3»
set sink0 [new Agent/LossMonitor]
$ns attach-agent $n(3) $sink0

# Σύνδεση του CBR agent με τον Sink agent
$ns connect $udp0 $sink0

#Αρχή record
$ns at 0.0 "record"
#Αρχή γεννήτριας κίνησης
$ns at 0.5 "$cbr0 start"
#Διακοπή ζεύξης μεταξύ των κόμβων “1” και “2” για 1 sec
$ns rtmodel-at 1.0 down $n(1) $n(2)
$ns rtmodel-at 2.0 up $n(1) $n(2)
#Τέλος γεννήτριας κίνησης
$ns at 4.5 "$cbr0 stop"
#Τέλος simulation
$ns at 5.0 "finish"
$ns run
