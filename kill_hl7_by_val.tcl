######################################################################
# Name:         kill_hl7_by_val
# Purpose:      KILL or CONTINUE a message based on a user defined content
# UPoC type:    tps
# Args:         tps keyedlist containing the following keys:
#               MODE    run mode ("start", "run" or "time")
#               MSGID   message handle
#               ARGS    user-supplied arguments:
#                       CMD        KEEP or KILL
#                       QUERY      HL7 Address to check
#                                   QUERY CONTEXT EXAMPLE PID.3.1.0.0
#                                        where:
#                                        3 is the field address part
#                                        1 is the repetition address part
#                                        0 is the component address part
#                                        0 is the subcomponent address part
#                       VALUE      Field number to check within the segment
#     
# 
#
#   There are two versions of the command that can be executed, one version KEEP will keep messages based on the value criteria passed in
#   the other version, KILL, will kill messages based on the entered criteria
#       EXAMPLE 1: THIS COMMAND WILL KEEP ALL MESSAGES THAT MEET THE FOLLOWING CONDITION IN MSH.9.0.1
#                   {CMD KEEP}  {QUERY MSH.9.0.1} {VALUE {A01 A02 A03 A04 A05 A06 A07 A08 A11 A12 A13 A14 A17 A28 A34 A35 } }
#       EXAMPLE 2: THIS COMMAND WILL KILL ALL MESSAGES THAT MEET THE FOLLOWING CONDITION IN MSH.9.0.1
#                   {CMD KILL}  {QUERY MSH.9.0.1} {VALUE {A20 A21 A22 A23 A24 A25 A26 A27 A28 A28 A30 A31 A32 A33 A34 A41 A45 A60} }
# Returns: tps disposition list:
#          KILL:  if field matches user defined literal
#          CONTINUE:  if field does not match user defined literal 
proc kill_hl7_by_val { args } {
    keylget args MODE mode                      ;# Fetch mode

    set dispList {}                             ;# Nothing to return

    switch -exact -- $mode {
        start {
            # Perform special init functions
            # N.B.: there may or may not be a MSGID key in args
        }

        run {
            # 'run' mode always has a MSGID; fetch and process it
            keylget args MSGID mh

            set msg [msgget $mh]                                ;# Get message
            set msgdata [msgget $mh]
            puts $msgdata            

#           
# Get arguments
           puts "****  Procedure Arguments \n\n" 
           keylget args ARGS.CMD msgCommand                   ;# Fetch the address to check for the kill
           puts "Command (CMD): $msgCommand"

           set query {}
           keylget args ARGS.QUERY msgQuery                   ;# Fetch the address to check for the kill
           puts "Message Address (QUERY): $msgQuery"
           #match condition variable parsed from message
           set values ""
           set killInd 0


           set valuetmp {}
           set msgValue {}
           keylget args ARGS.VALUE valuetmp
           set msgValue [split $valuetmp " "] 
           puts "Kill Condition(s) (VALUE): $msgValue"
           puts "\n\n**** End Procedure Arguments \n\n"           

           #FORMAT THE MESSAGE FOR EASY PARSING
           set msg [hl7 parse $msgdata]    
    
            #GET THE FIELD IN THE MSGQUERY LOCATION OF THIS MESSAGE
            set values [hl7 get values $msg $msgQuery]
            puts "VALUE FOUND IN MESSAGE AT $msgQuery: $values"

            #check to see if the value at the address location passed in is in the kill list passed in at the prompt
            set found [intersect $values $msgValue]
            puts "INTERSECT FOUND?? $found"

# set segment [eval $finalCmd]
#eval $finalCmd
            #set finalCmd ""
            
            if  [string equal $msgCommand "KEEP"]  {
                puts "---------- KEEP THIS MESSAGE IF IT IS IN THE LIST"
                if { [cequal $found {}] } {
                #puts "INTERSECT FOUND $found"
                puts "KEEPPPPP  this message because it is in the KEEP list $values "
                }
            } elseif [string equal $msgCommand "KILL"]  {
                puts "---------- KILL THIS MESSAGE IF IT IS IN THE LIST"
                if { ![cequal $found {}] } {
                #puts "INTERSECT FOUND $found"
                puts "KILL  this message because it is not in the KILL list $values "
                }
            }


            if {[cequal $killInd 1] } {
                echo "Kill Cond Match on this message: < $values >\n"
                lappend dispList "KILL $mh"
            } else {
                echo "NOT GOING TO Kill Cond Match on this message: < $values >\n"
                lappend dispList "CONTINUE $mh"
            }
            puts "END OF THE RUN IS HERE!!!! \n\n\n\n"
        } ;# end of 'run'

        time {
            # Timer-based processing
            # N.B.: there may or may not be a MSGID key in args
        }

        shutdown {
            #nothing to do
        }
    }

    return $dispList
}
