# GTWeibo

A lightweight iOS tweak that removes ads from Weibo. It targets the feed stream and the startup splash ad to deliver a cleaner, faster timeline.

Note: This project is under active development and currently focuses on ad removal only.

## ✨ Features

- Remove feed ads in the main timeline
- Disable/skip startup splash ad

## 🖼 Screenshots

Add your screenshots here (optional):
- 1.png
- 2.png
- 3.png

## 🛠 Build Instructions

This is a Theos/Logos-based tweak.

- Requirements
  - Theos installed and configured
  - iOS device (rootful or rootless jailbreak) or simulator environment that supports tweaks
  - iOS SDK matching your Theos setup

- Clone
```bash
git clone <your-repo-url> gtweibo
cd gtweibo
```

- Build (debug)
```bash
make package
```
The resulting `.deb` will appear in `packages/`.

- Build (release)
```bash
make package FINALPACKAGE=1
```

- Install (SSH to device)
```bash
# Example using dpkg over ssh
scp packages/*.deb root@<device-ip>:/var/root/
ssh root@<device-ip> "dpkg -i /var/root/*.deb; uicache -a"
```

- Uninstall
```bash
ssh root@<device-ip> "dpkg -r com.codex.gtweibo"
```

Notes:
- If you’re building for a rootless environment, ensure your Theos toolchain and packaging settings target rootless paths.
- App restart or respring may be required after installation.

## ⚙️ How It Works (Overview)

- Hooks core Weibo feed components to detect and eliminate ad cards.
- Removes/blocks the splash ad view early in app launch.
- Uses lightweight, defensive checks to avoid UI glitches and keeps the timeline compact.

Main logic lives in:
- `Tweak.x` — primary Logos hooks
- `src/Tool/GTTool.*` — utilities for ad detection and logging

## 🧪 Debugging

- Syslog logging is enabled in debug builds. Look for lines prefixed with `[TaoLi]`.
- If you see empty gaps in the feed, you may be running a debug build that leaves space for inspection. Release builds compress ad cells to near-zero height.

## 🔒 Compatibility

- Weibo iOS app. Exact version coverage may vary as Weibo updates frequently.
- iOS versions depend on your Theos SDK and jailbreak environment.

## 📜 Disclaimer

This project is for educational and personal use only. Use at your own risk. The authors are not affiliated with Weibo.

## 🙏 Credits

- Theos and Logos community
- Everyone contributing issue reports and improvements

