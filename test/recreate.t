use strict;
use File::Basename;
use lib dirname(__FILE__);
use TestModuleManifestSkip;

use Test::More tests => 4;
# use XXX; use Test::Differences; *is = \&eq_or_diff;

my $t = -e 't' ? 't' : 'test';
my $dir = "$t/dir3";
my $file = "$dir/MANIFEST.SKIP";

unlink $file;
die if -e $file;

create();
create();

unlink $file or die;

sub create {
    chdir $dir or die;

    system("$^X -I$LIB -MModule::Manifest::Skip=create") == 0
        or die;

    chdir $HOME or die;

    ok -e $file,
        "MANIFEST.SKIP created";

    is read_file($file),
        $TEMPLATE,
        'MANIFEST.SKIP is correct';
}
