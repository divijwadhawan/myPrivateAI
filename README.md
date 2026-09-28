# myPrivateAI

SwiftUI iPhone chat app using [Exyte Chat](https://github.com/exyte/Chat).

The current assistant is a demo responder. Qwen3-0.6B local inference is a planned next step; no model or API key is bundled.

## Run

1. Open `QwenChat.xcodeproj` in Xcode 16.3 or newer.
2. Allow Xcode to resolve the Exyte Chat Swift package.
3. Set your Apple development team in Signing & Capabilities; change the bundle ID if necessary.
4. Run on an iPhone simulator or your device (iOS 17+).

`ChatScreen.swift` sends user text to `DemoAssistant.reply(to:)`. Replace that service with an on-device Qwen service when adding local inference.
