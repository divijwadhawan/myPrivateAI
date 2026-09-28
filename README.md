# myPrivateAI

An experimental iPhone chat app built with SwiftUI. The original goal was a ChatGPT-style interface using [Exyte Chat](https://github.com/exyte/Chat), followed by on-device Qwen3-0.6B inference.

## Status: paused (28 September 2026)

The repository contains a SwiftUI app, an Exyte Chat screen, and `DemoAssistant.swift`, which returns a fixed demonstration reply. **Qwen is not integrated.** The iPhone app has not been confirmed to launch successfully. Work is paused while we choose a simpler chat UI approach for a later session.

## What we tried

1. Created `QwenChat.xcodeproj`, `ChatScreen.swift`, and `DemoAssistant.swift`. The app was intended to show messages through Exyte Chat before connecting an offline model.
2. An initial build failed inside MediaPicker with an initializer-label mismatch. We changed the Exyte Chat package reference in the repository to a specific revision; the app then built on the user's Mac.
3. Launch on an iPhone failed with `Library not loaded: @rpath/GiphyUISDK.framework/GiphyUISDK`. The repository was updated to link Giphy directly, but merely listing the package in Xcode did not establish that its binary framework was embedded in the installed app.
4. Locally in Xcode, we tried Exyte Chat 2.1.4 with MediaPicker 2.0.0 to avoid Giphy. MediaPicker 2.0.0 lacked `setSelectionParameters` and `SelectionParamsHolder`; version 2.2.4 contained both. These local package changes were **not committed to this repository**.
5. On Xcode 27.0, a fresh build with the older package combination still failed during linking with undefined symbols for multiple `ExyteChat.ChatView` state initializers. Deleting QwenChat DerivedData did not clear the linker failure. The build transcript showed that ExyteChat compiled and was included in the app link; it also showed a remaining direct Giphy dependency. The exact cause of the unresolved symbols was **not established**.

## Why we paused

The chat interface is still only a demo, but package integration has consumed several rounds of build and runtime troubleshooting. We decided to stop changing dependencies and revisit the UI later. A small chat screen made with native SwiftUI is the leading alternative: it would keep the message flow easy to understand and let us add on-device Qwen inference without Exyte's media and Giphy dependencies. This is a proposal for the next session, not an implemented change.

## When resuming

- First inspect the **local Xcode project and `git status`** before pulling or editing: the local package and signing changes may differ from `main`.
- Decide whether to replace Exyte Chat with a native SwiftUI chat screen, or isolate the Exyte/Xcode 27 linker failure in Exyte's example project.
- Get a simple chat interface running on the iPhone with the demo response.
- Then add local Qwen3-0.6B model loading and response generation.

The GitHub `main` branch still contains the Exyte-based starter. The documented local experiments are not represented as committed fixes.
