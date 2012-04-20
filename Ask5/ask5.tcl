### Arxeio prosomopoiosis gia meleth epidosis prostokollou 802.3
### gia topika diktya. To senario apoteleitai apo enan arithmo
### stathmon syndedemonon pano se ena topiko diktyo LAN 802.3.
### H gennitria kinisis einai CBR (statherou rythmou metadosis me
### tetoio ryrhmo oste panta na yparxoun paketa gia metadosi.
###
### 0 1 2
### | | |
### =======================
### | | |
### 3 4 5
### Gia tin ektelesi tou arxeiou pliktrologoume
### ns lantest.tcl
### Ta apotelesmata vriskontai sta arxeia lantest.nam (Animation)
### kai lantest.tr (Trace File)
### FileName: lantest.tcl
### Author: D. J. Vergados

set opt(tr) "lantest.tr" ;# Trace arxeiou pou perilamvanei ta apotelesmata tis prosomoiosis
set opt(nam) "lantest.nam" ;# Arxeio katagrafis pliroforias nam
set opt(seed) 5 ;# Gia ti gennhtria tyxaion arithmon
set opt(stop) 1 ;# Diarkeia prosomoiosis se deyterolepta
set opt(node) 6 ;# Arithmos xriston sto LAN
set opt(qsize) 100 ;# Megethos buffer se kathe stathmo
set opt(bw) 10000000 ;# Rythmos metadoshs sto LAN
set opt(delay) 0.000000950 ;# Kathysterisi metadoshs sto LAN
set opt(packetsize) 1024 ;# Megethos paketou
set opt(rate) [expr 2* $opt(bw)/ $opt(node)] ;# Rythmos paragogis dedomenonn kathe stathmou.

### Parametroi tou LAN
set opt(ll) LL
set opt(ifq) Queue/DropTail
set opt(mac) Mac/802_3
set opt(chan) Channel

# Dimiourgia topologias diktyou
proc create-topology {} {
	global ns opt
	global lan node
	set num $opt(node)

	### Dimiourgia Stathmon tou lan
	for {set i 0} {$i < $num} {incr i} {
		set node($i) [$ns node]
		lappend nodelist $node($i)
		}
	### Dimourgia tou LAN
	set lan [$ns newLan $nodelist $opt(bw) $opt(delay) \
	-llType $opt(ll) -ifqType $opt(ifq) \
	-macType $opt(mac) -chanType $opt(chan)]
}

### Dimiourgia Kinisis metaksy ton stathmon
proc create-connections {} {
	global ns opt
	global node udp sink cbr
	for {set i 1} {$i < $opt(node)} {incr i} {
		set udp($i) [new Agent/UDP]
		$udp($i) set packetSize_ [expr $opt(packetsize) + 100]
		$ns attach-agent $node($i) $udp($i)
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

### Anoigma trace arxeiou gia tin katagrafi ton symbanton tis
### prosomoiosis
proc create-trace {} {
	global ns opt
	set trfd [open $opt(tr) w] ;# Anoigma tou arxeiou
	$ns trace-all $trfd ;# Entoli gia katagrafi gegonoton
	return $trfd
}

### Anoigma nam arxeiou gia tin animation ton symbanton tis prosomoiosis
proc create-nam-trace {} {
	global ns opt
	set namfd [open $opt(nam) w] ;# Anoigma tou arxeiou
	$ns namtrace-all $namfd ;# Entoli gia katagrafi gegonoton
	return $namfd
}

### Diadikasia termatismou - Klesimo anoixton arxeion
proc finish {} {
	global ns trfd namfd
	$ns flush-trace
	close $trfd
	close $namfd
	exit 0
}

## MAIN ##
set ns [new Simulator]	
set trfd [create-trace]
set namfd [create-nam-trace]
create-topology
create-connections
$ns at $opt(stop) "finish"
$ns run
