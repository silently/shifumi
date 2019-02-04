# Shifumi

Rock Paper Scissors-like game (also known as Shifumi in France) to showcase Elixir/Phoenix and channels, in the context of a simple synced game with possibly many players. Client-side is done with React/Redux (as a progressive web app).

## Installation

After cloning, one will need to create OAuth apps with at least one OAuth provider used in this project (namely Facebook, Google, Twitter or Github), and then provide the relevant client id and secret as environment variables, as seen in *config/config.exs*

## Project Documentation

```
$ mix deps.get
$ mix docs
```

And then open `doc/index.html`.

## Developing

When working on the front-end code, one may want to disable the Service Worker (and its caching effects on JS assets for instance) in the browser dev tools settings.

## Overview

### Channels

- PlayerChannel is a private per-player channel, up till the player is online
- GameChannel is a per-game channel for 2 players

### Contexts

- People: for dealing with players, how they authenticate and how they relate to each other (through *Dating*)
- Records: used to process, save and aggregate statistics of players and games
- Engine: game server GenServer implementation and related modules (no DB persistence layer here)

### Assigns

- on *conn* is assigned the Player schema
- on *socket* is assigned only the player_id since socket is persisting and the player struct may change, so we do not want to have it cached

### Front-End

- the *menu* namespace fits with HTTP communication, possibly intercepted by a service worker
- the *play* namespace fits with socket communication

The way sequencing works on the front-end may be disturbing since there are several sources/causes of events:

- server-side ticking (mainly the *game_new_round* and *game_end* channel pushes)
- front-end sequencing in sequencer.js
- some timeout/callbacks in React component by themselves for minor display in-context sequencing

And they are also several ways to deal with graphical sequencing: JS/React, CSS animations, CSS transitions. When refreshing the page, some CSS effects may be broken until the next server-side ticking push.

### Statistics

Games are analyzed to deliver statistics. Round statistics like winning percentage don't take into account rounds where players have been idle (not throwing any shape).

## Interesting Bits, Oddities

- ~100 tests

- Game protocol through channels

- Dating: at first its intended behaviour was to avoid matches between 2 players that have played together a recent match. This limitation has been removed (see "DEPRECATED" in code comments) for test purposes, but some oddities may remain in the way this module has been thought

- React/Redux/PWA app

- Having the Service Worker cache and the digest one (`mix phx.digest` in production) work together both in dev and prod environment

- Using both rollup.js for JavaScript (tree-shaking + personal preference for configuration) and Brunch for CSS and static files/images (rollup seems weird regarding handling CSS + use of clean-css and sourcemap generation with Brunch)

- Ueberauth example

- File upload with client-side resizing + Mogrify example

- Using PubSub.subscribe in Shifumi.People.Dating#init/1 (so outside the context of a Channel) so that disconnections imply players moving from the "ready" pool to the "leaving" one

- CSS animations and transitions

- Demo is hosted on a $5/month droplet: https://shifumi.alt-g.fr/

## Enhancements?

### Known issues

- client-side l10n needed

- not tested on many devices, design/UX problems may appear

- If the same player connects twice, playing will be synced on all devices. The wished behavior has to be defined, for instance does reconnecting should disconnect from previous devices?

- Player existence is tested two times: when logging in and on socket connection. Maybe the first check is enough in normal usage, but during development it's possible to reset the DB and have stale connections opened in browsers

### Dating & Presence

For the moment, a single Shifumi.People.Dating process is responsible of connecting players to start matches, maybe this is a bottleneck. Related ideas:

- possibility to have a pool of Dating servers rather than a singleton?

- add randomness (wait a few seconds and select a random ready player)

### Optimization

- Upgrade to HTTP/2

- GameRegistry: periodical cleanup? (in case dead pid are still registered... I am not sure it would be a perf penalty anyway, but surely a memory usage one)

- Serve static assets from nginx

- Use preact? message pack instead of JSON?

### Testing

- Test channels with a truly separate websocket client, not using Phoenix test helpers?

### Front-end

- Sequencer could be implemented using a state machine.

### Friends

- Friends list & invitation workflow to be imagined and developed

- And then play private matches, with specific statistics ("you win xx% of the time against yy")
