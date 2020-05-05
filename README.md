# Webex Mute Button
 Basic program and hardware for controlling Webex Mute Status

![Screenshot](http://jonreiling.com/webex/webex-screenshot.png)

## The Problem

Webex makes it difficult to know if you're on mute.  Worse, if you're sharing your screen or using another app, it's very cumbersome to unmute yourself, meaning you might miss a critical part of the conversation.

So I've created a macOS menu app to keep tabs on Webex and relay its state to an external status indicator (in this case, red and green LEDs). To boot, you can even toggle mute status using an external button.

## How it works

Going to Cisco API route would be overkill. I didn't want to mess with authentication and, frankly, didn't need it. Instead, I turned to Applescript, which allowed me to read the values of Webex's menu bars. Cheeky! 💅🏻

From there, a macOS swift app manages communication between Applescript and a [Teensy LC](https://www.sparkfun.com/products/13305) via a Serial connection. Two external LEDs indicate mute status (or turn off if there isn't a meeting) and a button allows me to quickly toggle the mute state in the Webex app.

## Demo

![Screenshot](http://jonreiling.com/webex/webex-video.jpg)

[View on Youtube](https://youtu.be/0hhCqMGTCo0)

## What's next

As you can see from the video, the status indicators and button are pretty raw. Next up: build a more permanent enclosure. (Perhaps an "On Air" sign?)

And while this is helpful for me as an individual, I could imagine this being useful as a way to let family members know that you're on a conference call. An external status sign outside your office door could be pretty useful...

## Closing thoughts

This was a quick weekend project, but the possibilities are endless. If you're interested in collaborating, feel free to reach out, or just grab the code and go wild! Let me know what you create!
