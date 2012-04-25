#!/usr/bin/perl
use strict;

my $orig_test = "dan_test_dev_as_user";

print "\n";
print "Collect Artifacts of Tests\n";
print "\n";


print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Discover Tests\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";

print "ls ../etc/runs | grep $orig_test\n";
print "\n";
system("ls ../etc/runs | grep $orig_test");
print "\n";

my $scale_limit = 0;

my $temp = `ls ../etc/runs | grep $orig_test | wc -l`;
chomp($temp);
print "Discovered $temp Tests\n";
print "\n";

if( $temp =~ /\d+/ ){
	$scale_limit = $temp - 1;
};

if( $scale_limit == 0 ){
	print "[TEST_REPORT]\tFAILED in discovering test counts!!\n\n";
	exit(1);
};

for( my $i = 0; $i < $scale_limit; $i++){

	my $account = "account" . sprintf("%02d", $i);
	my $user = "user00";
	my $testname = $orig_test . sprintf("%02d", $i);
	
	if( !( -e "../etc/runs/$testname/artifacts") ){
		print "[TEST_REPORT]\tFAILED in locating $testname/artfacts directory !!\n\n";
		exit(1);
	}; 

	print "\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	print "Creating a Link to the Test \'$testname\' for Account \'$account\' and User \'$user\'\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	print "\n";

	print "\n";
	print "ln -s ../etc/runs/$testname/artifacts ../artifacts/artifacts_of_$testname\n";
	system("ln -s ../etc/runs/$testname/artifacts ../artifacts/artifacts_of_$testname");
	print "\n";

};

my $testname = $orig_test . "_final";

print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Creating a Link to the Final Test \'$testname\'\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";

print "\n";
print "ln -s ../etc/runs/$testname/artifacts ../artifacts/artifacts_of_$testname\n";
system("ln -s ../etc/runs/$testname/artifacts ../artifacts/artifacts_of_$testname");
print "\n";


print "\n";
print "[TEST_REPORT]\tCompleted Collecting Artifacts\n";
print "\n";


exit(0);



######################### SUB-ROUTINES #################################


# To make 'sed' command human-readable
# my_sed( target_text, new_text, filename);
#   --->
#        sed --in-place 's/ <target_text> / <new_text> /' <filename>
sub my_sed{

        my ($from, $to, $file) = @_;

        $from =~ s/([\'\"\/])/\\$1/g;
        $to =~ s/([\'\"\/])/\\$1/g;

        my $cmd = "sed --in-place 's/" . $from . "/" . $to . "/' " . $file;

        system("$cmd");

        return 0;
};

1;

