# AVPlayerItemLegibleOutput bug

Demonstration project for a bug that occurs when `AVPlayer` is used with `AVPlayerItemLegibleOutput`.

## Area:
AVFoundation

## Summary:
If started in the middle of a subtitle interval, `AVPlayer` displays the first subtitle indefinitely. 

## Steps to Reproduce:
1. Launch the AVPlayerItemLegibleOutputTest application from the attached ZIP archive (or clone it from https://github.com/tzahola/AVPlayerItemLegibleOutput-bug )
2. The application will show a rudimentary video player, which uses an AVPlayer under the hood.
3. Press "Start 480p" or "Start 1024p" to start the sample video. The sample video has a WebVTT subtitle attached via `AVMutableComposition` ([see ViewController.swift](https://github.com/tzahola/AVPlayerItemLegibleOutput-bug/blob/master/AVPlayerItemLegibleOutputTest/ViewController.swift#L45)).
4. The first subtitle interval is 00:00:00.001 → 00:00:03.000, and we seek to 00:00:00.500 before starting playback.

## Expected Results:
Because the AVPlayerItem has an `AVPlayerItemLegibleOutput` attached with `suppressesPlayerRendering == true`, we would expect the `AVPlayer` to not render any subtitle by itself, and report the appropriate subtitles through `AVPlayerItemLegibleOutputPushDelegate`.

## Actual Results:
When testing on an iPad Pro, 7 out of 10 times when playback is started the first subtitle is by `AVPlayer`. Moreover, this first subtitle is displayed throughout the whole playback, until `AVPlayer` is torn down (stopped & deallocated). Meanwhile the legible output delegate correctly receives the subtitle updates, so the end result is that the video player will display two subtitles: the first subtitle which is stuck, rendered by `AVPlayer` at the bottom; and the correct subtitles rendered through the legible output delegate at the top. 

Please check the attached demonstration video:

![animation](https://github.com/tzahola/AVPlayerItemLegibleOutput-bug/blob/master/loop.gif)

Still image:

![screenshot](https://github.com/tzahola/AVPlayerItemLegibleOutput-bug/blob/master/screenshot.png)

**Some observations:** the issue occurs less often when starting the 480p video instead of the 1024p one. It also happens less often on older devices (e.g. iPad Pro 3rd gen vs iPad Pro 2nd gen).

## Version/Build:
iOS 12.2

## Configuration:
iPad Pro 12.9" (3rd generation), MTEL2HC/A happens around 9 out of 10 video starts
iPad Pro 12.9" (2nd generation), MQDA2HC/A happens around 7 out of 10 video starts

When tested on an iPhone 7 Plus (MN4W2GH/A) we couldn't reproduce the issue.
