#! perl

$tar = "bin\\tar.exe";
$rm = "bin\\rm.exe";
$cp = "bin\\cp.exe";

if( !$ARGV[0]){
    print "need cr.tar\n";
    exit 1;
}

$cr = $ARGV[0];
$ex = $cr . "_";
$cmd = "$rm -rf $ex";
mkdir $ex;
$cmd = "cp -f $cr $ex";
system ($cmd);
$cmd = $tar . " xvf $ex/" . $cr . " -C $ex";
system ($cmd);
$cmd = $tar . " -tf $ex/$cr > $ex/$cr.lst";
print $cmd, "\n";
system ($cmd);

open H, "$ex/$cr.lst";
@fs = <H>;
close H;

foreach $f (@fs){
    chomp $f;
    $_ = $f;
    if( /.map$/){
#	print $f, "\n";
#	$cmd = "perl cb.pl -2.9 -22.1 \"" . $ex . "/" . $f . "\"";
	$cmd = "perl cb.pl -3.78 -22 \"" . $ex . "/" . $f . "\"";
	print $cmd, "\n";
	system($cmd);
    }
}

system("rm -f $ex/$cr.lst $ex/$cr ");
chdir $ex;
system("tar cvf $cr .");
chdir "..";
system("mv $ex/$cr $cr.new");
system("rm -rf $ex");
system("tar --delete . -f $cr.new");
system("tar --delete $cr -f $cr.new");
