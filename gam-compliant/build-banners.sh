#!/bin/bash
# =============================================================================
# HTML5 Video Banner Builder for Google Ad Manager
# IAB Austria compliant | Generates ZIP packages ready for GAM upload
#
# Usage:
#   ./build-banners.sh
#
# Prerequisites:
#   - ffmpeg installed (brew install ffmpeg)
#   - Source MP4 videos in the same directory
#
# Configuration:
#   Edit the BANNERS array below. Format:
#   "source_video.mp4|width|height|output_name"
#
# The script will:
#   1. Re-encode videos to target dimensions (H.264 Baseline, no audio)
#   2. Extract first frame as fallback JPG
#   3. Generate IAB/GAM-compliant HTML5 wrapper
#   4. Package everything as ZIP for GAM upload
# =============================================================================
set -e

BASEDIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="$BASEDIR/output"
CLICKTAG_URL="https://www.example.com"

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

# Configure your banners here:
# "source_filename.mp4|target_width|target_height|output_name"
BANNERS=(
  "my-video.mp4|300|250|Campaign_300x250"
  "my-video.mp4|728|90|Campaign_728x90"
  "my-video.mp4|300|600|Campaign_300x600"
  "my-video.mp4|920|250|Campaign_920x250"
)

# Determine mute button position based on banner dimensions
get_button_style() {
  local w=$1 h=$2
  if [ "$h" -ge "$w" ]; then
    # Tall banner (e.g. 300x600) - button bottom-left
    echo "bottom: 8px; left: 8px;"
  elif [ "$h" -le 100 ]; then
    # Flat banner (e.g. 728x90) - button right, vertically centered
    local btnTop=$(( (h - 24) / 2 ))
    echo "top: ${btnTop}px; right: 8px;"
  else
    # Normal banner - button top-left
    echo "top: 8px; left: 8px;"
  fi
}

for entry in "${BANNERS[@]}"; do
  IFS='|' read -r filename width height name <<< "$entry"
  echo "Processing: $name (${width}x${height})"

  BANNERDIR="$OUTDIR/$name"
  mkdir -p "$BANNERDIR"

  # Re-encode video to target size
  ffmpeg -y -i "$BASEDIR/$filename" \
    -vf "scale=${width}:${height}" \
    -c:v libx264 -preset slow -crf 23 \
    -profile:v baseline -level 3.0 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    -an \
    "$BANNERDIR/video.mp4" 2>/dev/null

  # Extract first frame as fallback
  ffmpeg -y -i "$BANNERDIR/video.mp4" \
    -vframes 1 -q:v 3 \
    "$BANNERDIR/fallback.jpg" 2>/dev/null

  VIDEOSIZE=$(stat -f%z "$BANNERDIR/video.mp4" 2>/dev/null || stat -c%s "$BANNERDIR/video.mp4")
  echo "  Video: $((VIDEOSIZE / 1024))KB"

  BTNSTYLE=$(get_button_style "$width" "$height")

  if [ "$height" -le 100 ]; then
    ICONSIZE="16"; BTNSIZE="24"
  else
    ICONSIZE="20"; BTNSIZE="30"
  fi

  # Generate IAB/GAM-compliant HTML5
  cat > "$BANNERDIR/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="ad.size" content="width=${width},height=${height}">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>${name}</title>
<script type="text/javascript">
var clickTag = "${CLICKTAG_URL}";
</script>
<style>
html, body {
  width: ${width}px;
  height: ${height}px;
  margin: 0;
  padding: 0;
  overflow: hidden;
  background: #000;
}
#contentWrapper {
  position: relative;
  width: ${width}px;
  height: ${height}px;
}
#video {
  position: absolute;
  top: 0;
  left: 0;
  width: ${width}px;
  height: ${height}px;
  z-index: 100;
  border: 0;
  object-fit: cover;
}
.fallback-image {
  position: absolute;
  top: 0;
  left: 0;
  width: ${width}px;
  height: ${height}px;
  z-index: 90;
  display: none;
  object-fit: cover;
}
#ct {
  width: ${width}px;
  height: ${height}px;
  z-index: 9999;
  position: absolute;
  top: 0;
  left: 0;
  cursor: pointer;
  background: transparent;
}
#muteBtn {
  position: absolute;
  z-index: 10000;
  ${BTNSTYLE}
  width: ${BTNSIZE}px;
  height: ${BTNSIZE}px;
  background: rgba(0,0,0,0.5);
  border: none;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.7;
  transition: opacity 0.2s;
  padding: 0;
}
#muteBtn:hover {
  opacity: 1;
}
#muteBtn svg {
  width: ${ICONSIZE}px;
  height: ${ICONSIZE}px;
  fill: #fff;
}
</style>
</head>
<body>
<div id="contentWrapper">
  <video id="video" width="${width}" height="${height}"
         controlsList="nodownload" autoplay autobuffer loop muted
         playsinline preload="metadata">
    <source src="video.mp4" type="video/mp4">
  </video>
  <img src="fallback.jpg" alt="Banner" class="fallback-image" id="fallbackImg">
  <div id="ct"></div>
  <button id="muteBtn" title="Ton ein/aus">
    <svg id="iconMuted" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4L9.91 6.09 12 8.18V4z"/>
    </svg>
    <svg id="iconUnmuted" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" style="display:none;">
      <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/>
    </svg>
  </button>
</div>

<script type="text/javascript">
(function() {
  var video = document.getElementById('video');
  var fallback = document.getElementById('fallbackImg');
  var muteBtn = document.getElementById('muteBtn');
  var iconMuted = document.getElementById('iconMuted');
  var iconUnmuted = document.getElementById('iconUnmuted');
  var ct = document.getElementById('ct');

  video.volume = 0.65;
  video.play().catch(function() {
    fallback.style.display = 'block';
  });

  video.addEventListener('error', function() {
    fallback.style.display = 'block';
  });

  muteBtn.addEventListener('click', function(e) {
    e.stopPropagation();
    e.preventDefault();
    if (video.muted) {
      video.muted = false;
      iconMuted.style.display = 'none';
      iconUnmuted.style.display = 'block';
    } else {
      video.muted = true;
      iconMuted.style.display = 'block';
      iconUnmuted.style.display = 'none';
    }
  });

  ct.addEventListener('click', function() {
    window.open(window.clickTag);
  });
})();
</script>
</body>
</html>
HTMLEOF

  # Package as ZIP
  cd "$OUTDIR"
  zip -j "${name}.zip" "$BANNERDIR/index.html" "$BANNERDIR/video.mp4" "$BANNERDIR/fallback.jpg" >/dev/null
  ZIPSIZE=$(stat -f%z "$OUTDIR/${name}.zip" 2>/dev/null || stat -c%s "$OUTDIR/${name}.zip")
  echo "  ZIP: $((ZIPSIZE / 1024))KB"
  echo ""
done

echo "=== DONE ==="
echo "All banner ZIPs are in: $OUTDIR"
ls -lh "$OUTDIR"/*.zip
