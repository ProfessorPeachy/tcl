#!/usr/bin/env tclsh

#source keep_hl7_field.tcl

# TWO VERSIONS , KEEP OR DELETE
# BE CAREFUL WITH THIS, IT COULD CHANGE THE DATA STRUCTURE OF THE SEGMENT.
# IF YOU DELETE AN ELEMENT, IS IT ESSENTIALLY A POP, AND THE SIZE OF THE DATA STRUCTURES
# AS WELL AS THE ORDERING OF THE DATA WILL CHANGE 
# TRY TO DELETE BASED ON A RANGE, UNLESS IT IS THE LAST ELEMENT IN THE SEGMENT
# SYNTAX 
# CMD {KEEP} QUERY {RANGE OF FIELDS TO KEEP IN SEGMENT}   CMD {KEEP} QUERY {RANGE OF FIELDS TO DELETE FROM SEGMENT}
# SINCE THIS IS AT THE FIELD LEVEL, YOU DO NOT HAVE TO ADDRESS THE QUERY ALL THE WAY OUT PAST THE FIELD LEVEL
# IF YOU DO, THIS PROCEDURE MIGHT NOT WORK
# CMD {KEEP} QUERY {PV2.0-8}  EQUIVALENT  TO  CMD {DELETE} QUERY {PV2.9-25}
# CMD {KEEP} QUERY {DG1.0-1}  EQUIVALENT  TO  CMD {DELETE} QUERY {DG1.2-26}

# VERSION   DEVELOPER              DATE                                 PURPOSE
# 001       AMELIA JAMISON         01/21/2017                           CREATE PROCEDURE TO DELETE A RANGE OF FIELDS 

proc delete_hl7_field { args } {
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
    set field_list {}
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
            set query_list {}
            
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
                    COND {
                            set setValueFlag 0
                            set msgCondition $value
                            puts "msgCondition $msgCondition\n"
                        }                                     
                    QUERY {
                            if { [string equal $msgCondition ""] } { set setValueFlag 1 } else {  set setValueFlag 0  }                                     
                            set msgQuery $value
                            puts "msgQuery $msgQuery\n"
                            set field_list [lindex $value end]
                            puts "field_list -->$field_list"
                            set query_list [split $msgQuery " "]
                            puts "query_list ->$query_list size: [llength $query_list]"
                            
                        } 
                    VALUE {
                            set setValueFlag 1                  
                            set msgValue $value
                            puts "msgValue $msgValue\n"
                            set field_list [split $msgValue "-"]
                            set list_size [llength $field_list]
                        }           
                    default { puts "no command set for entered parameters please set up the feature to catch this argument key value $key"}
                }
                set field_address ".0.0.0.0"
                set keep_list {}
                                  
                #puts "SET VALUE FLAG $setValueFlag"        
                if {$setValueFlag == 1} {
                    set seg_id [crange $msgQuery 0 2]
                    #set keep_address [crange $msgQuery 3 end]
                    #set field_address ".0.*.0.0"
                    #puts "KEEP seg_id $seg_id"
                   
                    
                    set keep_address [hl7 query $msg $msgQuery]
                    #puts "KEEP_ADDRESS $keep_address"
                    #puts "msg Query being set"
                    set msgQuery [concat $seg_id$field_address]
                    set expQuery [concat $seg_id.*.0.0]
                    set qlength [llength $query_list]
  
                        #puts "$qlength is not greater than 1"
                        #puts "expQuery $expQuery"
                        # GET THE LIST OF ADDRESSES TO KEEP by expanding the query 
                        foreach result [hl7 get reversed $msg $expQuery 1] {
                            # remove Z segments
                            set address [lindex $result 1]
                            #puts "keeping these address $keep_address"
                            #puts "checking this address $address"
                            set segment_address [lindex [split $address "."] 0]
                            set field_address [lindex [split $address "."] 1]
                            #puts "segment_address $segment_address"
                            #puts "field_address $field_address"
                            set check_address [concat $segment_address.$field_address]
                               
                            #puts "-- keep result $check_address if it is a keep_address $keep_address"
                            set segment_type $seg_id
    
                            #keep this segment it it is a keep address
                            set found [intersect $keep_address $check_address]
                            #puts "found  $found "
    
                            set msgQuery [concat $seg_id.$field_address]
    
    
                            #DO THIS ONLY IF THERE IS A MESSAGE CONDITION ON THE COMMAND
                            if { ![string equal $msgCondition "" ]} {
                                set values [hl7 get values $msg $msgQuery]
                                if { [string equal $msgCondition "ISBLANK" ]} {
                                            #puts "these are equal -->$msgCondition"
                                            set msgCondition "{}"
                                }                            
                                if [string equal $values $msgCondition] {
                                        #puts "match found"
                                        #puts "DELETING IFCOND since the value at $msgQuery to $msgValue since it contains the value: $msgCondition"
                                        #puts "delete the hl7 for this command"
                                        set values [hl7 get values $msg $msgQuery]
                                        #puts "field will now be deleted from location $msgQuery"
                                        set msg [hl7 delete $msg $msgQuery]
                                        #puts "----message AFTER removing this piece  of the message \n $msg" 
                                } else {continue}  
                            } 
    
                            set values [hl7 get values $msg $msgQuery]
                            #puts "CHECKING THE CURRENT VALUES\n $values"
                            #puts "msgCommand: $msgCmd $msgQuery"
                            if  [string equal $msgCmd "KEEP"]  {
                                
                                if { [cequal $found ""] } { 
                                    set msg [hl7 delete $msg $msgQuery]  
                                    puts "---------- DELETINGTHIS FIELD SINCE IT WAS NOT FOUND IN THE KEEP LIST $msgQuery"
                                } 
                            } elseif [string equal $msgCmd "DELETE"]  {
                                
                                 if { ![cequal $found ""] } { 
                                    set msg [hl7 delete $msg $msgQuery]  
                                    puts "---------- DELETINGTHIS FIELD SINCE IT WAS FOUND IN THE DELETE LIST $msgQuery"
                                    #puts "tHIS FIELD SHOLD AHVE BEEN DELETED $msgQuery"
                                 } 
                            }
                              
                        } ;#end foreach result
                    puts "!!!!!!!!!!!!!!! END THE KEEP FOR LOOP"
                    puts "------- msgCmd $msgCmd " 
                    #"<msg> $msgQuery $msgValue"
                    #set segment
                    
                        set setValueFlag 0    
                                 
                    }    ;#END IF SETVALUEFLAG TEST
                     
                    puts "TESTING TESTING 123"                                                          
                    #RUN THIS COMMAND ON THE MESSAGE
                    #eval $finalCmd
                    
                
            }        
                      

            puts "MESAGE ----------- \n $msg"
         
            set msg [hl7 data $msg]
            
            set msg [string trimright $msg "\r"]
           # set msg [string trimright $msg "\|"]
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
