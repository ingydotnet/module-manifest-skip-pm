use t::Test;
use Test::More tests => 1;

use Module::Manifest::Skip;

my $mms = Module::Manifest::Skip->new;

is $mms->text, $TEMPLATE,
    'Default MANIFEST.SKIP text is ok';
