<blockquote>
  <details>
    <summary>
      <code>あ ←→ A</code>
    </summary>
    <!--Head-->
    &emsp;&ensp;<sub><b>Melodic Stamp</b> supports the following languages. <a href="/Docs/ADD_A_LOCALIZATION.md"><code>↗ Add a localization</code></a></sub>
    <br />
    <!--Body-->
    <br />
    &emsp;&ensp;English
    <br />
    &emsp;&ensp;<a href="/Docs/简体中文.md">简体中文</a>
  </details>
</blockquote>

<div align="center">
  <img width="225" height="225" src="/MelodicStamp/Assets.xcassets/AppIcon.appiconset/icon_512x512%402x.png" alt="Logo">
  <h1><b>Melodic Stamp</b></h1>
  <p> A new way to listen and edit music <br>
</div>

> [!IMPORTANT]
> **Melodic Stamp** requires **macOS 15.0 Sequoia**[^check_your_macos_version] or above to run.

> [^check_your_macos_version]: [`↗ Find out which macOS your Mac is using`](https://support.apple.com/en-us/HT201260)

## Learn about Melodic Stamp
**Melodic Stamp** is a macOS application designed to provide a brand new experience in music appreciation and audio metadata editing. Through an intuitive and elegant interface, users can easily browse and play various audio formats while enjoying high-quality sound effects. The application supports multiple audio formats, including WAV, MP3, AAC, Opus, etc., to meet the needs of different users. Whether it's for fine-grained metadata editing of songs or customizing playlists, Melodic Stamp can provide you with powerful and flexible functions. At the same time, the application also supports batch processing of audio files to help you efficiently manage your music library.

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewPlaylist_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewPlaylist_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

## Format Support
**Melodic Stamp** Driven by [SFBAudioEngine](https://github.com/sbooth/SFBAudioEngine), it supports multiple formats including:
* WAV
* AIFF
* CAF
* MP3
* AAC
* m4a
* [FLAC](https://xiph.org/flac/)
* [Ogg Opus](https://opus-codec.org)
* [Ogg Speex](https://www.speex.org)
* [Ogg Vorbis](https://xiph.org/vorbis/)
* [Monkey's Audio](https://www.monkeysaudio.com)
* [Musepack](https://www.musepack.net)
* Shorten
* True Audio
* [WavPack](http://www.wavpack.com)
* All formats supported by [libsndfile](http://libsndfile.github.io/libsndfile/)

## User Manual
The functions of **Melodic Stamp** are expanded based on the tab bar on the side of the window - **Content Panel** and **Inspector Panel**:
### Content Panel:
- **Playlist**&emsp;In this area, the currently opened playlists will be displayed.
- **Leaflet**&emsp;In this area, the real-time lyrics of the currently playing song will be displayed.
  
### Inspector Panel:
- **Common Information**&emsp;In this area, basic metadata editing of songs will be supported.
- **Advanced Information**&emsp;In this area, advanced metadata for editing songs will be supported.
- **Lyrics**&emsp;In this area, editing and viewing of song lyrics information will be supported.
- **Library**&emsp;In this area, your saved playlists will be displayed.
  
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewTabBar_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewTabBar_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

## Interface preview
### Leaflet
Leaflet page supports displaying **LRC** and **TTML** lyrics.
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewLeaflet1_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewLeaflet1_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
  <p> ChiliChill - Show Slay Show <br>
</div>

### Common
Basic Information page can edit information such as cover, title, artist, composer, album, etc.
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewInspector1_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewInspector1_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

### Advanced
Additional Information page can edit information such as rating, comment, release date, copyright information, etc.
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewInspector2_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewInspector2_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

### Lyrics
Lyrics page can view and edit lyrics, and supports parsing and previewing of **LRC** and **TTML** lyrics.
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewInspector3_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewInspector3_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>

### Library
Resource library. You can view the playlists you have saved.
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="/Doc/Overview/MSMainViewInspector4_dark.png?raw=true">
    <img src="/Doc/Overview/MSMainViewInspector4_light.png?raw=true" width="750" alt="Playlist Image">
  </picture>
</div>
