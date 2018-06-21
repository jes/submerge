package Submerge::DB;

use strict;
use warnings;

use DBI;

my $DBH;

sub dbh {
    if (!$DBH || !$DBH->ping) {
        $DBH = DBI->connect("DBI:SQLite:dbname=submerge.db", "", "", {
            RaiseError => 1,
        });

        # create tables that we need
        if (0 && !table_exists($DBH, 'subscriptions')) {
            $DBH->do(qq{
                CREATE TABLE subscriptions (id integer primary key, token text, channel_id text)
            });
            $DBH->do(qq{
                CREATE INDEX tokenidx ON subscriptions(token)
            });
        }

        if (0 && !table_exists($DBH, 'channel_names')) {
            $DBH->do(qq{
                CREATE TABLE channel_names (channel_id text primary key, name text)
            });
        }
    }
    return $DBH;
}

sub table_exists {
    my ($dbh, $table) = @_;

    my $sth = $dbh->table_info(undef, 'public', $table, 'TABLE');

    $sth->execute;
    my @info = $sth->fetchrow_array;

    my $exists = scalar @info;
    return $exists;
}

1;
