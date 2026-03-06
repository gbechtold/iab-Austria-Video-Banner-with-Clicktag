# IAB Austria Video Banner with Clicktag

IAB Austria compliant HTML5 Video Banners with Sound Control and Clicktag for **Google Ad Manager (GAM)**.

## Repository Structure

```
├── gam-compliant/              # Google Ad Manager compatible templates (recommended)
│   ├── 300x250.html            # Medium Rectangle
│   ├── 300x600.html            # Half Page Ad
│   ├── 728x90.html             # Leaderboard
│   ├── 920x250.html            # Billboard
│   └── build-banners.sh        # Batch build script (ffmpeg + ZIP packaging)
├── 300x250.html                # Legacy: jQuery-based (vol.at AdServer)
├── 300x600.html                # Legacy: jQuery-based
├── 600x500.html                # Legacy: jQuery-based
├── 640x256.html                # Legacy: jQuery-based
├── 970x250.html                # Legacy: jQuery-based
├── UH24-Desktop-Version_*.html # Legacy: Font Awesome + URI params
└── UH24-Mobile-Version_*.html  # Legacy: Font Awesome + URI params
```

## Quick Start

### Option 1: Use a template directly

1. Copy the HTML from `gam-compliant/` for your banner size
2. Replace `video.mp4` with your video file
3. Replace `fallback.jpg` with a static fallback image (first frame)
4. Update the `clickTag` URL in the `<head>`
5. ZIP together: `index.html` + `video.mp4` + `fallback.jpg`
6. Upload ZIP to Google Ad Manager

### Option 2: Use the build script

1. Place your source MP4 videos in `gam-compliant/`
2. Edit `build-banners.sh` — configure the `BANNERS` array and `CLICKTAG_URL`
3. Run: `./build-banners.sh`
4. Upload the generated ZIPs from `output/` to GAM

**Prerequisites:** `ffmpeg` (`brew install ffmpeg` on macOS)

## Google Ad Manager ClickTag Implementation

### The correct way (GAM-compliant)

Google Ad Manager scans your HTML for a specific pattern. The `clickTag` variable **must** be declared as a global variable in the `<head>`:

```html
<head>
  <meta name="ad.size" content="width=300,height=250">
  <script type="text/javascript">
    var clickTag = "https://www.example.com";
  </script>
</head>
```

The click handler **must** use `window.open(window.clickTag)`:

```javascript
document.getElementById('ct').addEventListener('click', function() {
  window.open(window.clickTag);
});
```

GAM will override the default URL with the click-through URL configured in the creative settings.

### Common mistakes that cause "Missing ClickTag" errors

| Mistake | Why it fails |
|---------|-------------|
| `var clickTag` inside `<body>` | GAM scans `<head>` for the variable |
| `getUriParams.clicktag` | GAM doesn't recognize dynamic URI param parsing as a clickTag |
| `clickTag` inside an IIFE/closure | GAM needs it as a **global** variable |
| Minified/obfuscated clickTag code | GAM cannot parse minified variable declarations |
| Missing `<meta name="ad.size">` | GAM needs this to detect banner dimensions |

### Testing locally

Open the HTML file in a browser and append `?clickTag=https://google.com`:

```
file:///path/to/banner/index.html?clickTag=https://google.com
```

Click the banner — it should open Google in a new tab.

### Validation tools

- [HTML5 Validator (Google)](https://h5validator.appspot.com/adwords/asset)
- [Rich Media Gallery Validator](https://www.google.com/webdesigner/galleryassets/html5/dcm-enabler/validator.html)

## IAB Austria Compliance Checklist

- [x] **Auto-muted:** Video starts muted (`muted` attribute)
- [x] **Autoplay:** Video plays automatically (`autoplay` attribute)
- [x] **Loop:** Video loops continuously (`loop` attribute)
- [x] **Inline playback:** No fullscreen on mobile (`playsinline` attribute)
- [x] **Sound control:** Mute/unmute button with visual feedback (SVG icons)
- [x] **Click tracking:** `clickTag` variable for AdServer URL injection
- [x] **Fallback image:** Static image shown when video fails to load
- [x] **No external dependencies:** Pure HTML/CSS/JS, no jQuery or CDN required
- [x] **Accessible:** Mute button has `title` attribute

## Template Architecture

### Z-Index Stacking Order

```
z-index: 90      → Fallback image (hidden by default)
z-index: 100     → Video element
z-index: 9999    → Click overlay (#ct) — captures clicks for clickTag
z-index: 10000   → Mute button — above click overlay, uses stopPropagation()
```

### Key Design Decisions

**All elements inside `#contentWrapper`:** The video, fallback image, click overlay, and mute button are all children of a single `position: relative` container. This ensures correct z-index stacking across all banner sizes and prevents positioning bugs on narrow banners (e.g. 728x90).

**No `transform` on positioned elements:** CSS `transform` creates a new stacking context, which can break z-index hierarchies. The mute button uses calculated `top` values instead of `transform: translateY(-50%)`.

**Inline SVG icons:** No external icon libraries (Font Awesome, etc.) — the mute/unmute icons are inline SVGs. This keeps the banner self-contained and avoids additional HTTP requests.

**`background: transparent` on click overlay:** Ensures the invisible overlay reliably captures click events across all browsers.

### Video Encoding Settings

The build script encodes videos with these settings for maximum compatibility:

```
H.264 Baseline Profile, Level 3.0
CRF 23 (good quality/size balance)
YUV 4:2:0 pixel format
faststart (metadata at beginning for streaming)
No audio track
```

### Adaptive Mute Button Positioning

| Banner Type | Position | Example Sizes |
|------------|----------|---------------|
| Tall (h >= w) | Bottom-left | 300x600 |
| Flat (h <= 100px) | Right, vertically centered | 728x90 |
| Normal | Top-left | 300x250, 920x250 |

## Available Sizes

### GAM-Compliant Templates (recommended)

| Size | IAB Name | File |
|------|----------|------|
| 300x250 | Medium Rectangle | `gam-compliant/300x250.html` |
| 300x600 | Half Page Ad | `gam-compliant/300x600.html` |
| 728x90 | Leaderboard | `gam-compliant/728x90.html` |
| 920x250 | Billboard | `gam-compliant/920x250.html` |

### Legacy Templates (jQuery / Font Awesome)

| Size | File | Dependencies |
|------|------|-------------|
| 300x250 | `300x250.html` | jQuery, Modernizr, vol.at plugin |
| 300x600 | `300x600.html` | jQuery, Modernizr, vol.at plugin |
| 600x500 | `600x500.html` | jQuery, Modernizr, vol.at plugin |
| 640x256 | `640x256.html` | jQuery, Modernizr, vol.at plugin |
| 970x250 | `970x250.html` | jQuery, Modernizr, vol.at plugin |
| 1920x1080 | `UH24-Desktop-Version_1920x1080.html` | Font Awesome CDN |
| 1080x1920 | `UH24-Mobile-Version_1080x1920.html` | Font Awesome CDN |
| 600x500 | `UH24-Mobile-Version_600x500.html` | Font Awesome CDN |

## Reference Links

- [HTML5 Guidelines for Ad Manager](https://support.google.com/admanager/answer/7046799)
- [Traffic HTML5 Creatives in GAM](https://support.google.com/admanager/answer/7046902)
- [IAB Austria Standards](https://www.iab-austria.at)
- [Google Web Designer](https://webdesigner.withgoogle.com)
- [Genecy: Prepare HTML5 ads for GAM](https://www.genecy.com/resources/25-how-to-prepare-an-html5-ad-with-click-tracking-for-google-ad-manager-formerly-doubleclick-for-publishers/)

## Project Origin

Originally created for [#UH24 Hackathon](https://digitaleinitiativen.at/initiativen/ummahuesla-hackathon/).
GAM-compliant templates added by [Stars Media](https://www.starsmedia.com).

## License

This project is provided as-is for educational and commercial use. Ensure compliance with IAB Austria guidelines and local advertising regulations when deploying.
