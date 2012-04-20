# Dimiourgia antikeimenou prosomoioti
set ns [new Simulator]
# Dimiourgia Animation 
set nf [open out.nam w] 
$ns namtrace-all $nf
# Dimiourgia Trace File
set trf [open out.tr w] 
$ns trace-all $trf

# Entoles termatismou
proc finish {} {
	global ns nf f1 f2 trf 
	$ns flush-trace 
	close $nf 
	close $f1 
	close $f2 
	close $trf 
	exit 0
}

# Kathorismos protokollou dromolofisis 
$ns rtproto DV
# Dimiourgia Komvon Diktyou 
for {set i 0} {$i < 4} {incr i} {
  set n($i) [$ns node]
}

# Dimourgia zeykseon 
$ns duplex-link $n(0) $n(1) 1Mb 10ms DropTail 
$ns duplex-link $n(1) $n(2) 1Mb 10ms DropTail 
$ns duplex-link $n(1) $n(3) 1Mb 10ms DropTail 
$ns duplex-link $n(2) $n(3) 1Mb 10ms DropTail

# Emfanisi ouras anamonnis sto nam 
$ns duplex-link-op $n(2) $n(1) queuePos 0.5
#Στρώμα Μεταφοράς, κόμβος 2: πηγή, κόμβος 0: προορισμός 
set udp1 [new Agent/UDP] 
$ns attach-agent $n(2) $udp1 
$udp1 set fid_ 1
$ns color 1 red 
set sink1 [new Agent/LossMonitor] 
$ns attach-agent $n(0) $sink1

#Στρώμα Μεταφοράς, κόμβος 3: πηγή, κόμβος 1: προορισμός 
set udp2 [new Agent/UDP] 
$ns attach-agent $n(3) $udp2 
$udp2 set fid_ 2
$ns color 2 blue 
set sink2 [new Agent/LossMonitor] 
$ns attach-agent $n(1) $sink2

#Σύνδεση των πηγών και των προορισμών 
$ns connect $udp1 $sink1 
$ns connect $udp2 $sink2

#Στρώμα εφαρμογής set cbr1 [new Application/Traffic/CBR] 
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1 
$cbr1 set packetSize_ 600 
$cbr1 set interval_ 0.005

set cbr2 [new Application/Traffic/CBR] 
$cbr2 attach-agent $udp2 
$cbr2 set packetSize_ 600 
$cbr2 set interval_ 0.005

# Didikasia Katagrafis kinisis 
proc record {} {
	global sink1 sink2 f1 f2 
	set ns [Simulator instance] 
	#Ορισμός της ώρας που η διαδικασία θα ξανακληθεί 
	set time 0.1 
	#Καταγραφή των bytes
	set bw1 [$sink1 set bytes_] 
	set bw2 [$sink2 set bytes_] 
	#Λήψη της τρέχουσας ώρας 
	set now [$ns now] 
	#Υπολογισμός του bandwidth και καταγραφή αυτού στο αρχείο 
	puts $f1 "$now [expr (($bw1/$time)*8)/1000000]"
	puts $f2 "$now [expr (($bw2/$time)*8)/1000000]" 
	#Κάνει την μεταβλητή bytes 0 
	$sink1 set bytes_ 0 
	$sink2 set bytes_ 0
	#Επαναπρογραμματισμός της διαδικασίας 
	$ns at [expr $now+$time] "record"
}

# Anoigma arkeion xgraph 
set f1 [open out1.tr w] 
set f2 [open out2.tr w]

#Ορισμός γεγονότων 
$ns at 0.0 "record"
$ns at 0.3 "$cbr1 start"
$ns at 0.3 "$cbr2 start"
$ns at 2.9 "$cbr1 stop"
$ns at 2.9 "$cbr2 stop"
$ns at 3 "finish"

# Astoxia Zeyksis 
$ns rtmodel-at 1.0 down $n(0) $n(1)
# Epanafora Zeyksis 0-1 
$ns rtmodel-at 2.0 up $n(0) $n(1)
# Ektelesi tis prosomoiosis 
$ns run
