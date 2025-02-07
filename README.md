<blockquote>
  <details>
    <summary>
      <code>あ ←→ A</code>
    </summary>
    <!--Head-->
    &emsp;&ensp;<sub><b>Melodic Stamp</b> supports the following languages. <a href="/Doc/ADD_A_LOCALIZATION.md"><code>↗ Add a localization</code></a></sub>
    <br />
    <!--Body-->
    <br />
    &emsp;&ensp;English
    <br />
    &emsp;&ensp;<a href="/Doc/简体中文.md">简体中文</a>
  </details>
</blockquote>

<div align="center">
  <img width="225" height="225" src="/MelodicStamp/Assets.xcassets/AppIcon.appiconset/icon_512x512%402x.png" alt="Logo">
  <h1><b>Melodic Stamp</b></h1>
  <p>The very choise to play and edit your local audio files, elegantly.<br>
</div>

> [!IMPORTANT]
> **Melodic Stamp** requires **macOS 15.0 Sequoia**[^check_your_macos_version] or above to run.

[^check_your_macos_version]: [`↗ Find out which macOS your Mac is using`](https://support.apple.com/en-us/HT201260)

## Overview

**Melodic Stamp** is a music player designed to provide a brand new experience in local music managing and audio metadata editing.
Through an intuitive and elegant interface, you can easily browse and play [various audio formats.](#supported-audio-formats)

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewPlaylist_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewPlaylist_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

**Melodic Stamp** also introduces some finely designed interfaces to entertain your journey of music appreciation, such as the ultra smooth lyrics page that comes along with the support of [multiple lyrics formats.](#supported-lyrics-formats)
What's more, it will always be free and open sourced!

### Supported Audio Formats

**Melodic Stamp** is driven by [SFBAudioEngine,](https://github.com/sbooth/SFBAudioEngine) which supports the following audio formats:

- WAV
- AIFF
- CAF
- MP3
- AAC
- m4a
- [FLAC](https://xiph.org/flac)
- [Ogg Opus](https://opus-codec.org)
- [Ogg Speex](https://www.speex.org)
- [Ogg Vorbis](https://xiph.org/vorbis)
- [Monkey's Audio](https://www.monkeysaudio.com)
- [Musepack](https://www.musepack.net)
- Shorten
- True Audio
- [WavPack](http://www.wavpack.com)
- All formats supported by [libsndfile](http://libsndfile.github.io/libsndfile)

### Supported Lyrics Formats

**Melodic Stamp** extracts and parses lyrics from audio metadata into multiple formats for you. The following formats are supported:

- [LRC](https://en.wikipedia.org/wiki/LRC_(file_format))[^extended_lrc_features]
- [TTML](https://en.wikipedia.org/wiki/Timed_Text_Markup_Language)
- Plain text (also the fallback solution for other unsupported formats)

[^extended_lrc_features]: **Melodic Stamp** only accepts some trivial fellow translation lines beyond the original LRC format specification. Other extensions of the LRC format will be parsed as plain LRC lyric lines.

## Features

## Screenshots

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewTabBar_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewTabBar_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewLeaflet1_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewLeaflet1_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
  <p>Show Slay Show<br />ChiliChili</p>
</div>


<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewInspector1_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewInspector1_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewInspector2_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewInspector2_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewInspector3_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewInspector3_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewInspector4_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewInspector4_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMiniPlayerView1_dark.png?raw=true">
    <img src="/Doc/Overview/MSMiniPlayerView1_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

## Install & Run

> [!NOTE]
> Currently, **Melodic Stamp** is still in active development. Therefore, you cannot install **Melodic Stamp** directly from the App Store. At the same time, you may also need to allow **Melodic Stamp** to run as an unauthenticated application[^open_as_unidentified].
>
> For now, you can only download the compressed application file of **Melodic Stamp** from the [Releases](https://github.com/Cement-Labs/MelodicStamp/releases) page.

[^open_as_unidentified]: [`↗ Open a Mac app from an unidentified developer`](https://support.apple.com/guide/mac-help/mh40616/mac)
