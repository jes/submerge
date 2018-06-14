# Submerge

## Description

There's lots of good content on YouTube, but actively using YouTube allows Google to track too much personal information.

[HookTube](https://hooktube.com/) is an alternative YouTube user interface that lets you watch the videos with less of the tracking, but HookTube doesn't yet support subscriptions.

Submerge lets you subscribe to YouTube channels, with the player links going directly to HookTube.

## Roadmap

This is a work in progress. Currently it works well enough to provide individual RSS feeds of single channels.

Next steps are:

1. A public instance and public-facing index page to explain what the project is about.

2. A way to combine several feeds together so that you can subscribe to multiple channels with just one URL.

3. A user interface to browse your subscriptions without having to go via the RSS reader.

Longer-term goals would include:

* a caching layer so that popular requests don't get the public instance banned from YouTube

* make it easy for people to run a private instance so that the public instance doesn't accumulate too much data to track people with

## Installation

It's a [Mojolicious](https://mojolicious.org/) application. There's not yet a systemd unit file, but you can run it in
development mode with:

  morbo submerge

or in production mode with:

  hypnotoad submerge

When running in production mode you'll need to copy development.yaml to production.yaml and edit it accordingly.

## Contact

Please send feedback to james@incoherency.co.uk

Bug reports, patches, etc. welcome at https://github.com/jes/submerge
