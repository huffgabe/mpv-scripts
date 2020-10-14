# mpv scripts
## sub-copy
Copies the currently displayed subtitle to the clipboard with Ctrl+C (Windows only). Adapted from [mpvacious](https://github.com/Ajatt-Tools/mpvacious/blob/windows/subs2srs.lua). 

### Changes:
* Made it possible to copy subtitles with multiple lines.
* Added a message to confirm the subtitle was copied.

### Todo:
* Find a better way to copy multi-line subtitles. Right now it just replaces the newlines with spaces.

## sub-voracious

Pause after each subtitle line to test your listening. Original: [sub-voracious](https://github.com/kelciour/mpv-scripts/blob/master/sub-voracious.lua).

### Changes:
* Some srt files have whitespace after the timestamps. The original script would fail to parse these.
* Removed reading practice mode.

### Todo:
* Support changes to the sub delay.
* Load sub files that don't have the same name as the video file.
* Have a better way of stripping whitespace.
* Add messages when e.g. subtitle fail to load instead of failing silently.
* User-configurable subtitle padding.
* Add prompts.