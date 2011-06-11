use t::Test;
use Test::More tests => 1;
use Test::Differences;

use Module::Manifest::Skip;

my $mms = Module::Manifest::Skip->new;

eq_or_diff $mms->text, $TEMPLATE,
    'Default MANIFEST.SKIP text is ok';
