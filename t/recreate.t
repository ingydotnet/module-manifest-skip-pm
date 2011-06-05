use t::Test;
use Test::More tests => 4;
# use Test::Differences;
# *is = \&eq_or_diff;

my $dir = 't/dir3';
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
