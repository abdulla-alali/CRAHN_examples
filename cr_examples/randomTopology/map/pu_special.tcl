# Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# simple-wireless.tcl
# A simple example for wireless simulation

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             20                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol

set val(seed)		[lindex $argv 0]
set val(alpha)		[lindex $argv 1]
set val(beta)		[lindex $argv 2]
set val(nnPU)		[lindex $argv 3]



# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open simple.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 2000 2000

#
# Create God
#
create-god $val(nn)


set chan_0_ [new $val(chan)]
set chan_1_ [new $val(chan)]

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node

       

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
#$ns_ at 50.0 "$node_(1) setdest 25.0 20.0 15.0"
#$ns_ at 10.0 "$node_(0) setdest 20.0 18.0 1.0"

# Node_(1) then starts to move away from node_(0)
#$ns_ at 100.0 "$node_(1) setdest 490.0 480.0 15.0" 

# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)

puts $val(nnPU)



set rng [new RNG]
$rng seed $val(seed)


set anglePU [new RandomVariable/Uniform]
$anglePU set min_ 0
$anglePU set max_ 360
$anglePU use-rng $rng


set radiusPU [new RandomVariable/Uniform]
$radiusPU set min_ 0
$radiusPU set max_ 300
$radiusPU use-rng $rng

set position [new RandomVariable/Uniform]
$position set min_ 0
$position set max_ 1000
$position use-rng $rng


set channel [new RandomVariable/Uniform]
$channel set min_ 1
$channel set max_ 11
$channel use-rng $rng



for {set i 0} {$i<$val(nnPU) } {incr i }  {

		
	
	set radius [$radiusPU value]
	set angle [$anglePU value]	

	set xPU [$position value]
	set yPU [$position value]

	
	set xPU_r [expr cos($angle) * $radius + $xPU]
	set yPU_r [expr sin($angle) * $radius + $yPU]
			
	set ch [$channel value]
	set ch [expr int($ch)]			
		
	puts "$ch $xPU $yPU $xPU_r $yPU_r $val(alpha) $val(beta) 500"
}





	
set rng [new RNG]
$rng seed $val(seed)

set alphaV(0) [new RandomVariable/Exponential]
$alphaV(0) set avg_ [expr 1/$val(alpha)]
set betaV(0) [new RandomVariable/Exponential]
$betaV(0) set avg_ [expr 1/$val(beta)]
$alphaV(0) use-rng $rng
$betaV(0) use-rng $rng


for {set k 0} { $k < $val(nnPU)  } {incr k} {
	
	set counter 0
	set time 0
	set endTime 205
	

	set m 0
	#set m 0

	for {set j 0} { $j<25} {incr j} { 
	    set on [$alphaV($m) value]
	    set off [$betaV($m) value]
	} 

	for {} { $time < $endTime } {} {
	    set on [$alphaV($m) value]
	   # puts $on
	    set off [$betaV($m) value]
	   # puts $off
	    set time [expr $time + $off ]
	    set arrival($counter) $time
	    set time [expr $time + $on ]
	    set departure($counter) $time
	    set counter [expr $counter + 1]
	}

		
	
	puts $counter
	for {set i 0} { $i < $counter } {incr i} {
	 
		puts $arrival($i)
		puts $departure($i)
	}

}
	




#
# Tell nodes when the simulation ends
#

#$ns_ at 150.0 "stop"
#$ns_ at 150.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

#puts "Starting Simulation..."
$ns_ run

