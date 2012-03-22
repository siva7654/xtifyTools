#!/usr/bin/perl
  
use strict;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;

my $numArgs = $#ARGV+1;

if ($numArgs != 1) {
  print $numArgs . "\nUsage: apiPush.pl configFile.json\n\n";
  exit;
}
 
my $file = $ARGV[0];
my $apiRequest = do {
    local $/ = undef;
    open my $fh, "<", $file
        or die "could not open $file: $!";
    <$fh>;
};
$ENV{HTTPS_DEBUG} = 1;
$ENV{HTTPS_CERT_FILE} = '/Users/michael/Documents/workspace/Xtify_Webservices/2.0/discover.client.xtify.crt';
$ENV{HTTPS_KEY_FILE}  = '/Users/michael/Documents/workspace/Xtify_Webservices/2.0/discover.client.xtify.key';

my $apiHeader = HTTP::Headers->new;
$apiHeader->push_header('Content-Type' => 'application/json');

my $apiPostRequest = HTTP::Request->new(
 "POST",
 "https://api.xtify.com/2.0/push",
 $apiHeader,
 $apiRequest
);
 
my $apiUserAgent = LWP::UserAgent->new;
my $apiResponse = $apiUserAgent->request($apiPostRequest);

print $apiRequest;
 
if (!$apiResponse->is_error) {
 print $apiResponse->content;
}
else {
 print $apiResponse->error_as_HTML;
}
