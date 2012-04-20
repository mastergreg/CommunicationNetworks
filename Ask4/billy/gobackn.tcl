set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

set trf [open out.tr w]
$ns trace-all $trf

#Διαδικασία finish
proc finish {} {
	global ns nf trf
	$ns flush-trace
	close $nf
	close $trf
	exit 0
}

#Δημιουργία κόμβων
set n0 [$ns node]
set n1 [$ns node]

#Δημιουργία ζεύξης
#$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n0 $n1 100Mb 100ms DropTail

#Δημιουργία TCP σύνδεσης από "n0" σε "n1"
set tcp0 [$ns create-connection TCP/Reno $n0 TCPSink $n1 0]
#Μέγεθος παραθύρου go back Ν
$tcp0 set window_ 39 #5
#Μέγεθος πακέτου tcp
$tcp0 set packetSize_ 1000
#$tcp0 set packetSize_ 6260

#Δημιουργία FTP γεννήτριας για μεταφορά αρχείου άπειρου μεγέθους 
set ftp0 [$tcp0 attach-app FTP]

#Event list
$ns at 0.0 "$ftp0 start"
$ns at 5.0 "finish"
#Run Simulation
$ns run

