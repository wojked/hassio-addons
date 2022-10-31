# HomePod Connect

This addons allows to use OwnTone and Spotify Connect with librespot-java on Home Assistant OS.

It is inspired by the OwnTone addon from [a-marcel](https://github.com/a-marcel/hassio-addon-owntone).

As a base the linuxserver/daapd image is used.

## Installation

The addon can be installed by adding this repo to Home Assistant. After that OwnTone Server can be installed through the list of available addons.

## Configuration

(You can use the VSCode addon to customize the configuration.)

You can configure OwnTone through it's configuration file. It can be found at `/config/owntone/owntone.conf`.

Librespot-java is configurable through it's configuration file at `/config/owntone/librespot-java.toml`

After adjusting something, please restart the addon.

## Access OwnTone

You can access OwnTone through `[Home Assistant IP]:3689`

## OwnTone Credentials

Username: `admin`

Password: `owntoneadmin8765`
