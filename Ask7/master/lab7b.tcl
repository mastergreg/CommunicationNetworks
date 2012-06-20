Παράρτημα Β – Κώδικας για την προσομοίωση του δεύτερου μέρους
### Αρχείο προσομοίωσης για μελέτη επίδοσης πρωτοκόλλου δρομολόγησης Distance
### Vector (DV). Το σενάριο αποτελείται από 4 κόμβους συδεδεμένους με ζεύξεις,
### όπως φαίνεται στην παρακάτω τοπολογία:


###     10Mbps
###    C-------D       Στην προσομοίωση, ο κόμβος A ονομάζεται n(0), ο B n(1),
###     \         /    ο C n(2) και ο D n(3).
###   10Mbps 10Mbps
###         \ /
###         B
###         /          Ο κόμβος C στέλνει κίνηση CBR στον Α.
###     /10Mbps        Ο κόμβος D στέλνει κίνηση CBR στον B.
###    A


### Τα αποτελέσματα καταγράφονται στα αρχεία lab7b.nam (NAM) και lab7b.tr
### (trace file). Επιπλέον, τα αρχεία lab7b1.tr και lab7b2.tr περιγράφουν την
### κίνηση συναρτήσει του χρόνου (Xgraph).


# Δημιουργία αντικειμένου προσομοίωσης
set ns [new Simulator]


# Δημιουργία αρχείου NAM
set nf [open lab7b.nam w]
$ns namtrace-all $nf


# Δημιουργία αρχείου trace
set trf [open lab7b.tr w]
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
$ns rtproto DV


# Δημιουργία κόμβων δικτύου
for {set i 0} {$i < 4} {incr i} {
      set n($i) [$ns node]
}


# Δημιουργία ζεύξεων
$ns duplex-link $n(0) $n(1) 1Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 1Mb 10ms DropTail
$ns duplex-link $n(1) $n(3) 1Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 1Mb 10ms DropTail


# Εμφάνιση ουράς αναμονής στο NAM
$ns duplex-link-op $n(2) $n(1) queuePos 0.5


# Στρώμα Μεταφοράς, κόμβος n(2): πηγή, κόμβος n(0): προορισμός
set udp1 [new Agent/UDP]
$ns attach-agent $n(2) $udp1
$udp1 set fid_ 1
$ns color 1 red
set sink1 [new Agent/LossMonitor]
$ns attach-agent $n(0) $sink1


# Στρώμα Μεταφοράς, κόμβος n(3): πηγή, κόμβος n(1): προορισμός
set udp2 [new Agent/UDP]
$ns attach-agent $n(3) $udp2
$udp2 set fid_ 2
$ns color 2 blue
set sink2 [new Agent/LossMonitor]
$ns attach-agent $n(1) $sink2


# Σύνδεση των πηγών και των προορισμών
$ns connect $udp1 $sink1
$ns connect $udp2 $sink2


# Στρώμα εφαρμογής
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 600
$cbr1 set interval_ 0.005


set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set packetSize_ 600
$cbr2 set interval_ 0.005


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
set f1 [open lab7b1.tr w]
set f2 [open lab7b2.tr w]


# Ορισμός γεγονότων
$ns at 0.0 "record"
$ns at 0.3 "$cbr1 start"
$ns at 0.3 "$cbr2 start"
$ns at 2.9 "$cbr1 stop"
$ns at 2.9 "$cbr2 stop"
$ns at 3 "finish"


# Διακοπή ζεύξης n(0)-n(1)
$ns rtmodel-at 1.0 down $n(0) $n(1)


# Επαναφορά ζεύξης n(0)-n(1)
$ns rtmodel-at 2.0 up $n(0) $n(1)


# Εκτέλεση προσομοίωσης
$ns run


