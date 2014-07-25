use strict; use warnings;
package TestModuleManifestSkip;

use base 'Exporter';

use Module::Manifest::Skip;
use Cwd qw[cwd abs_path];

our $HOME = cwd;
our $LIB = abs_path 'lib';
our $TEMPLATE = Module::Manifest::Skip->read_file('share/MANIFEST.SKIP');
our @EXPORT = qw[read_file copy_file cwd abs_path $HOME $LIB $TEMPLATE];

sub import {
    strict->import;
    warnings->import;
    goto &Exporter::import;
}

sub read_file {
    return Module::Manifest::Skip->read_file(@_);
}

sub copy_file {
    my ($src, $dest) = @_;
    open IN, $src or die "Can't open $src for input";
    open OUT, '>', $dest or die "Can't open $dest for output";
    local $/;
    print OUT <IN>;
    close OUT;
    close IN;
    return 1;
}

1;
