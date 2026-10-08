# On-Device AI Chat for iOS

A SwiftUI application that downloads Qwen models and runs chat inference locally on an iPhone using MLX. An optional Gmail plugin retrieves selected messages for local summarization.

**Status:** implemented prototype adapted from the MLX Chat Example; device compatibility and performance must be verified for each model.

## Demo
Download the smallest model, send a prompt, then optionally select a vision model and attach a photo. See [demo steps](docs/demo.md).

## Implemented features
- Model selection and download, local text generation and vision-model support.
- Chat interface with download progress and generation information.
- Plugin interface and optional read-only Gmail integration.

## Architecture and stack
SwiftUI views → ChatViewModel → MLXService → MLX Swift LM → downloaded model.

Source remains in `QwenChat/`, with `Models/`, `Views/`, `ViewModels/`, `Services/`, `Plugins/` and `Support/`. See [architecture](docs/architecture.md).

## Quick start
1. Open `QwenChat.xcodeproj` in Xcode and resolve Swift packages.
2. Configure your development team and signing; choose a physical iPhone.
3. Run the app and download Qwen3 0.6B first.
4. Configure Gmail only if needed using [setup instructions](docs/setup.md).

The project declares iOS 17.0 as its deployment target. Package requirements may impose additional toolchain constraints.

## Project scope and attribution
Adapted from [MLX Swift Examples](https://github.com/ml-explore/mlx-swift-examples/tree/main/Applications/MLXChatExample). The repository adds standalone app integration and plugin-related source; it does not implement or train the underlying Qwen models or MLX engine. Upstream source attribution is retained.

## Validation and limitations
No Mac/iPhone build or inference benchmark was run in this documentation update. No tested-device performance figures are claimed.

Chat history is in memory. Models reside in a cache which iOS may evict. Downloads and Gmail requests need internet; ordinary local inference runs on device after download. Larger models require more memory.

## Documentation and license
[Setup](docs/setup.md) · [Architecture](docs/architecture.md) · [Demo](docs/demo.md)

MIT licence: see [LICENSE](LICENSE). Model weights have their own licences.
