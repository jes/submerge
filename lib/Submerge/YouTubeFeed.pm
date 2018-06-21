package Submerge::YouTubeFeed;

use strict;
use warnings;

use Mojo::UserAgent;
use Mojo::Util qw(url_escape);
use XML::Feed;

my $ua = Mojo::UserAgent->new();
$ua->max_redirects(3); # follow redirects


sub get_channel_id {
    my ($pkg, $url, $cb) = @_;

    $url =~ s/^\s*//;
    $url =~ s/\s*$//;

    # channel url - just extract the channel id from the url
    if ($url =~ m{^https?://(?:www\.)?(?:youtube|hooktube)\.com/channel/([^/]*)/?$}i) {
        return $cb->([$1]);
    }

    # feed url (either submerge or youtube) - just extract the channel ids from the url
    if ($url =~ m{/feeds/videos\.xml\?channel_id=(.*)$}i) {
        return $cb->([split /,/, $1]);
    }

    # user page url - fetch the page and extract the channel id from the "canonical" url
    if ($url =~ m{^https?://(?:www\.)?(?:youtube|hooktube)\.com/user/([^/]*)/?$}i) {
        # make sure to fetch from youtube.com to learn the "canonical" url
        $url =~ s/hooktube\.com/youtube.com/gi;
        $ua->get($url => sub {
            my ($ua, $tx) = @_;

            if ($tx->res->body =~ m{<link rel="canonical" href="https?://(?:www\.)?youtube\.com/channel/([^/"]*)/?"}i) {
                return $cb->([$1]);
            } else {
                return $cb->(undef, "Couldn't find canonical URL in user page");
            }
        });
        return;
    }

    # video url
    if ($url =~ m{^https?://(?:www\.)?(?:youtube|hooktube)\.com/watch}i) {
        # make sure to fetch from youtube.com to learn the channel id
        $url =~ s/hooktube\.com/youtube.com/gi;
        $ua->get($url => sub {
            my ($ua, $tx) = @_;

            if ($tx->res->body =~ m{<meta itemprop="channelId" content="([^"]*)">}) {
                return $cb->([$1]);
            } else {
                return $cb->(undef, "Couldn't find channel ID in video page");
            }
        });
        return;
    }

    return $cb->(undef, "Don't recognise the input URL");
}

sub get_feed {
    my ($pkg, $channel_id, $cb) = @_;

    $ua->get('https://www.youtube.com/feeds/videos.xml?channel_id=' . url_escape($channel_id) => sub {
        my ($ua, $tx) = @_;
        my $body = $tx->res->body;

        # processing xml with regex ftw
        $body =~ s/youtube\.com/hooktube.com/g;

        # TODO: replace URLs like https://i3.ytimg.com/vi/nD_6YEXFJ1c/hqdefault.jpg with something that we proxy
        # so as not to leak IP addresses to Google when people view thumbnails (#4)

        $cb->(XML::Feed->parse(\$body));
    });
}

1;
