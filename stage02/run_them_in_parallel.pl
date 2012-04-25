#!/usr/bin/perl
use strict;

my $orig_test = "dan_test_dev_as_user";

print "\n";
print "Run the Tests in Parallel\n";
print "\n";


if(  -e "../etc/runs/logs" ){
	system("rm -fr ../etc/runs/logs");	
}; 

system("mkdir -p ../etc/runs/logs");	


print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Discover How Many Tests to Run\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";

print("ls ../etc/runs | grep $orig_test\n");
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


if( $scale_limit <= 0 ){
	print "[TEST_REPORT]\tFAILED in discovering test counts!!\n\n";
	exit(1);
};

print "\n";
print "Among $temp tests in ./etc/runs,\n";
print "$scale_limit tests will run in parallel,\n";
print "and the \"_final\" test will be used to verify the condition of the system\n";
print "\n";


my @pids;

for( my $i = 0; $i < $scale_limit; $i++){

	my $account = "account" . sprintf("%02d", $i);
	my $user = "user00";
	my $testname = $orig_test . sprintf("%02d", $i);
	
	$pids[$i] = fork();
	if(not defined $pids[$i]) {
		clean_exit("Failed in fork(): ID $i\nAborting...");
	}elsif($pids[$i] == 0) {
		print "\n\n";
		print "\n";
		print "CHILD $i :: Prepraing Test ID $i\n";
		print "\n";

		print "\n";
		print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
		print "Running the Test \'$testname\' for Account \'$account\' and User \'$user\'\n";
		print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
		print "\n";

		if( run_test_while_forked($testname) ){
			print "[TEST_REPORT]\tFAILED in running test \'$testname\' while forked !!\n\n";
			exit(1);
		};

		print "\n\n";		
		print "\n";
		print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
		print "End of the Test \'$testname\' for Account \'$account\' and User \'$user\'\n";
		print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
		print "\n";
		
		print "\n";
		print "CHILD $i :: Completed Test ID $i\n";
		print "\n";
		exit(0);
	};
};

for( my $i = 0 ; $i < $scale_limit; $i++){
	print "PARENT :: Waiting on CHILD $i :: PID $pids[$i]\n";
	waitpid($pids[$i],0);
};

sleep(5);

my $testname = $orig_test . "_final";
my $account = "account00";
my $user = "user00";

print "\n\n\n\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Running the Final Test \'$testname\' for Account \'$account\' and User \'$user\'\n";
print "***This test is used to verify the condition of the system\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";

if( run_test_while_forked($testname) ){
	print "[TEST_REPORT]\tFAILED in running final test \'$testname\' while forked !!\n\n";
	exit(1);
};
		
print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "End of the Test \'$testname\' for Account \'$account\' and User \'$user\'\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";

print "\n";
print "[TEST_REPORT]\tCompleted the Final Run\n";
print "\n";

print "\n\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Scanning the Log File of the Final Test Run\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";

system("cat ../etc/runs/logs/". $testname . ".log | grep TEST_REPORT ");

print "\n";
print "\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "End of Log File of the Final Test Run\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";

print "\n";
print "\n";
print "[TEST_REPORT]\tCompleted Parallel Test Run\n";
print "\n";


exit(0);



######################### SUB-ROUTINES #################################


sub run_test_while_forked{

	my $testname = shift @_;

	if( !( -e "../etc/runs/$testname") ){
		print "[TEST_REPORT]\tFAILED in locating $testname !!\n\n";
		return 1;
	}; 

	if( !( -e "../etc/runs/logs") ){
		print "[TEST_REPORT]\tFAILED in locating ../etc/runs/logs !!\n\n";
		return 1;
	}; 

	my $this_log_file = $testname .".log";

	system("rm -f ../etc/runs/logs/$this_log_file"); 
	system("touch ../etc/runs/logs/$this_log_file"); 

	system("cd ../etc/runs/$testname; perl ./run_test.pl ".$testname.".conf > ../logs/$this_log_file 2> ../logs/$this_log_file");
	
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

