#!/path/to/perl
# vinocui@gmail.com

# 2010/1/26 changed the parameter use gap seconds
# 2009/7/15 first version
# tool for calibrate latitude & longitude in *.map files generated
# by TrekBuddy_Atlas_Creator_v1.1

#   Actual:     N39бу4'21.9"  E117бу15'49.6"
#   Google Map: N39бу4'26.3"  E117бу16'13.6"

my $line;
my $argc = @ARGV;


my $version = "090715";
print "cb: calibrate .map file the TrekBuddy_Atlas_Creator_v1.1 generated.\n";
my $bar = "VERSION: $version, vinocui\@gmail.com, twitter.com/vinocui\n";
if ($argc != 3 and $argc != 2){
    print $bar, "\n";
    print "Usage:\n";
    print "  " . __FILE__ . " [+|-]Nseconds [+|-]Eseconds xxx.map\n";
    print "  " . __FILE__ . " lat/long lat/long\n";
    print "\nDescriptions: 
  Nseconds: North latitude correction seconds
  Eseconds: East longitude correction seconds
  + or -:   corection direction from Actual GPS lat/long to Google Map lat/long. default is +
  use 2 parameter means calculating the gap, return seconds.
  \n";

    exit 1;
}

if($argc == 2){
    my @D = ();
    my @M = ();
    my @S = ();

    for($i = 0; $i < 2; $i++){
	my ($d, $a) = split(/D/, $ARGV[$i]);
	$D[$i] = $d;
	my ($m, $s) = split(/M/, $a);
	$M[$i] = $m;
	$S[$i] = $s;
    }
    $gap = (($D[0])*60+($M[0]))*60+($S[0]) - ((($D[1])*60+($M[1]))*60+$S[1]);
    print $D[0] . "бу" . $M[0] . '\'' . $S[0] . '"'. " => ";
    print $D[1] . "бу" . $M[1] . '\'' . $S[1] . '"';
    print " gap (in seconds) is\n$gap";
    print "\nConversion: ", $D[0]+($M[0]+$S[0]/60.0)/60.0,  "  " ,  $D[1]+($M[1]+$S[1]/60.0)/60.0 , "\n";
    exit 0;
}

# following is $argc = 3
$mapfile = $ARGV[2];
# Nc: North corrction seconds
my $Ncs = $ARGV[0];
my $Ecs = $ARGV[1];

print $Ncs, "_", $Ecs, "\n";

my $nMcb = $Ncs/60;
my $eMcb = $Ecs/60;
my $nDcb = $nMcb/60;
my $eDcb = $eMcb/60;
print "N: ", $nMcb, "\'\n";
print "E: ", $eMcb, "\'\n";
print "N: ", $nDcb, "бу\n";
print "E: ", $eDcb, "бу\n";



open (INFILE, $mapfile ) or die "Could not open file";
open (BACKUPFILE, ">$mapfile.bak" ) or die "Could not open file";

while (my $line = <INFILE>){
    print BACKUPFILE $line;
}
close (BACKUPFILE);
close (INFILE);

open (INFILE, "$mapfile.bak" ) or die "Could not open file";
open (OUTFILE, ">$mapfile") or die $!;

while (my $line = <INFILE>) {
    if($line =~ /Point01|Point02|Point03|Point04/g){
	my @segs = split(/\,/, $line);
	print $segs[7] . "N, " . $segs[10]. "E\n";

	for(my $i; $i<@segs; $i++){
	    my $v = 0.0;
	    if($i == 7){
		$segs[$i] = sprintf("%.6f", $segs[$i] + $nMcb);
	    }elsif($i == 10 ){
		$segs[$i] = sprintf("%.6f", $segs[$i] + $eMcb);
	    }
	    print OUTFILE $segs[$i];
	    if($i != (@segs - 1))
	    {
		print OUTFILE ",";
	    }
	}
	next;
    }

    if($line =~ /MMPLL/g){
	my @segs = split(/\,/, $line);
	chomp($segs[3]);
	print $segs[2], "E, " . $segs[3] . "N\n"; 
	for(my $i = 0; $i < @segs; $i++){

	    if ($i == 2){
		$segs[$i] = sprintf("%.6f", $segs[$i] + $eDcb);
	    }elsif($i == 3){
		$segs[$i] = sprintf("%.6f", $segs[$i] + $nDcb);
	    }
	    print OUTFILE $segs[$i];
	    if($i != (@segs - 1))
	    {
		print OUTFILE ",";
	    }else{
		print OUTFILE "\n";
	    }
	}
	next;
    }
    print OUTFILE $line;
}
close (INFILE);
close (OUTFILE);
