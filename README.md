# My Private AI — local Qwen chat for iPhone

A standalone SwiftUI iOS app based on the [MLX Chat Example](https://github.com/ml-explore/mlx-swift-examples/tree/main/Applications/MLXChatExample). It downloads a selected Qwen model and generates chat replies locally with MLX. The included models are Qwen3 0.6B, 1.7B, 4B and Qwen2.5 VL 3B for image chat. Downloading a model requires internet; inference after download runs on device. No model weights, backend, account, or API key are included.

## Open on your Mac

1. Open `QwenChat.xcodeproj` with current Xcode and let Swift Package Manager resolve the dependencies.
2. Select the `QwenChat` scheme and your physical iPhone. Set your Apple Development Team in **Signing & Capabilities**. If necessary, change the bundle identifier to one you control.
3. Build and run, select **Qwen3 0.6B (4-bit)** and send your first message. The initial model download may take time and needs storage and internet. Larger models require more RAM; use the smallest one first.
4. To send a photo, switch to **Qwen2.5 VL 3B** and use the attachment button.

## Architecture

`SwiftUI Views → ChatViewModel → MLXService → MLX Swift LM → downloaded Qwen model`

The app keeps the active conversation in memory. Model files are stored in the app cache; iOS can evict cached files, in which case a download is needed again. Chat history is not persisted across launches. No server receives your prompts during ordinary local chat. Model downloads contact Hugging Face.

## Verification status

The repository contains a standalone Xcode project and upstream Swift source. This environment cannot run Xcode or install on an iPhone; the Xcode build, signing, initial download, and on-device inference still need to be verified on a Mac and iPhone. Dependencies are declared using the versions referenced by the upstream example at integration time.

## Attribution

Based on the MLX Swift Examples project, copyright its contributors, under the MIT license included in `LICENSE`. App source is adapted from `Applications/MLXChatExample` (upstream snapshot).
