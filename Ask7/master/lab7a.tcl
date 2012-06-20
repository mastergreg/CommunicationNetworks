### Αρχείο προσομοίωσης για μελέτη επίδοσης πρωτοκόλλου δρομολόγησης Distance
### Vector (DV). Το σενάριο αποτελείται από 6 κόμβους συδεδεμένους με ζεύξεις
### διαφορετικού βάρους, όπως φαίνεται στην παρακάτω τοπολογία:


###          B--3--C         Στην προσομοίωση, ο κόμβος A ονομάζεται n(0), ο B n(1),
###       2/|      /|\5      ο C n(2), ο D n(3), ο E n(4) και ο F n(5).
###       / |     / | \
###      A   2   3   1   F
###       \ | /      | /     Ο κόμβος C στέλνει κίνηση CBR στον Α.
###       1\|/       |/2     Ο κόμβος F στέλνει κίνηση CBR στον D.
###          D--1--E


### Τα αποτελέσματα καταγράφονται στα αρχεία lab7a.nam (NAM) και lab7a.tr
### (trace file). Επιπλέον, τα αρχεία lab7a1.tr και lab7a2.tr περιγράφουν την
### κίνηση συναρτήσει του χρόνου (Xgraph).


# Δημιουργία αντικειμένου προσομοίωσης
set ns [new Simulator]


# Δημιουργία αρχείου NAM
set nf [open lab7a.nam w]
$ns namtrace-all $nf


# Δημιουργία αρχείου trace
set trf [open lab7a.tr w]
$ns trace-all $trf


# Διαδικασία τερματισμού
proc finish {} {
      global ns nf f1 f2 trf
      $ns flush-trace
      close $nf
      close $f1
      close $f2
      close $trf
      exit 0
}


# Ορισμός πρωτοκόλλου δρομολόγησης
Agent/rtProto/Direct set preference_ 200


                                                                                       4
$ns rtproto DV


# Δημιουργία κόμβων δικτύου
for {set i 0} {$i < 6} {incr i} {
      set n($i) [$ns node]
}


# Δημιουργία ζεύξεων και ορισμός κόστους
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
$ns duplex-link $n(4) $n(5) 1Mb 20ms DropTail
$ns cost $n(4) $n(5) 2
$ns cost $n(5) $n(4) 2


# Στρώμα Μεταφοράς, κόμβος n(2): πηγή, κόμβος n(0): προορισμός
set udp1 [new Agent/UDP]
$ns attach-agent $n(2) $udp1
$udp1 set fid_ 1
$ns color 1 red
set sink1 [new Agent/LossMonitor]
$ns attach-agent $n(0) $sink1


# Στρώμα Μεταφοράς, κόμβος n(5): πηγή, κόμβος n(3): προορισμός
set udp2 [new Agent/UDP]
$ns attach-agent $n(5) $udp2
$udp2 set fid_ 2
$ns color 2 blue
set sink2 [new Agent/LossMonitor]
$ns attach-agent $n(3) $sink2


# Σύνδεση των πηγών και των προορισμών
$ns connect $udp1 $sink1
$ns connect $udp2 $sink2


# Στρώμα εφαρμογής
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2


# Διαδικασία καταγραφής κίνησης
proc record {} {
     global sink1 sink2 f1 f2
     set ns [Simulator instance]
     # Ορισμός του χρόνου που η διαδικασία θα ξανακληθεί
     set time 0.1
     # Καταγραφή των byte
     set bw1 [$sink1 set bytes_]
     set bw2 [$sink2 set bytes_]
     # Λήψη της τρέχουσας ώρας
     set now [$ns now]
     # Υπολογισμός του bandwidth και καταγραφή αυτού
     puts $f1 "$now [expr (($bw1/$time)*8)/1000000]"
     puts $f2 "$now [expr (($bw2/$time)*8)/1000000]"
     # Θέτει τη μεταβλητή bytes ίση με 0
     $sink1 set bytes_ 0
     $sink2 set bytes_ 0
     # Επαναπρογραμματισμός της διαδικασίας
     $ns at [expr $now+$time] "record"
}


# Δημιουργία αρχείων για το Xgraph



set f1 [open lab7a1.tr w]
set f2 [open lab7a2.tr w]


# Ορισμός γεγονότων
$ns at 0.0 "record"
$ns at 0.3 "$cbr1 start"
$ns at 0.5 "$cbr2 start"
$ns at 2.5 "$cbr1 stop"
$ns at 2.5 "$cbr2 stop"
$ns at 3 "finish"
# Εκτέλεση προσομοίωσης
$ns run
