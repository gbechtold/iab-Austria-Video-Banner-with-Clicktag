# iab-Austria-Video-Banner-with-Clicktag

IAB Austria compliant HTML5 Video Banner with Sound on/off Feature

This repository hosts the code for an IAB Austria compliant HTML5 video banner. The banner includes a responsive design that adapts to various display sizes and a user-friendly interface allowing viewers to toggle sound on and off. The banner is optimized for high performance across desktop and mobile platforms, ensuring a seamless user experience while meeting all IAB Austria advertising standards.

## Features

- **Responsive Design:** Automatically adjusts to fit the size of the viewing device.
- **Sound Control:** Includes a mute/unmute feature, allowing users to control the audio experience.
- **Cross-Platform Compatibility:** Ensures consistent functionality across different browsers and devices.
- **IAB Austria Compliance:** Meets the standards set by the Interactive Advertising Bureau (IAB) Austria for online advertising.
- **Dynamic Clicktag Support:** AdServer-compatible clicktag implementation for tracking and URL redirection.

## Creating Banners with Google Web Designer

This repository includes a pre-built banner template created with Google Web Designer (GWD). You can use GWD to create IAB-compliant HTML5 banners with proper clicktag implementation.

### Quick Start Guide

1. **Install Google Web Designer**
   - Download from [https://webdesigner.withgoogle.com](https://webdesigner.withgoogle.com)
   - Available for macOS, Windows, and Linux

2. **Create a New Banner**
   - Open GWD → **File** → **New**
   - Select **Banner** as project type
   - Choose your target format (e.g., 300×250, 1920×1080)
   - Set environment to **Display & Video 360**

3. **Add Content**
   - Import assets: **File** → **Import Elements** → select images/videos
   - Drag assets onto the canvas
   - Use Timeline (bottom panel) to create animations

4. **Add Clicktag**
   - **Insert** → **Component** → **Tap Area**
   - Resize Tap Area to cover entire banner (full width/height)
   - In Properties panel (right side), set **Exit ID** to `clickTag`
   - Leave **URL** field empty (AdServer will inject the target URL dynamically)

5. **Validate & Export**
   - Check validation panel (left side) for green checkmarks
   - **File** → **Publish** → **Locally**
   - Enable **"Optimize for AdWords/Display & Video 360"**
   - Export as ZIP file

### Example Banner Included

The file `MeinZweiterBanner.zip` in this repository contains a working example with proper clicktag implementation. Extract and inspect the HTML to understand the structure:

```html
<gwd-taparea id="gwd-taparea_1" exit-id="clickTag" class="gwd-taparea-q1bo"></gwd-taparea>
```

### Critical Implementation Notes

**DO NOT hardcode URLs in the clicktag handler.** Incorrect implementation:
```javascript
var clickTag = "https://example.com/"; // WRONG
```

**Correct implementation:** Let GWD generate the handler automatically by setting `exit-id="clickTag"` on the Tap Area component. The `gwdtaparea_min.js` script handles URL injection from AdServer query parameters.

### Testing Your Banner

1. Open the exported HTML in a browser
2. Append `?clickTag=https://google.com` to the URL
3. Click the banner – should redirect to Google
4. If it doesn't work, verify the Tap Area has `exit-id="clickTag"` attribute

### File Size Limits

- **IAB Standard:** Max 150-200 KB (depending on AdServer)
- **GWD shows file size** in bottom-right corner during editing
- Optimize images before importing (use WebP/PNG compression)

## Technical Specifications

- **HTML5/CSS3** with Web Components
- **Google Enabler.js** for DV360/Campaign Manager integration
- **Responsive layouts** using CSS transforms
- **Polite loading** support for optimal page performance
- **Exit tracking** via `gwd-metric-event` for campaign analytics

## Project Origin

Made for #UH24 using AI by OpenAI.  
[https://digitaleinitiativen.at/initiativen/ummahuesla-hackathon/](https://digitaleinitiativen.at/initiativen/ummahuesla-hackathon/)

## License

This project is provided as-is for educational and commercial use. Ensure compliance with IAB Austria guidelines and local advertising regulations when deploying.

## Support

For issues with Google Web Designer, consult the official documentation:  
[https://support.google.com/webdesigner](https://support.google.com/webdesigner)

For IAB Austria standards:  
[https://www.iab-austria.at](https://www.iab-austria.at)
