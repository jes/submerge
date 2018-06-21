package Submerge::RSS;

use strict;
use warnings;

use XML::Feed;

sub new {
    my ($pkg, %opts) = @_;

    my $self = bless \%opts, $pkg;

    $self->{feed} = XML::Feed->new();

    return $self;
}

sub feed {
    my ($self) = @_;

    $self->{feed}->title('Submerge videos');

    return $self->{feed};
}

sub add_feed {
    my ($self, $feed) = @_;

    my @entries = ($self->{feed}->entries, $feed->entries);
    $self->{feed} = XML::Feed->new();

    for my $entry (sort { $b->issued cmp $a->issued } @entries) {
        $self->{feed}->add_entry($entry);
    }
}

1;
