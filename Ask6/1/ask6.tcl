###  Arxeio prosomopoiosis gia meleth epidosis prostokollou   
###  dromologisis Distance Vector (DV). To senario apoteleitai   
###  apo 6 komvous syndedemenous me zeykseis diaforerikou varous,  
###  stin topologia tou parakato Sxhmatos. 
             ###
###        B--3--C       Gia tin prosomoiosi o komvos A onomazetai  
###      2/|    /|\5     node 0, o B->1, o C->2, o D->3, o E->4 kai 
###      / |   / | \     o F->5 
###     A  2  3  1  F 
###      \ | /   | /     O kombos C stelnei CBR kinisi ston A, kai o 
###      1\|/    |/2     F stelnei CBR kinisi ston D. 
###        D--1--E 
             ###
### Gia tin ektelesi tou arxeio pliktrologoume 
###    ns ask7a.tcl 
###
### Ta apotelesmata vriskontai sta arxeia out.nam (Animation) 
### kai out.tr (Trace File). Episis ta arxeia out1.tr kai out2.tr 
### perilamvanoun grafikes parastaseis tis kinisis (xgraph). 
### FileName: ask7a.tcl 
### Author:   D. J. Vergados 


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
for {set i 0} {$i < 6} {incr i} { 
	set n($i) [$ns node] 
}
	
# Dimourgia zeykseon kai kathorismos costous 
$ns duplex-link $n(0) $n(1) 1Mb 20ms DropTail 
$ns cost $n(0) $n(1) 2 
$ns cost $n(1) $n(0) 2 
$ns duplex-link $n(0) $n(3) 1Mb 10ms DropTail 
$ns cost $n(0) $n(3) 1 
$ns cost $n(3) $n(0) 1 
$ns duplex-link $n(1) $n(2) 1Mb 30ms DropTail 
$ns cost $n(1) $n(2) 3 
$ns cost $n(2) $n(1) 3 
$ns duplex-link $n(1) $n(3) 1Mb 20ms DropTail 
$ns cost $n(1) $n(3) 2 
$ns cost $n(3) $n(1) 2 
$ns duplex-link $n(2) $n(3) 1Mb 30ms DropTail 
$ns cost $n(2) $n(3) 3 
$ns cost $n(3) $n(2) 3 
$ns duplex-link $n(2) $n(4) 1Mb 10ms DropTail 
$ns cost $n(2) $n(4) 1 
$ns cost $n(4) $n(2) 1 
$ns duplex-link $n(2) $n(5) 1Mb 50ms DropTail 
$ns cost $n(2) $n(5) 5 
$ns cost $n(5) $n(2) 5 
$ns duplex-link $n(3) $n(4) 1Mb 10ms DropTail 
$ns cost $n(3) $n(4) 1 
$ns cost $n(4) $n(3) 1 
#$ns cost $n(4) $n(3) 3 
#$ns cost $n(3) $n(4) 3
$ns duplex-link $n(4) $n(5) 1Mb 20ms DropTail 
$ns cost $n(4) $n(5) 2 
$ns cost $n(5) $n(4) 2 

#Ptwsi zeyksis D-E 
$ns rtmodel-at 1.0 down $n(3) $n(4) 

#Στρώµα Μεταφοράς, κόµβος 2: πηγή, κόμβος 03: προορισµός
set udp1 [new Agent/UDP] 
$ns attach-agent $n(2) $udp1 
$udp1 set fid_ 1 
$ns color 1 red 
set sink1 [new Agent/LossMonitor] 
$ns attach-agent $n(0) $sink1 

#Στρώµα Μεταφοράς, κόµβος 5: πηγή, κόμβος 3: προορισµός
set udp2 [new Agent/UDP] 
$ns attach-agent $n(5) $udp2 
$udp2 set fid_ 2 
$ns color 2 blue 
set sink2 [new Agent/LossMonitor] 
$ns attach-agent $n(3) $sink2 

#Σύνδεση των πηγών και των προορισµών
$ns connect $udp1 $sink1 
$ns connect $udp2 $sink2 

#Στρώµα εφαρµογής
set cbr1 [new Application/Traffic/CBR] 
$cbr1 attach-agent $udp1 
set cbr2 [new Application/Traffic/CBR] 
$cbr2 attach-agent $udp2 

# Didikasia Katagrafis kinisis 
proc record {} { 
	global sink1 sink2 f1 f2 
	set ns [Simulator instance] 
	#Ορισµός της ώρας που η διαδικασία θα ξανακληθεί
	set time 0.1 
	#Καταγραφή των bytes 
	set bw1 [$sink1 set bytes_] 
	set bw2 [$sink2 set bytes_] 
  #Λήψη της τρέχουσας ώρας
	set now [$ns now] 
	#Υπολογισµός του bandwidth και καταγραφή αυτού στο αρχείο
	puts $f1 "$now [expr (($bw1/$time)*8)/1000000]"
	puts $f2 "$now [expr (($bw2/$time)*8)/1000000]" 
	#Κάνει την µεταβλητή bytes 0 
	$sink1 set bytes_ 0 
	$sink2 set bytes_ 0 
	#Επαναπρογραµµατισµός της διαδικασίας
	$ns at [expr $now+$time] "record" 
}

# Anoigma arkeion xgraph 
set f1 [open out1.tr w] 
set f2 [open out2.tr w] 

#Ορισµός γεγονότων
$ns at 0.0 "record" 
$ns at 0.3 "$cbr1 start" 
$ns at 0.5 "$cbr2 start" 
$ns at 2.5 "$cbr1 stop" 
$ns at 2.5 "$cbr2 stop" 
$ns at 3 "finish" 

# Ektelesi tis prosomoiosis 
$ns run 
