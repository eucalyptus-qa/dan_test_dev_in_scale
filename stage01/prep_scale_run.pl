#!/usr/bin/perl
use strict;

my $orig_test = "dan_test_dev_as_user";
my $scale_limit = 2;
my $repeat_limit = 3;

if( @ARGV > 0 ){
	my $temp = shift @ARGV;
	if( $temp =~ /\d+/){
		$scale_limit = $temp;
	};
};

if( @ARGV > 0 ){
	my $temp = shift @ARGV;
	if( $temp =~ /\d+/){
		$repeat_limit = $temp;
	};
};

$ENV{'TEST_REPEAT_LIMIT'} = $repeat_limit;

print "\n";
print "Preparing Scale Run\n";
print "\n";
print "[SCALE LIMIT]\t$scale_limit\n";
print "[REPEAT LIMIT]\t$ENV{'TEST_REPEAT_LIMIT'}\n";
print "\n";


print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Prepapre ../etc/runs directory\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";


print "rm -fr ../etc/$orig_test\n";
system("rm -fr ../etc/$orig_test");
print "\n";

print "rm -fr ../etc/runs\n";
system("rm -fr ../etc/runs");
print "\n";

print "mkdir -p ../etc/runs\n";
system("mkdir -p ../etc/runs");
print "\n";

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Get the original copy of \'$orig_test\'\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";


print "cd ../etc; bzr co sftp://root\@192.168.7.1/home/repositories/tests/qa/$orig_test\n";
system("cd ../etc; bzr co sftp://root\@192.168.7.1/home/repositories/tests/qa/$orig_test");
print "\n";


for( my $i = 0; $i < $scale_limit; $i++){
	my $account = "account" . sprintf("%02d", $i);
	my $user = "user00";
	my $testname = $orig_test . sprintf("%02d", $i);
	
	print "\n\n";
	print "\n";
	print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	print "Create Test Copy \'$testname\' for Account \'$account\' and User \'$user\'\n";
	print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	print "\n";

	if( create_test_copy_with_new_user($orig_test, $testname, $account, $user) ){
		print "[TEST_REPORT]\tFAILED in creating test copy $testname under account $account and user $user !!\n\n";
	};

};

my $testname = $orig_test . "_final";
my $account = "account00";
my $user = "user00";

### Adjusting Test REPEAT LIMIT to 3 since this test is used to verify the wellness of the system
$ENV{'TEST_REPEAT_LIMIT'} = 3;

print "\n\n";
print "\n";
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Create Test Copy \'$testname\' for Account \'$account\' and User \'$user\'\n";
print "***This test is designed to run as a verification test\n";
print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";

if( create_test_copy_with_new_user($orig_test, $testname, $account, $user) ){
	print "[TEST_REPORT]\tFAILED in creating test copy $testname under account $account and user $user !!\n\n";
};


exit(0);








######################### SUB-ROUTINES #################################


sub create_test_copy_with_new_user{

	my $orig_test = shift @_;
	my $testname = shift @_;
	my $account = shift @_;
	my $user = shift @_;

	if( !( -e "../etc/$orig_test") ){
		print "[TEST_REPORT]\tFAILED in finding ./etc/$orig_test !!\n\n";
		return 1;
	};

	print "cp -r ../etc/$orig_test ../etc/runs/$testname\n";
	system("cp -r ../etc/$orig_test ../etc/runs/$testname");
	print "\n";

	if( !( -e "../input/2b_tested.lst") ){
		print "[TEST_REPORT]\tFAILED in finding ../input/2b_tested.lst !!\n\n";
		return 1;
	};

	print "cp ../input/2b_tested.lst ../etc/runs/$testname/input/.\n";
	system("cp ../input/2b_tested.lst ../etc/runs/$testname/input/.");
	print "\n";
	

	my $conf_file = "../etc/runs/$testname/".$testname.".conf";

	print "mv -f ../etc/runs/$testname/".$orig_test.".conf  $conf_file\n";
	system("mv -f ../etc/runs/$testname/".$orig_test.".conf  $conf_file");
	print "\n";

	my_sed("TEST_NAME\t$orig_test", "TEST_NAME\t$testname", $conf_file);

	my_sed("RUN download_user_credentials.pl", "RUN download_user_credentials.pl $account $user", $conf_file);

	my_sed("REPEAT\t3", "REPEAT\t" . $ENV{'TEST_REPEAT_LIMIT'}, $conf_file);

	print "\n";
	print "Change in Configuration File $conf_file\n";
	print "\n";

	system("head -n 17 $conf_file");
	print "\n";

	print "\n";
	print "[TEST_REPORT]\tSucceeded in create_test_copy_with_new_user($orig_test, $testname, $account, $user);\n\n";
	print "\n";

	return 0;
};


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

