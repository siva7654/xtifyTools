#!/usr/bin/perl
  
use strict;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;

####
# Edit these vars
 
my $XID = "YOUR USER'S XID"; 
my $tag = "TAG NAME";
my $appKey = "YOUR XTIFY APP KEY";

#
####

my $apiUrl = "http://api.xtify.com/2.0/tags/" . $XID . "/addtag?appKey=" . $appKey . "&tag=" . $tag;
my $apiUa = new LWP::UserAgent;
my $apiRequest = new HTTP::Request 'POST', $apiUrl;
$apiRequest->content_type('application/x-www-form-urlencoded');

# send the request
my $apiResult = $apiUa->request($apiRequest);

print $apiRequest->as_string( );

if ($apiResult->is_error) {
 print $apiResult->error_as_HTML;
}
