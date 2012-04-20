# Enarksi Prosomoiwsis
set ns [new Simulator] 

#Open the nam trace file  
set nf [open out.nam w]  
$ns namtrace-all $nf  
set trf [open out.tr w]  
$ns trace-all $trf 

#Diadikasia finish
proc finish {} { 
	global ns nf trf
	$ns flush-trace 
	#Close the NAM trace file 
	close $nf 
	close $trf 
	exit 0 
	}



#################
### TOPOLOGIA ###
#################

##Dimiourgia 4 komvwn##
set n0 [$ns node] 
set n1 [$ns node]  
set n2 [$ns node] 
set n3 [$ns node] 

##Dimiourgia Zeyksewn##
$ns duplex-link $n0 $n2 2Mb 10ms DropTail 
$ns duplex-link $n1 $n2 2Mb 10ms DropTail 
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail 
#Kathorizoume to megethos tis ouras (buffer)
$ns queue-limit $n2 $n3 10 ; 

### Queue-monitoring gia ti zeyksi twn n2,n3 - Erwtima (z) ###
$ns duplex-link-op $n2 $n3 queuePos 0.5


##Dimiourgia Agents##

#Dimiourgia TCP agent ston komvo n0
set tcp [new Agent/TCP] 
$tcp set class_ 2 
$ns attach-agent $n0 $tcp 

#Prosartisi pigis FTP ston komvo n0
set ftp [new Application/FTP] 
$ftp attach-agent $tcp 
$ftp set type_ FTP 

#Dimiourgia TCP sink agent ston komvo n3
set sink [new Agent/TCPSink] 
$ns attach-agent $n3 $sink 
$ns connect $tcp $sink ;        #Syndesi TCP me to sink
$tcp set fid_ 2 

#Dimiourgia UPD agent ston komvo n1
set udp [new Agent/UDP] 
$ns attach-agent $n1 $udp
$udp set class_ 1 

#Prosartisi pigis CBR ston komvo n1
set cbr [new Application/Traffic/CBR] 
$cbr attach-agent $udp 
$cbr set type_ CBR 
$cbr set packet_size_ 1000 ; 	  #Megethos paketwn
$cbr set rate_ 1mb 		;       	#Rythmos metadosis dedomenwn
$cbr set random_ false 	;     	#Den yparxei random thoryvos sti metadosi

#Dimiourgia null agent ston komvo n3
set null [new Agent/Null] 
$ns attach-agent $n3 $null 
$ns connect $udp $null ;        #Syndesi UDP me to sink
$udp set fid_ 1 


### Erwtima (e) ###

#Dimiourgia TCP agent ston komvo n1
set tcp2 [new Agent/TCP] 
$tcp2 set class_ 3 
$ns attach-agent $n1 $tcp2 

#Prosartisi pigis FTP ston komvo n1
set ftp2 [new Application/FTP] 
$ftp2 attach-agent $tcp2 
$ftp2 set type_ FTP 

#Dimiourgia TCP sink agent ston komvo n3
set sink2 [new Agent/TCPSink] 
$ns attach-agent $n3 $sink2 
$ns connect $tcp2 $sink2 ;      #Syndesi TCP me to sink
$tcp2 set fid_ 3

########################


### Xrwmatismos rown - Erwtima (st) ###
$ns color 1 Red 
$ns color 2 Blue
$ns color 3 Green

##Events##
$ns at 0.1 "$cbr start"  
$ns at 0.5 "$ftp2 start"
$ns at 1.0 "$ftp start" 
$ns at 5.0 "finish" 
$ns run
