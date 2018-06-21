package Submerge::Feed;

use strict;
use warnings;

use Submerge::DB;
use Submerge::YouTubeFeed;

sub new {
    my ($pkg, $token, %opts) = @_;

    my $self = bless { %opts, token => $token }, $pkg;

    return $self;
}

sub have_channel {
    my ($self, $channel_id) = @_;

    my ($count) = Submerge::DB->dbh->selectrow_array(qq{
        SELECT count(*)
        FROM subscriptions
        WHERE token = ? AND channel_id = ?
    }, {}, $self->{token}, $channel_id);

    return $count == 1 ? 1 : 0;
}

sub channels {
    my ($self, $cb) = @_;

    my @channels = @{ Submerge::DB->dbh->selectall_arrayref(qq{
        SELECT channel_id, name
        FROM subscriptions
        LEFT JOIN channel_names
        USING (channel_id)
        WHERE token = ?
    }, {}, $self->{token}) };

    # put the known names into a hash, and unknown ones into @must_fetch
    my @must_fetch;
    my %name_for;
    for my $channel (@channels) {
        my ($id, $name) = @$channel;
        if (!defined $name) {
            push @must_fetch, $id;
        } else {
            $name_for{$id} = $name;
        }
    }

    # closure to call the provided $cb with all the channel ids and names
    my $call_cb = sub {
        my @return;
        for my $id (sort keys %name_for) {
            push @return, {
                name => $name_for{$id},
                channel_id => $id,
            };
        }
        $cb->(@return);
    };

    # run the closure immediately if we don't need to fetch anything...
    if (@must_fetch == 0) {
        $call_cb->();
    }

    # ...otherwise, fetch what we need to fetch and run the closure when all are done
    my $nfetched = 0;
    for my $id (@must_fetch) {
        Submerge::YouTubeFeed->get_feed($id, sub {
            my ($feed) = @_;

            $name_for{$id} = $feed->title;
            $call_cb->() if ++$nfetched == @must_fetch;
        });
    }
}

sub add_channel {
    my ($self, $channel_id, $cb) = @_;

    return $cb->() if $self->have_channel($channel_id);

    Submerge::DB->dbh->do(qq{
        INSERT INTO subscriptions
        (token, channel_id)
        VALUES (?, ?)
    }, {}, $self->{token}, $channel_id);
}

sub remove_channel {
    my ($self, $channel_id) = @_;

    Submerge::DB->dbh->do(qq{
        DELETE FROM subscriptions
        WHERE token = ? AND channel_id = ?
    }, {}, $self->{token}, $channel_id);
}

sub clear_channels {
    my ($self) = @_;

    Submerge::DB->dbh->do(qq{
        DELETE FROM subscriptions
        WHERE token = ?
    }, {}, $self->{token});
}

1;
