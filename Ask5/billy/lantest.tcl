### Arxeio prosomopoiosis gia meleth epidosis prostokollou 802.3
### gia topika diktya. To senario apoteleitai apo enan arithmo
### stathmon syndedemonon pano se ena topiko diktyo LAN 802.3.
### H gennitria kinisis einai CBR (statherou rythmou metadosis me
### tetoio ryrhmo oste panta na yparxoun paketa gia metadosi.
###
###	0 	1 	2
### 	| 	| 	|
### =======================
### 	| 	| 	|
###	3 	4 	5

#Simulation Setup
set opt(tr) "lantest.tr" ;	# Trace αρχείο που περιλαμβάνει τα αποτελέσματα της προσομοίωσης
set opt(nam) "lantest.nam" ;	# Αρχείο καταγραφής πληροφορίας NAM
set opt(seed) 0 ;		# Used for RNG
set opt(stop) 1 ;		# Simulation duration in seconds
set opt(node) 6 ;		# Number of nodes in LAN
set opt(qsize) 100	 ;		# Buffer Size in each node
set opt(bw) 10000000 ;		# LAN bandwidth
set opt(delay) 0.000000950 ;	# Transfer delay in LAN
set opt(packetsize) 1500 ;	# Packet Size
set opt(rate) [expr 2* $opt(bw)/ $opt(node)] ;	# Data generation rate of each node

# LAN parameters
set opt(ll) LL
set opt(ifq) Queue/DropTail
set opt(mac) Mac/802_3
set opt(chan) Channel

# Dimiourgia topologias diktyou
proc create-topology {} {
	global ns opt
	global lan node
	set num $opt(node)

	# Creating LAN nodes
	for {set i 0} {$i < $num} {incr i} {
		set node($i) [$ns node]
		lappend nodelist $node($i)
	}
	
	# Connecting the nodes
	set lan [$ns newLan $nodelist $opt(bw) $opt(delay) \
			-llType $opt(ll) -ifqType $opt(ifq) \
			-macType $opt(mac) -chanType $opt(chan)]
}	
	
# Data transfer setup
proc create-connections {} {
	global ns opt
	global node udp sink cbr
	for {set i 1} {$i < $opt(node)} {incr i} {
		set udp($i) [new Agent/UDP]				#Create UDP agent
		$udp($i) set packetSize_ [expr $opt(packetsize) + 100]
		$ns attach-agent $node($i) $udp($i)			#Attach agent to n[i] node
		set sink($i) [new Agent/Null]
		$ns attach-agent $node(0) $sink($i)
		$ns connect $udp($i) $sink($i)
		set cbr($i) [new Application/Traffic/CBR]
		$cbr($i) set rate_ $opt(rate)
		$cbr($i) set packetSize_ $opt(packetsize)
		$cbr($i) set random_ 1
		$cbr($i) attach-agent $udp($i)
		$ns at 0.000$i "$cbr($i) start"
	}
}

# Anoigma trace arxeiou gia tin katagrafi ton symbanton tis prosomoiosis
proc create-trace {} {
	global ns opt
	set trfd [open $opt(tr) w] ;# Anoigma tou arxeiou
	$ns trace-all $trfd ;# Entoli gia katagrafi gegonoton
	return $trfd
}

# Anoigma nam arxeiou gia tin animation ton symbanton tis prosomoiosis
proc create-nam-trace {} {
	global ns opt
	set namfd [open $opt(nam) w] ;# Anoigma tou arxeiou
	$ns namtrace-all $namfd ;# Entoli gia katagrafi gegonoton
	return $namfd
}

# Diadikasia termatismou - Klesimo anoixton arxeion
proc finish {} {
	global ns trfd namfd
	$ns flush-trace
	close $trfd
	close $namfd
	exit 0
}

# MAIN #
set ns [new Simulator]
set trfd [create-trace]
set namfd [create-nam-trace]
create-topology
create-connections
$ns at $opt(stop) "finish"
$ns run
