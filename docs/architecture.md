# Architecture

## Architecture

`SwiftUI Views → ChatViewModel → MLXService → MLX Swift LM → downloaded Qwen model`

## Plugins

The puzzle-piece button opens the plugin catalog. `AppPlugin` defines a small interface for connecting, disconnecting, and searching a service. `PluginRegistry` lists the installed plugins. A plugin returns `PluginItem` values; only after you tap an item does the app give its content to the local model for summarization. A future plugin can implement the same protocol and register itself without changing the chat model. Plugins are explicit actions in the UI; the model does not execute arbitrary external requests or send mail.


## Source organization

Models contain model/message types; ViewModels coordinate UI state; Services implement MLX inference; Plugins implement explicit external-service actions; Views and Support contain UI and shared resources.
