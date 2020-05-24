set val(chan) Channel/WirelessChannel  ;# type du canal
set val(prop) Propagation/TwoRayGround ;# modèle de radio-propagation
set val(netif) Phy/WirelessPhy         ;# type interface reseau
set val(mac) Mac/802_11                ;# type MAC
set val(ifq) Queue/DropTail/PriQueue   ;# interface queue type: file d attente
set val(ll) LL                         ;# type de couche liaison 
set val(ant) Antenna/OmniAntenna       ;# modele d antenne
set val(ifqlen) 50                     ;# paquet max dans ifq
set val(nn) 7                          ;# number of mobile nodes

set val(rp) DSDV                       ;# protocole de routage
#set val(rp) DSR                       ;

set val(x) 1000                        ;# dimensionde la topographie
set val(y) 1000                        ;# dimensionde la topographie

# initialiser les variables globales
set ns [new Simulator]
set tracefd [open sanet.tr w]
$ns trace-all $tracefd

set namtrace [open sanet.nam w]
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

#fichier Trace Debit
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set winfile1 [open WinFile1 w]
set winfile2 [open WinFile2 w]


#fichier queuesize
set queuesize [open QueueSize w]
#fichier Trace Paquet Perdus
set f2 [open lost0.tr w]
set f3 [open lost1.tr w]

#fichier Trace Retards
set f4 [open delay0.tr w]
set f5 [open delay1.tr w]

# set up topography object
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

# Creation des canaux
set chan_1 [new $val(chan)]
set chan_2 [new $val(chan)]

# configuration des noeuds
$ns node-config -adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-phyType $val(netif) \
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace ON \
	-macTrace ON \
	-movementTrace OFF \
	-channel $chan_1

set node0 [$ns node]
set node1 [$ns node]
set node2 [$ns node]
set node3 [$ns node]
set node4 [$ns node]
set node5 [$ns node]
set node6 [$ns node]

$node0 label "NewReno1"
$node1 label "Gateway 1"
$node2 label "Gateway 2"
$node3 label "Gateway 3"
$node4 label "NewReno2"
$node5 label "Vegas1"
$node6 label "Vegas2"

$node0 random-motion 0
$node1 random-motion 0


$ns initial_node_pos $node0 20
$ns initial_node_pos $node1 20
$ns initial_node_pos $node2 20
$ns initial_node_pos $node3 20
$ns initial_node_pos $node4 20
$ns initial_node_pos $node5 20
$ns initial_node_pos $node6 20




# Positions des noeuds
# NewReno 1
$node0 set X_ 50
$node0 set Y_ 300
$node0 set Z_ 0
#Gateway 1
$node1 set X_ 250
$node1 set Y_ 175
$node1 set Z_ 0
#Gateway 2
$node2 set X_ 450
$node2 set Y_ 175
$node2 set Z_ 0
#Gateway 3
$node3 set X_ 650
$node3 set Y_ 175
$node3 set Z_ 0
#Vegas 1
$node4 set X_ 850
$node4 set Y_ 300
$node4 set Z_ 0
#NewReno 2
$node5 set X_ 50
$node5 set Y_ 50
$node5 set Z_ 0
#Vegas 2
$node6 set X_ 850
$node6 set Y_ 50
$node6 set Z_ 0


#mouvement des noeuds
$ns at 0.0 "$node0 setdest 50.0 300.0 0.0"
$ns at 0.0 "$node1 setdest 250.0 175.0 0.0"
$ns at 0.0 "$node2 setdest 450.0 175.0 0.0"
$ns at 0.0 "$node3 setdest 650.0 175.0 0.0"
$ns at 0.0 "$node4 setdest 850.0 300.0 0.0"
$ns at 0.0 "$node5 setdest 50.0 50.0 0.0"
$ns at 0.0 "$node6 setdest 850.0 50.0 0.0"
 
# connections TCP
set tcp1 [new Agent/TCP/Newreno]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns attach-agent $node0 $tcp1
$ns attach-agent $node1 $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 3.0 "$ftp1 start"

set tcp2 [new Agent/TCP/Vegas]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns attach-agent $node5 $tcp2
$ns attach-agent $node6 $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns at 3.0 "$ftp2 start"

#$ns queue-limit $node(1) $node(2) 20
set holdtime0 0
set holdtime1 0

set holdseq0 0
set holdseq1 0

set holdrate0 0
set holdrate1 0

#procedure d enregistrement des statistiques

proc record {} {
	global sink1 sink2 f0 f1 f2 f3 f4 f5 holdtime0 holdtime1 holdseq0 holdseq1 holdrate0 holdrate1

	set ns [Simulator instance]
	set time 0.9

	set bw0 [$sink1 set bytes_]
	set bw1 [$sink2 set bytes_]

	#set bw2 [$sink1 set nlost_]
	#set bw3 [$sink2 set nlost_]

	#set bw4 [$sink1 set lastPktTime_]
	#set bw5 [$sink1 set npkts_]

	#set bw6 [$sink2 set lastPktTime_]
	#set bw7 [$sink2 set npkts_]

	set now [$ns now]

	#enregistrement Debit
	puts $f0 "$now [expr (($bw0+$holdrate0)*8)/(2*$time*1000000)]"
	puts $f1 "$now [expr (($bw1+$holdrate1)*8)/(2*$time*1000000)]"

	#enregistrement taux de perte
	#puts $f2 "$now [expr $bw2/$time]"
	#puts $f3 "$now [expr $bw3/$time]"

	#enregistrement des Retards
	#if {$bw5 > $holdseq0}{
	#	puts $f4"$now[expr($bw4-$holdtime0)/(bw5-$holdseq0)]"
	#} else {
	#	puts $f4"$now[expr($bw5-$holdseq0)]"
	#}
	#if {$bw7 >$holdseq1}{
	#	puts $f5"$now[expr($bw6-$holdtime1)/(bw7-$holdseq1)]"
	#} else {
	#	puts $f5"$now[expr($bw7-$holdseq1)]"
	#}
	#reinitilisation des variables
	$sink1 set bytes_ 0
	$sink2 set bytes_ 0
	#$sink1 set nlost_ 0
	#$sink2 set nlost_ 0
	#set holdtime0 $bw4
	#set holdseq0 $bw5
	set holdrate0 $bw0
	set holdrate1 $bw1
	$ns at [expr $now + $time] "record";
}
#proc queueLength {} {
#	global ns monitor
#	set time 0.1
#	set len [$monitor set pkts_]
#	set now [$ns now]
#	puts $file "$now $len"
#	$ns at [expr $now+$time] "queueLength 0 0 $queuesize"
#}
#set monitor [$ns monitor-queue $node1 $node2 stdout 0.1]
#$ns at 0.1 "queueLength"
# Tell nodes when the simulation ends 4

proc plotWindow {tcpSource file} {
	global ns
	set time 0.1
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]
	puts $file "$now $cwnd"
	$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp1 $winfile1"
$ns at 0.1 "plotWindow $tcp2 $winfile2"

$ns at 400.0 "$node0 reset";
$ns at 400.0 "$node1 reset";
$ns at 400.0 "$node2 reset";
$ns at 400.0 "$node3 reset";
$ns at 400.0 "$node4 reset";
$ns at 400.0 "$node5 reset";
$ns at 400.0 "$node6 reset";

$ns at 0.0 "record"
$ns at 400.0 "stop"
$ns at 400.01 "puts \"NS EXITING...\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace f0 f1 f2 f3 f4 f5

    close $f0
    close $f1
    close $f2
    close $f3
    close $f4
    close $f5

    exec xgraph out0.tr out1.tr -geometry 800x400 &

	exec nam sanet.nam &
    $ns flush-trace
    close $tracefd
    close $namtrace
    exit 0
}

puts "Starting Simulation... "
$ns run
