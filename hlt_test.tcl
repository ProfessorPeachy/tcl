########################################################################
# Name:         HL7_test.tcl 
# Purpose:
#               uSE TO TEST HL7 PROCEDURES
#
# UPoC type: Pre Xlate 
# Args:         tps keyedlist containing the following keys:
#               MODE    run mode ("start", "run" or "time"
#               MSGID   message handle
#               ARGS    user-supplied arguments:
#               #
# Returns: tps disposition list:
#          CONTINUE - Message was processed normally - continue into engine.
#          ERROR - Message processing failed - put message into the error database.
#
#

proc hl7_test { args } {
    
    set filename "/pwim/cis6.1/integrator/test/tclprocs/hl7.tcl"
    source $filename
    
    global HciConnName

    keylget args MODE mode         ;# Fetch mode
    keylget args CONTEXT context   ;# Fetch context

    
    if { ! [info exists HciConnName] } {

        set HciConnName "UNKNOWN_TD"

    }

    set dispList {}                             ;# Nothing to return

    switch -exact -- $mode {
        start {
            # Perform special init functions
            # N.B.: there may or may not be a MSGID key in args
        }

        run {
            keylget args MSGID mh               ;# Fetch the MSGID
    
        
            # Retrieve the Patient Type from the message PID and MRG Segment.

            #set msg [msgget $mh]                  ;# Get the Message Handle
            set msgdata [msgget $mh]


                 keylget args MSGID mh
                 keylget args OBMSGID ob_mh
                 lappend dispList "CONTINUE $mh"


            puts ""
            puts ""
            puts "msgdata \n $msgdata"

            puts "mh \n $mh"
            
            set msg [hl7 parse $msgdata]   
            set id 12345
            #set msg [hl7 data $msg]

        puts "data"
        puts "hl7 data <msg>"

puts "Arguments:"
    puts "msg: The parsed HL7 message that is being converted to raw data."
puts "Example Usage:"


#set msg [hl7 parse $msgdata]  

puts "TEST AMELIA AREA \n\n\n"

puts "get the value and addresses of a specific segment"
set thisMessage [hl7 get $msg MSH]
puts "thisMessage $thisMessage"
set thisMessage [hl7 get $msg MSH.5]
puts "thisMessage2 $thisMessage"
set thisMessage [hl7 get $msg MSH.8]
puts "thisMessage3 $thisMessage"

puts "get the address  of a specific segment"
set thisMessage [hl7 query $msg MSH]
puts "thisMessage $thisMessage"
set thisMessage [hl7 query $msg MSH.5]
puts "thisMessage2 $thisMessage"
set thisMessage [hl7 query $msg MSH.8]
puts "thisMessage3 $thisMessage"

set values [hl7 get values $msg MSH.9.*]
puts "values MSH.9.* $values"
set values [hl7 get values $msg MSH.9.0]
puts "values MSH.9.0  $values"

set values [hl7 get values $msg MSH.9.0.1]
puts "values MSH.9.0.1  $values"


#set msg [hl7 delete $msg MSH..1]


puts "END AMELIA TEST AREA \n\n\n\n\n"

puts " Parse the message"
puts "set msg [hl7 parse $msgdata]"
set msg [hl7 parse $msgdata]

puts "Modify the message"
puts "set msg [hl7 set $msg MSH.3.0.0.0 'SENDAPP']"
set msg [hl7 set $msg MSH.3.0.0.0 "SEND APP"]
puts "\n\n\nmessage --------------> $msg\n\n\n"


puts "Get the data of the message"
puts "set msgdata [hl7 data $msg]"
set $msg [hl7 data $msg]


set msg [hl7 parse $msgdata]   
        puts "query"
        
        puts "This proc takes a parsed message and a query address, and it returns a list of all matching static addresses. See Static Addresses above."
        
        puts "Usage:"
        #
        puts "hl7 query <msg> <query> expand reverse"
        #
        #Arguments:
        #    msg: This is the parsed message being queried against.
        #    query: This is the query being run against the given message.
        #    expand (optional):
        #        - Default: 0
        #        - Set this argument to `1` to return addresses that match repetitions, components, or subcomponents that do not exist.
        #        - For example, if a field on has one repetition, by default, a query addressing the third repetition would not be returned.  By setting `expand` to `1`, the "invisible" repetition's address would be returned.
        #        - This argument does not affect segments or fields.  Segments are never expanded, fields are always expanded.
        #    reverse (optional):
        #        - Default: 0
        #        - By default, the `query` command returns a sorted list of static addresses, with the addresses in the order that you would find them as you move from the start of the message to the end.  By settting this to `1`, you will get a reverse-sorted list of addresses.
        #        - This is useful for when you are performing destructive actions on a message (such as removing segments, repetitions, etc
        #Example Usage:
        
        puts "Assume that 'msg' contains a parsed HL7 message"
        puts "addresses hl7 query msg PID.3.*.0.0"
        set addresses [hl7 query $msg "PID.3.*.0.0"]
        puts "addresses $addresses"
        
        puts "reverse the results"
        puts "set reversed_addresses hl7 query msg PID.3.*.0.0 0 1"
        set reversed_addresses [hl7 query $msg "PID.3.*.0.0" 0 1]
        puts "addresses $addresses"
        
        puts "expand to the 3rd repetition, even if it's not present"
        puts "set expanded_addresses hl7 query msg PID.3.2.0.0 1"
        set expanded_addresses [hl7 query $msg "PID.3.2.0.0" 1]
        puts "addresses $addresses"
        
        puts "# both expand and reverse the results"
        # both expand and reverse the results
        puts "set expanded_reversed_addresses hl7 query msg 'PID.3.*.4.0' 1 1"
        set expanded_reversed_addresses [hl7 query $msg "PID.3.*.4.0" 1 1]
        puts "addresses $addresses"
        
        puts "get"
        puts "This proc is used to actually pull data out of an HL7 message. It always returns a list of matches."
        #This proc is used to actually pull data out of an HL7 message. It always returns a list of matches.
        #By default, this proc returns a list of value-address pairs. The value is the value of the matched item, and the address is the static address of the matched item. This allows you analyze the value and then issue subsequent modification commands on item's static address. There is a form of the get command that returns a list of matched values, not a list of matched value-address pairs. If you need just the matched addresses, you can use the query command.
        puts "Usage:"
        
        # standard usage
        puts "hl7 get <msg> <query> <reverse> <expand>"
        
        #Arguments:
        #    msg: The message being queried against.
        #    query: The query indicating the items to be matched.
        #    reverse (optional):
        #        - Default: 0
        #        - If set to `1`, the command reverses the results.
        #        - See the comments on reversing for the `query` command.
        #    expand (optional):
        #        - Default: 0
        #        - This is passed to the `query` command.  If a queried item does not exist and the `query` call returns an address for the missing item, the value is set to a blank string ("".
        #        - See the comments on expanding for the `query` command.
        
        puts "reverse the results"
        puts "hl7 get reversed <msg> <query> <expand>"
        #    msg: The message being queried against.
        #    query: The query indicating the items to be matched.
        #    expand (optional):
        #        - Default: 0
        #        - This is passed to the `query` command.  If a queried item does not exist and the `query` call returns an address for the missing item, the value is set to a blank string ("".
        #        - See the comments on expanding for the `query` command.
        
        puts " return only matching values"
        puts "hl7 get values <msg> <query> <reverse> <expand>"
        #    msg: The message being queried against.
        #    query: The query indicating the items to be matched.
        #    reverse (optional):
        #        - Default: 0
        #        - If set to `1`, the command reverses the results.
        #        - See the comments on reversing for the `query` command.
        #    expand (optional):
        #        - Default: 0
        #        - This is passed to the `query` command.  If a queried item does not exist and the `query` call returns an address for the missing item, the value is set to a blank string ("".
        #        - See the comments on expanding for the `query` command.
        #Example Usage:
        
        
        
        # Usually, you would loop through the results.
        puts "Most loops can be handled by `hl7 each`."
        puts "foreach result hl7 get $msg PID.3.*.0.0"
        foreach result [hl7 get $msg PID.3.*.0.0] {
            set value [lindex $result 0]
            set address [lindex $result 1]
        
            # do something with the value and address
            puts "$address) $value"
        }
        
        puts "Occasionally, you'd only want the values"
        puts "set values hl7 get values $msg PID.3.*.0.0"
        set values [hl7 get values $msg PID.3.*.0.0]
        
        puts "If you're doing something destructive, reverse the results."
        puts "foreach result hl7 get reversed $msg *.0.0.0.0"
        
        foreach result [hl7 get reversed $msg *.0.0.0.0] {
            # remove Z segments
            set segment_type [lindex $result 0]
        
            if { [regexp {^Z} $segment_type] } {
                # remove the Z segment
        
                # get the address of the result
                set address [lindex $result 1]
        
                # get the segment address (the first part)
                set segment_address [lindex [split $address "."] 0]
        
                # remove the segment
                puts "message before removing segment\n $msg"
                set msg [hl7 delete $msg $segment_address]
                puts "message after removing segment\n $msg"
            }
        }


        set msg [hl7 parse $msgdata]     
        puts "set"
        puts "This proc is used to set the value of the items that match the given query address. \nIt makes the modifications and returns the resulting parsed-message."
        #
        puts "Usage:"
        #
        puts "hl7 set <msg> <query> <value> <expand>"
        #
        #Arguments:
        #    msg: The message being modified.
        #    query: The query indicating the items to be modified.
        #    value: The new value of the matched items.
        #    expand (optional):
        #        - Default: 0
        #        - This is passed to the `query` command.  If a queried item does not exist and the `query` call returns an address for the missing item, the message is expanded to include the indicated item and its value is set to the given value.
        #        - See the comments on expanding for the `query` command.
        #Example Usage:
        
        puts "set the sending and receiving facilities to '01'"
        puts "msg hl7 set $msg MSH.3,5.0.0.0 '01'"
        set msg [hl7 set $msg MSH.3,5.0.0.0 "01"]
        puts "SET TWO FIELDS TO HAVE THE SAME VALUE \n $msg"
        

        set msg [hl7 parse $msgdata]           
        #clear
        puts "clear"
        puts "This proc clears out the contents of the items that match the given query. \nThe modified parsed-message is returned."
        
        puts "Usage:"
        
        puts "hl7 clear <msg> <query>"
        
        puts "Arguments:"
        puts "    msg: The message being modified."
        puts "    query: The query indicating the items to be cleared."
        puts "Example Usage:"
        
        puts "clear out the identifiers in PID.2"
        puts "before CLEAR $msg"
        set msg [hl7 clear $msg PID.2]
        puts "after clear $msg"

        
        set msg [hl7 parse $msgdata]           
        
        puts "delete"
        #delete
        
        puts "This proc COMPLETELY removes the items that match the given query from the message. \nThe modified parsed-message is returned."
        
        puts "Usage:"
        
        puts "hl7 delete <msg> <query>"
        
        puts "Arguments:"
        puts "    msg: The message being modified."
        puts "    query: The query indicating the items to be removed."
        puts "Example Usage:"
        
        # remove the 2nd identifier in PID.3
        puts "remove the 2nd identifier in PID.3"
        puts "set msg hl7 delete $msg PID.3.1"
        set msg [hl7 data $msg] 
        puts "msg before delete\n $msg"
        set msg [hl7 parse $msgdata]  
        #set values [hl7 get values $msg "PID.3.0.4"]
        puts "PV2"
        set values [hl7 get values $msg "PV2.22.*.0"]
        puts "Value that will be deleted:  $values " 
       # set values [hl7 get values $msg "PID.3.0.0"]
        puts "Value that will be KEPT:  $values "         
        set msg [hl7 delete $msg PV2.22.*.0]
        #
        #set msg [hl7 delete $msg $msgQuery]
        set msg [hl7 data $msg] 
        puts "msg after delete\n $msg"

set msg [hl7 parse $msgdata]  
        # Occasionally, you'd only want the values
set values [hl7 get values $msg PID.3.*]
puts "VALUES: $values\n"
# If you're doing something destructive, reverse the results.

set msgQuery "PID.3.0.0"
#set msgQuery "PV2.
set querySegment [lindex [split $msgQuery "."] 0]

set mySeg "PID"
set mySeg $querySegment



foreach result [hl7 get reversed $msg *.0.0.0] {
    # remove Z segments
    set segment_type [lindex $result 0]

    if { [regexp "^$mySeg" $segment_type] } {
        # remove the Z segment

        # get the address of the result
        set address [lindex $result 1]
        puts "address $address"

        # get the segment address (the first part)
        set segment_address [lindex [split $address "."] 0]
        puts "SEGMENT ADDRESS to delete $segment_address"
        # remove the segment
        #set msg [hl7 delete $msg $segment_address]
    }
}

set msg [hl7 data $msg] 
puts "msg after delete\n $msg"  
set msg [hl7 parse $msgdata]      

             
        puts "add"
        #add
        #
        puts "This proc appends the given value to the end of the items indicated by the query. \nThe modified parsed-message is returned."
        #
        #Note that this can't be run on segments or subcomponents. You can't run it on segments because appending a field to the endof a segment is usually not needed (usually, the field index has meaning). You can bypass this by using set. You can't run this on subcomponents because there are not items at a lower level than subcomponents.
        #
        puts "Usage:"
        #
        puts "hl7 add <msg> <query> <value> <expand>"
        #
        #Arguments:
        #    msg: The message being modified.
        #    query: The query indicating the items being appended to.
        #    value: The value being appended.
        #    expand (optional):
        #        - Default: 1
        #        - Typically, you would want the message to expand to include the item that you are appending to.
        #        - See the comments on expanding for the `query` command.
        #Example Usage:
        #
        puts "add an identifier repetition to PID.3"
        puts "set msg hl7 add $msg PID.3 $id"
        set msg [hl7 add $msg PID.3 $id]
        
set msg [hl7 parse $msgdata]           
        puts "insert"
        #insert
        #
        puts "This proc inserts the given value either at the address indicated in the query or after the address. \nAll items at the inserted index (and after) are shifted."
        #
        puts "Usage:"
        
        puts "There are three forms of the insert command, two of which perform the same operation:"
        
        
        puts "insert <msg> <query> <value>: This form inserts the value at the address indicated by query."
        puts "insert before <msg> <query> <value>: This form acts just like the first form."
        puts "insert after <msg> <query> <value>: This form inserts the value after the address indicated by query."
        puts "Example Usage:"
        
        #
        #There are three forms of the insert command, two of which perform the same operation:
        #insert <msg> <query> <value>: This form inserts the value at the address indicated by query.
        #insert before <msg> <query> <value>: This form acts just like the first form.
        #insert after <msg> <query> <value>: This form inserts the value after the address indicated by query.
        #Example Usage:
        #
        ## insert the id as the first repetition in PID.3

        set msg [hl7 parse $msgdata]   
        puts "insert the id as the first repetition in PID.3"
        set msg [hl7 insert $msg PID.3.0 $id]
        set msg [hl7 insert $msg PID.3.0 $id]
        #
        set msg [hl7 parse $msgdata]   
        puts "do the same thing, using `insert before`"
        puts "set msg hl7 insert before $msg PID.3.0 $id"
        set msg [hl7 insert before $msg PID.3.0 $id]
        #
        set msg [hl7 parse $msgdata]   
        puts "insert the id as the second repetition in PID.3"
        puts "set msg hl7 insert after $msg PID.3.0 $id"
        set msg [hl7 insert after $msg PID.3.0 $id]

        set msg [hl7 parse $msgdata]   
        puts "INSERT A NEW ZPI SEGMENT AFTER THE PID"
        puts "set msg hl7 insert after PID ZP \n $msg "
        set msg [hl7 insert after $msg PID ZPI.0]

        puts "insert new segment AFTER"

        puts "$msg"

        
        puts "each"
        #each
        set msg [hl7 parse $msgdata]   
        puts "--------- EACH ----------"
        puts "Looping through the results of an hl7 get call"
        puts "A common idiom that you will see with this library is looping through the results of an hl7 get call. \nThe way to do this with TCL's foreach command can be seen below:"
        #
        puts "loop through each item"

        puts "foreach result hl7 get $msg PID.3.*.0.0"
        foreach result [hl7 get $msg PID.3.*.0.0] {
            set value [lindex $result 0]
            set address [lindex $result 1]
        
            # do something with the value and address
            puts "$address) $value"
        }

        
        puts "Notice that with this example, you have to manually pull out each result's value and address using lindex.\n Since this was such a common idiom, hl7 each was created to simplify this scenario."
        puts "For example, the above becomes the following when using hl7 each:"
        puts ""
        puts "loop through each item"
        puts "hl7 each value address $msg PID.3.*.0.0"
       
                         
         

        }
        

        shutdown {
                echo "upd_msh3_4 is shutting down"
        }
         
        time {
            # Timer-based processing
            # N.B.: there may or may not be a MSGID key in args
        }

        default {
            error "Unknown mode '$mode' in upd_msh_6"
        }
    }

    return $dispList
}

