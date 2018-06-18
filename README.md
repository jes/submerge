![Submerge](public/submerge.png)

Subscribe to YouTube channels without telling Google.

## Description

There's lots of good content on YouTube, but actively using YouTube allows Google to track too much personal information.

[HookTube](https://hooktube.com/) is an alternative YouTube user interface that lets you watch the videos with less of the tracking, but HookTube doesn't yet support subscriptions.

Submerge lets you subscribe to YouTube channels, with the player links going directly to HookTube.

There's a public instance available at [submerge.io](https://submerge.io/), or you can self-host.

## Roadmap

This is still a work in progress. Currently it works well enough to provide combined RSS feeds of multiple channels.

Next steps are:

1. A public-facing index page to explain what the project is about.

2. A user interface to browse your subscriptions without having to go via the RSS reader.

3. Bulk-import subscriptions from YouTube

4. A way to update your subscriptions without having to update the feed URL in the RSS reader.

If it gets popular, longer-term goals would include:

* a caching layer so that popular requests don't get the public instance banned from YouTube

* make it easier for people to run a private instance (or even an alternative public instance!) so that my public instance doesn't accumulate too much data to track people with

## Installation

It's a [Mojolicious](https://mojolicious.org/) application. On Ubuntu, you should be able to install the dependencies with:

    sudo apt install cpanminus libxml2-dev
    sudo cpanm Mojolicious XML::Feed YAML

There's not yet a systemd unit file, but you can run it in development mode with:

    morbo submerge

or in production mode with:

    hypnotoad submerge

When running in production mode you'll need to copy development.yaml to production.yaml and edit it accordingly.

## Contact

Please send feedback to james@incoherency.co.uk

Bug reports, patches, etc. welcome at https://github.com/jes/submerge
