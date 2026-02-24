#!/usr/bin/env bash

set -euo pipefail

########################################
# CONFIG
########################################

BASE_MUSIC="$HOME/media/music"
BASE_VIDEO="$HOME/media/video"

########################################
# REQUIREMENTS CHECK
########################################

if ! command -v yt-dlp &>/dev/null; then
  echo "Error: yt-dlp is not installed."
  echo "Install with:"
  echo "  Fedora/Bazzite: sudo dnf install yt-dlp"
  echo "  Or: pip install -U yt-dlp"
  exit 1
fi

########################################
# DOWNLOAD FUNCTIONS
########################################

ytmp3() {
  yt-dlp \
    -x \
    --audio-format mp3 \
    --embed-metadata \
    --embed-thumbnail \
    --ignore-errors \
    --no-overwrites \
    --concurrent-fragments 8 \
    -o "%(playlist_index)02d.%(title)s.%(ext)s" \
    "$@"
}

ytv() {
  yt-dlp \
    -f "bv*+ba/b" \
    --ignore-errors \
    --no-overwrites \
    --concurrent-fragments 8 \
    -o "%(playlist_index)02d.%(title)s.%(ext)s" \
    "$@"
}

########################################
# BULK DOWNLOADER
########################################

ytbulk() {
  echo "What type of download?"
  echo "1) music"
  echo "2) video"
  read -rp "Enter choice (music/video): " media_type

  case "$media_type" in
  music)
    BASE_DIR="$BASE_MUSIC"
    DOWNLOAD_CMD="ytmp3"
    ;;
  video)
    BASE_DIR="$BASE_VIDEO"
    DOWNLOAD_CMD="ytv"
    ;;
  *)
    echo "Invalid choice."
    return 1
    ;;
  esac

  read -rp "How many directories would you like to create? " dir_count

  if ! [[ "$dir_count" =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number."
    return 1
  fi

  declare -a dirs
  declare -a links

  for ((i = 1; i <= dir_count; i++)); do
    read -rp "Name/path for directory $i (relative to $BASE_DIR): " dir_name
    dirs+=("$dir_name")
  done

  for dir in "${dirs[@]}"; do
    read -rp "Enter YouTube link for $dir: " link
    links+=("$link")
  done

  echo ""
  echo "========== CONFIRMATION =========="
  echo "Media Type: $media_type"
  echo "Base Directory: $BASE_DIR"
  echo ""

  for ((i = 0; i < ${#dirs[@]}; i++)); do
    echo "Directory: $BASE_DIR/${dirs[$i]}"
    echo "Link:      ${links[$i]}"
    echo ""
  done

  read -rp "Proceed? (y/n): " confirm
  [[ "$confirm" != "y" ]] && {
    echo "Aborted."
    return 0
  }

  mkdir -p "$BASE_DIR"

  ########################################
  # CREATE DIRECTORIES
  ########################################

  for dir in "${dirs[@]}"; do
    mkdir -p "$BASE_DIR/$dir" || {
      echo "Failed creating $BASE_DIR/$dir"
      return 1
    }
  done

  ########################################
  # PARALLEL DOWNLOADS
  ########################################

  for ((i = 0; i < ${#dirs[@]}; i++)); do
    (
      target_dir="$BASE_DIR/${dirs[$i]}"
      link="${links[$i]}"

      echo "Downloading into $target_dir..."

      cd "$target_dir" || {
        echo "Failed to enter $target_dir — skipping"
        exit 0
      }

      "$DOWNLOAD_CMD" "$link" ||
        echo "Warning: Some items failed in $link — continuing"
    ) &
  done

  wait
  echo ""
  echo "All downloads complete."
}

########################################
# RUN
########################################

ytbulk
