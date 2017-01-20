#!/usr/bin/env tclsh

# source the TclHL7 library
#source decodel_hl7.tcl


# syntax for hl7 functions for hl7.tcl
# hl7 query <msg> <query> [<expand>] [<reverse>]
# hl7 parse <msgdata> [<segment_separator>]
# hl7 data <msg>
# hl7 get <msg> <query> [<reverse>] [<expand>]
# hl7 set <msg> <query> <value> [<expand>]
# hl7 clear <msg> <query>
# hl7 delete <msg> <query>
# hl7 add <msg> <query> <value> [<expand>]
# hl7 insert <msg> <query> <value1> [<value2> ... <valueN>] This form inserts the value(s) at the address indicated by query.
# hl7 insert before <msg> <query> <value> [<value2> ... <valueN>] This form acts just like the first form.
# hl7 insert after <msg> <query> <value> [<value2> ... <valueN>]: This form inserts the value(s) after the address indicated by query
#CMD {SET} QUERY {MSH.5} VALUE {CERNER}
#CMD {DELETE} QUERY {MSH.9.0.2}
#CMD {DELETE} QUERY {PID.3.*.1-10}
#CMD {DELETE} QUERY {EVN.7.*.2}
#CMD {DELETE}  QUERY {PV1.7.*.4-12}
##CMD {DELETE}  QUERY {PV1.8.*.4-12}
#CMD {DELETE}  QUERY {PV1.9.*.4-12}
#CMD {DELETE}  QUERY {PV1.17.*.4-12}
#CMD {DELETE}  QUERY {PV1.7.*.3}  IFCOND {ISBLANK} 
#CMD {DELETE}  QUERY {PV1.8.*.3} IFCOND {ISBLANK} 
#CMD {DELETE}  QUERY {PV1.9.*.3} IFCOND {ISBLANK} 
#CMD {DELETE}  QUERY {PV1.17.*.3} IFCOND {ISBLANK} 
#CMD {DELETE} QUERY {PV2.9-49.0}
#CMD {DELETE} QUERY {DG1.1-26.0}


proc update_hl72 { args } {
    set filename "/pwim/cis6.1/integrator/test/tclprocs/hl7.tcl"
    source $filename
    global HciConnName
    
    keylget args MODE mode         ;# Fetch mode
       
    set uargs {} ;   
    keylget args ARGS uargs

   set argCount 0
   
    foreach {key value} $uargs { ;# TCL 8.4
        incr argCount
        puts "argCoung $argCount"
        puts "key $key value $value"
    }
    keylget args MODE mode                        ;# Fetch mode
    set dispList {}                               ;# Nothing to return

    switch -exact -- $mode {
        start     {
                # Perform special init functions
                }

        run    {
            # 'run' mode always has a MSGID; fetch and process it
            keylget args MSGID mh

            puts "args  $args"
            puts "msgid MSGID" 
            # Here we retrieve the data from our original message
            set msgdata [msgget $mh]
            puts $msgdata
            puts "#Parse the message and take out special characters\n"
            puts "****  Procedure Arguments \n\n" 

            set values ""
            #set killInd 0
           
            #puts "Message Value $msgValue"
            puts "\n\n**** End Procedure Arguments \n\n"                      

            set msgCmd ""
            set msgQuery ""
            set msgValue ""
            set msgDest ""
            set msgCondition ""
            
            set msg [hl7 parse $msgdata]    

            foreach {key value} $uargs { ;# TCL 8.4
                puts "key value $key: $value" 
                switch $key {
                    CMD {
                        set setValueFlag 0                   
                        #set msgCmd [string tolower $value]
                        puts "VALUE---> $value"
                        puts "before msgCmd $msgCmd\n"  
                        set msgCmd $value
                        puts "msgCmd $msgCmd\n"  
                        }
                    IFCOND {
                        if { ![string equal $msgCmd "DELETE" ] } {
                            set setValueFlag 0                   
                        } else {
                            set setValueFlag 1
                        }
                        set msgCondition $value                   
                        puts "msgCondition $msgCondition\n"
                        }                                     
                    QUERY {
                        set setValueFlag 0                   
                        set msgQuery $value

                        if { [string equal $msgCmd "DELETE" ] || [string equal $msgCmd "CLEAR" ] } {
                                set setValueFlag 1
                        } 
                        puts "msgQuery $msgQuery\n"
                        } 
                    VALUE {
                        set setValueFlag 1                  
                        set msgValue $value
                        puts "msgValue $msgValue\n"
                        }           
                    default { puts "no command set for entered parameters please set up the feature to catch this argument key value $key"}
                }
                                  
            puts "SET VALUE FLAG $setValueFlag"        
                if {$setValueFlag == 1} {
                    puts "------- msgCmd $msgCmd " 
                    #"<msg> $msgQuery $msgValue"
                    #set segment
                    switch $msgCmd {
                        SET { 
                                    if { $argCount >= 3 } {
                                        #get the value in the address                                        
                                        if { ![string equal $msgCondition "" ] } {
                                            set values [hl7 get values $msg $msgQuery]
                                            if [string equal $values $msgCondition] {
                                                puts "setting the value at $msgQuery to $msgValue since it contains the value: $msgCondition"
                                                set msg [hl7 set $msg $msgQuery $msgValue] 
                                            } else {continue}                                                                                           
                                        } else {
                                            set msg [hl7 set $msg $msgQuery $msgValue] 
                                        }                                         
                                        puts "Setting $msgQuery to a new value of $msgValue"    
                                    }                                                                 
                                }
                        GETSET {
                                      #get a value a a location
                                      set values [hl7 get values $msg $msgQuery]
                                      puts "Just got the data from passed in address:  $values "   
                                      #forget set, the value is an address passed in by user not text.
                                      puts "for getset, the value holds the place where the get data will be copied to"
                                      set msg [hl7 set $msg $msgValue $values]                                          
                        }                               
                        CLEAR {  
                                   puts "Clear the identifiers in the location $msgQuery"
                                   set values [hl7 get values $msg $msgQuery]
                                   puts "$values will now be cleared from location $msgQuery"
                                   # clear out the identifiers in PID.2
                                   #set msg [hl7 clear $msg PID.2]                                                    
                                   set msg [hl7 clear $msg $msgQuery]
                        }
                        CONCATA {  
                                   puts "Append to the beginning of this item, can't append to subcomponents or segments"
                                    #get the value that will be appended
                                    set values [hl7 get values $msg $msgQuery]
                                    puts "Value that will be appended:  $values at $msgQuery"
                                    #set the value 
                                    set msgValue [concat $values$msgValue]
                                    puts "New msgValue $msgValue"
                                    set msg [hl7 set $msg $msgQuery $msgValue]
                        }                                        
    
                        CONCATB {  
                                   puts "Append to the end of this item, can't append to subcomponents or segments"
                                    # add an identifier repetition to PID.3
    
                                    #get the value that will be appended
                                    set values [hl7 get values $msg $msgQuery]
                                    puts "Value that will be appended:  $values at $msgQuery"                                            
                                    #set the value 
                                    set msgValue [concat $msgValue$values]
                                    puts "New msgValue $msgValue"
                                    set msg [hl7 set $msg $msgQuery $msgValue]
                        }
                        INSERTA {  
                                   puts "insert something after the value, THIS CREATES A NEW SPOT"
                                   set msg [hl7 insert after $msg $msgQuery $msgValue]  
                        } 
                        INSERTB {  
                                   puts "insert something before the value THIS CREATES A NEW SPOT"     
                                   #set msg [hl7 insert after $msg PID.3.0 $id]          
                                   set msg [hl7 insert before $msg $msgQuery $msgValue]                            
                        }
                        DELETE   {

                                    if { [string equal $msgCondition ""]} {
                                        puts "delete the hl7 field for this command WITH NO CONDITIONS"
                                        set values [hl7 get values $msg $msgQuery]
                                        puts "field will now be cleared from location $msgQuery"
                                        set msg [hl7 delete $msg $msgQuery]
                                        puts "----message AFTER removing this piece  of the message \n $msg"                                    
                                    } else {
                                        #get the value in the address                                        
                                            puts "CONDITIONAL DELETE: checking to see if the argument passed in matches the value in this hl7 location"
                                            #check to see if we are checking for a blank in order to delete
                                            #puts "msgCondition before $msgCondition"
                                            #set blankCondition "ISBLANK"
                                            #puts "msgCondition before $msgCondition" 
                                            #puts "blankCondition $blankCondition" 

                                            if { [string equal $msgCondition "ISBLANK" ]} {
                                                puts "these are equal"
                                                set msgCondition "{}"
                                            } 
                                              
                                            #puts "msgCondition after $msgCondition"
                                            set values [hl7 get values $msg $msgQuery]
                                            #puts "does msg condition match the value ->$values<- VS ->$msgCondition<-" 
                                            if [string equal $values $msgCondition] {
                                                #puts "match found"
                                                puts "DELETING IFCOND since the value at $msgQuery to $msgValue since it contains the value: $msgCondition"
                                                #puts "delete the hl7 for this command"
                                                set values [hl7 get values $msg $msgQuery]
                                                #puts "field will now be deleted from location $msgQuery"
                                                set msg [hl7 delete $msg $msgQuery]
                                                #puts "----message AFTER removing this piece  of the message \n $msg" 
                                            } else {continue}                                                 
                                    }
                                    puts "Deleting $msgQuery to a new value of $msgValue"    

                                
                        }
    
                        DEFAULT { 
                                puts "no command set for entered parameters please set up the feature to catch this command $msgCmd" 
                                break
                        }
                        
                    }    
                    set setValueFlag 0     
                    puts "TESTING TESTING 123"                                                          
                    #RUN THIS COMMAND ON THE MESSAGE
                    #eval $finalCmd
                    
                
                }
            }           
                      

            puts "MESAGE ----------- \n $msg"
         
            set msg [hl7 data $msg]
            set msg [string trimright $msg "\r"]
            set msg "$msg\r"
            msgset $mh $msg
            #puts "displist before: $dispList\n\n\n"            
            lappend dispList "CONTINUE $mh"
            puts "end of run" 
        }           ;# End of RUN

        time {
            # Timer-based processing
            # N.B.: there may or may not be a MSGID key in args
        }

      shutdown {
        echo "upd_hl7 is shutting down"
      }

      default {
         error "Unknown mode '$mode' in upd_hl7"
        }
    }

    return $dispList
}
