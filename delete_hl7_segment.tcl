######################################################################
# Name:     rem_hl7_segment
#
# Author:   Chris Hale
#
# Date:     
# 1999.03.10 Chris Hale
#          - wrote intitial version           
#
# 1999.05.24 Russ Ross
#          - fixed to not have memory leaks when creating new message
#
# Purpose:  Removes a segment(s) within a message.
# UPoC type:   tps
# Args:  tps keyedlist containing the following keys:
#        MODE    run mode ("start", "run" or "time")
#        MSGID   message handle
#        ARGS    user-supplied arguments:
#               CMD - KEEP OR REMOVE
#               VALUE - Segments that you wish to have removed.
#            {CMD KEEP} {VALUE {SE1 SE2 SE3 SE4}}
#            {CMD REMOVE} {VALUE {SE1 SE2 SE3 SE4}}
#           The segments should have spaces between each segments as you like.  
#           EXAMPLES:  Please decide which version will be faster before choosing KEEP/REMOVE.  If 
#  This first "REMOVE" version of the command removes many sgements, it is a long list in this example.
# {CMD REMOVE} {VALUE {ZVN ZPD LAN PD1 ZDU ROL CON NTE NK1 IAM AL1 NPU ROL ZPV ZIF OBX NTE ZFL PR1 GT1 ZG1 NTE IN1 IN2 IN3 ZIN ACC FT1 ZFT UB2 ZDT ZMP ZPE ZID ZRQ ZLN ZCM}}
# Since you only want to keep a few segments, it might be better to do the "KEEP" ersion of the command since this will be faster. 
#{CMD KEEP} {VALUE {SEGMENTS MSH EVN PID MRG PV1 PV2 DG1}}
# {VALUE {A20 A21 A22 A23 A24 A25 A26 A27 A28 A28 A30 A31 A32 A33 A34 A41 A45 A60} }
#
# Returns: tps disposition list:
#    CONTINUE - original message will be overwritten
#               with new messages that has the specified
#               segments removed

proc delete_hl7_segment { args } {
   keylget args MODE mode                 ;# Fetch mode

   
    puts "****  Procedure Arguments \n\n" 
    keylget args ARGS.CMD msgCommand                   ;# Fetch the address to check for the kill
    puts "Command (CMD): $msgCommand"
   
    keylget args ARGS.SEGMENTS segments

    set valuetmp {}
    set segname_list {}
    set msgValue {}
    keylget args ARGS.VALUE valuetmp
    set msgValue [split $valuetmp " "] 
    set segname_list  [split $valuetmp " "] 
    puts "Command Condition(s) $msgCommand the following: $msgValue"
    puts "\n\n**** End Procedure Arguments \n\n"    

   

   set dispList {}            ;# Nothing to return

   switch -exact -- $mode {
   
      start {
         return ""
      }

      run {
        puts "DELETING HL7 SEGMENTS IF NEEDED"
        
         # 'run' mode always has a MSGID; fetch and process it
         keylget args MSGID mh

         # Initialize variables
        # set segname_list {}
         set index1 0
         set index2 2 
         set count 1
         set new_msg {}

        # set segname_list2 {}
       #  set seg_list [split $msg " "] 

         # Determine number of segments that you want to have eliminated 
         # and put them in list format
        # set arg_length [clength $segments]
        # set num_segments [expr $arg_length/3]
        # while {$count <= $num_segments} {
        #    lappend segname_list [crange $segments $index1 $index2]
         #   incr count
        #    incr index1 3
        #    incr index2 3
        # }
        echo $msgCommand SEGMENTS ($segname_list)
          #  puts "end while"
         # Retrieve the message and create a new message that 
         # contains only the segments that are wanted.
         set msg [msgget $mh]
         #puts "msg \n $msg"
         #the line feed did not work so I used the \n instead

#regsub -all -- {\",\"} $msg {"|"} msg  
        # regsub -all -- {\n} $msg {\r} msg  
         
         set seg_list [split $msg \r] 
         #set seg_list [split $msg "MSH\|" ]
         #try [regsub -all \[\r\n] $string " " string]
         #puts "SEGMENT LIST"

        #puts "seg_list\n $seg_list"

            
        #puts "\n\n end seg_list"
         echo BEGIN FOREACH
         foreach item $seg_list {
            echo "ITEM: $item"
            puts "\n\n item: $item\n"
            echo ITEM $item
            #if {[cequal $item {}]} {puts "cequal item $item is blank"}
            if {[string equal $item {}]} continue
            set seg_id [crange $item 0 2]
            set found_list [intersect $segname_list $seg_id]
            puts "arguments-->  $segname_list hl7 --> $seg_id"

            if  [string equal $msgCommand "REMOVE"]  {
                if { [string equal $found_list {}]} {
                   append new_msg $item \r
                   echo NEW ITEM APPENDED TO NEW MSG $new_msg
                   puts "SET FOR REMOVAL $item"
                   }
            } elseif [string equal $msgCommand "KEEP"]  {
                if { ![string equal $found_list {}]} {
                   append new_msg $item \r
                   echo NEW ITEM APPENDED TO NEW MSG $new_msg
                   puts "SET TO KEEP $item"
                   }
            } else {
              error "You did not enter a valid paramter keys for the segments to keep must be CMD KEEP or CMD DELETE" 
                   }
         }      
         puts "end of the items to append"   
        echo NEW MESSAGE $new_msg
        # puts "end foreach"

         #   set msg "$msg\r"
        #    msgset $mh $msg  
         puts "new msg BEFORE CARRIAGE RETURN $new_msg"
         echo NEW MESSAGE BEFORE THE CARRIAGE RETURN SINCE IT HAD TO BE ADDED
         echo $new_msg
         set $new_msg "new_msg\r"    
         puts "new msg AFTER CARRIAGE RETURN $new_msg"
        echo NEW MESSAGE AFTER
         echo $new_msg
       
         msgset $mh $new_msg
         echo NEW MESSAGE HANDLE $mh
         lappend dispList "CONTINUE $mh"
      }

      time {
         # Timer-based processing
         # N.B.: there may or may not be a MSGID key in args
      }

        shutdown {
            # Doing some clean-up work
        }

      default {
         error "Unknown mode '$mode' in tps_remove_segment"
      }
   }

    return $dispList
}
