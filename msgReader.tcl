#!/usr/bin/perl -lw

###########################################################################
#
# Name: msgReader
# Purpose: Parse HL7 into segments
#
###########################################################################

use Getopt::Std;
use Text::Wrap;

getopt('w');

if ($opt_w) {
    $Text::Wrap::columns = $opt_w;
}

$/ = "\r";
$i = 0;

while (<>) {
    s/\n//g;
    if (/^MSH/) {
        $i++;
        print "\nMessage: $i\n";
    }
    if ($opt_w) {
        print wrap("", "    ", $_);
    } else {
        print;
    }
}
