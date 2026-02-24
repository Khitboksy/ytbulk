
# ytbulk

A simple Bash script to bulk download YouTube music and videos into organized  
directories, using `yt-dlp` and`ffmpeg`. -- i took my fish function and told chatgpt to make it bash. sue me.

## Dependencies

Make sure `yt-dlp` and `ffmpeg` are installed on your system  
(`yt-dlp` handles downloading from YouTube, and `ffmpeg` is used for audio conversion.):

Fedora

```sh
sudo dnf install yt-dlp ffmpeg
```

## Installation

You can install `ytbulk` with a single command:

```sh
mkdir -p ~/.local/bin &&
curl -sLo ~/.local/bin/ytbulk <https://raw.githubusercontent.com/>
<Khitboksy>/ytbulk/main/ytbulk.sh &&
chmod +x ~/.local/bin/ytbulk
```

## Usage

Once installed, simply open a terminal and run:

```sh
ytbulk
```

Follow the prompts:

Choose whether to download music or video.

Specify how many directories you want.

Enter directory names relative to the base folder (~/media/music or ~/media/video).

Enter YouTube links for each directory.

Confirm and let the script handle downloads.

All tracks in playlists are automatically numbered and saved in the specified directories.
