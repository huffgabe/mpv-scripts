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
* Added overlay prompts.
* Changed default hotkeys.
* Added a hotkey to skip to the next line without viewing subtitles.
* Removed reading practice mode (might consider bringing it back).

### How to Use
Load a video with subtitles. You can use a video's internal subtitles or load an external subtitle file.

Press `i` to toggle listening practice mode on or off.

When listening practice mode is on, the video will pause at the end of each subtitle line. Try to recall the spoken line, then press `Space` to reveal the subtitle and confirm (or press `g` to play the next line without viewing the subtitle). Press `r` to replay the line, or press `Space` again to continue to the next line.

Tip: Press `g` if you're confident you heard the line correctly. You can press `g` anytime while the line is playing to continue without interruption.