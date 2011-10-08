##
# name:      Module::Manifest::Skip
# abstract:  MANIFEST.SKIP Manangement for Modules
# author:    Ingy döt Net
# license:   perl
# copyright: 2011

use 5.008003;
package Module::Manifest::Skip;

use Moo 0.009008;

our $VERSION = '0.16';

has text => (
    is => 'ro',
    builder => 'text__',
    lazy => 1,
);

has old_text => (
    is => 'ro',
    default => sub {
        my $self = shift;
        return $self->read_file('MANIFEST.SKIP', 1);
    },
);

sub import {
    my ($package, $command) = @_;
    if ($command and $command eq 'create') {
        my $text = $package->new->text;
        open MS, '>', 'MANIFEST.SKIP'
            or die "Can't open MANIFEST.SKIP for output:\n$!";
        print MS $text;
        close MS;
        exit;
    }
    else {
        goto &Moo::import;
    }
}

sub add {
    my $self = shift;
    my $addition = shift or return;
    chomp $addition;
    if (not $self->{add_occurred}++) {
        $self->{text} =~ s/\n+\z/\n\n/;
    }
    $self->{text} .= $addition . "\n";
}

sub remove {
    my $self = shift;
    my $exclude = shift or return;
    $self->{text} =~ s/^(\Q$exclude\E)$/# $1/mg;
}

sub text__ {
    my $self = shift;
    my $old = $self->old_text;
    my $text = ($old =~ /\A(\S.*?\n\n)/s) ? $1 : '';
    chomp $text;
    $text .= $self->skip_template;
    local $self->{text} = $text;
    $self->reduce;
    return $self->{text};
}

sub reduce {
    my $self = shift;
    while ($self->{text} =~ s/^- (.*)$/* $1/m) {
        $self->remove($1);
    }
    $self->{text} =~ s/^\* /- /mg;
}

sub skip_template {
    my $self = shift;
    my $path = $INC{'Module/Manifest/Skip.pm'} or die;
    if (-e 'lib/Module/Manifest/Skip.pm') {
        return $self->read_file('share/MANIFEST.SKIP');
    }
    elsif ($path =~ s!(\S.*?)[\\/]?\blib\b.*!$1! and -e "$path/share") {
        return $self->read_file("$path/share/MANIFEST.SKIP");
    }
    else {
        require File::ShareDir;
        require File::Spec;
        my $dir = File::ShareDir::dist_dir('Module-Manifest-Skip');
        my $file = File::Spec->catfile($dir, 'MANIFEST.SKIP');
        die "Can't find MANIFEST.SKIP share file for Module::Manifest::Skip"
            unless $dir and -f $file and -r $file;
        return $self->read_file($file);
    }
}

sub read_file {
    my ($self, $file, $ignore) = @_;
    open FILE, $file or
        $ignore and return '' or
        die "Can't open '$file' for input:\n$!";
    my $text = do { local $/; <FILE> };
    close FILE;
    $text =~ s/\r//g;
    return $text;
}

1;

=head1 SYNOPSIS

From the command line:

    > perl -MModule::Manifest::Skip=create

From Perl:

    use Module::Manifest::Skip;
    use IO::All;
    
    my $mms = Module::Manifest::Skip->new;
    # optional add and removes:
    $mms->add('^foo-bar$');
    $mms->remove('^foo$');
    $mms->remove(qr/\Q\bfoo\b/);
    io('MANIFEST.SKIP')->print($mms->text);

=head1 DESCRIPTION

B<NOTE:> This module is mostly intended for module packaging frameworks to
share a common, up-to-date C<MANIFEST.SKIP> base. For example,
Module::Install::ManifestSkip, uses this module to get the actual SKIP
content. However this module may be useful for any module author.

CPAN module authors use a MANIFEST.SKIP file to exclude certain well known
files from getting put into a generated MANIFEST file, which would cause them
to go into the final distribution package.

The packaging tools try to automatically skip things for you, but if you add
one of your own entries, you have to add all the common ones yourself. This
module attempts to make all of this boring process as simple and reliable as
possible.

Module::Manifest::Skip can create or update a MANIFEST.SKIP file for you. You
can add your own entries, and it will leave them alone. You can even tell it
to B<not> skip certain entries that it normally skips, although this is rarely
needed.

=head1 USAGE

Usually this module is called by other packaging modules. If you want this to
be used by Module::Install, then you would put this:

    manifest_skip 'clean';

in your F<Makefile.PL>, and everything would be taken care of for you.

If you want to simply create a F<MANIFEST.SKIP> file from the command line,
this handy syntax exists:

    > perl -MModule::Manifest::Skip=create

=head1 BEHAVIOR

This module ships with a share file called F<share/MANIFEST.SKIP>. This is the
basis for all new MANIFEST.SKIP files. This module will look for an already
existing F<MANIFEST.SKIP> file and take all the text before the first blank
line, and prepend it to the start of a new SKIP file. This allows you to put
your own personal section at the top, that will not be overwritten later.

It will then look for lines beginning with a dash followed by a space. Like
this:

    - \bfoo\b
    - ^bar/
    - ^baz$

It will comment out each of these lines and any other lines that match the
text (after the '- '). This allows you to override the default SKIPs.
