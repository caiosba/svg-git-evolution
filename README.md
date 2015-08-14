## svg-git-evolution.sh

A Bash script that generates a video (.mp4) that shows the different versions of an SVG image inside a Git repository,
with the version date (e.g., the commit date) printed on it. One version fades out and the next one fades in.
This way, the generated video basically shows the evolution of an SVG image (hence the name).
Works even if the file was moved, renamed or copied from some other file (it relies on `git log --follow` for that).
This script could be easily generalized to work with any image, not only SVG (but probably the above wouldn't be true).

### Example

Check example.mp4, generated automatically from a Github repository.

### Dependencies

You need the following: git, inkscape, imagemagick, mktemp and ffmpeg (a recent version that supports `filter_complex`).

### TODO

A lot of customizations could be done, besides generalizations and more. Pull requests welcome!

### Usage

Go to the root of the Git repository where the SVG file is, and run:

`./path/to/svg-git-evolution.sh <path to SVG inside Git repository> <video size (WxH, default 800x600)> <image duration (seconds, default 5)> <effect (fade|default)`

Output will be at `<input file name>.mp4`.

### Credit

Caio SBA <caiosba@gmail.com>
