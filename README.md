# mpv scripts
## sub-copy
Copies the currently displayed subtitle to the clipboard with Ctrl+C (Windows only). Adapted from [mpvacious](https://github.com/Ajatt-Tools/mpvacious/blob/windows/subs2srs.lua). 

### Changes
* Made it possible to copy subtitles with multiple lines.
* Added a message to confirm the subtitle was copied.

## sub-voracious
Pause after each subtitle line to test your listening. Original: [sub-voracious](https://github.com/kelciour/mpv-scripts/blob/master/sub-voracious.lua).

### Changes
* Works with any subtitle file, including internal subtitles. External files can have any name and be from any location.
* Supports adjustments to the sub delay.
* Removed reading practice mode.

### How to Use
Load a video with subtitles. You can use a video's internal subtitles or load an external subtitle file.

Press `i` to toggle listening practice mode on or off.

When listening practice mode is on, the video will pause at the end of each subtitle line. Try to recall the spoken line, then press &#8595; (or `Space`) to reveal the subtitle and confirm. Press &#8593; to replay the line, or press &#8595; (or `Space`) again to continue to the next line.