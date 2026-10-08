# Setup

## Open on your Mac

1. Open `QwenChat.xcodeproj` with current Xcode and let Swift Package Manager resolve the dependencies.
2. Select the `QwenChat` scheme and your physical iPhone. Set your Apple Development Team in **Signing & Capabilities**. If necessary, change the bundle identifier to one you control.
3. Build and run, select **Qwen3 0.6B (4-bit)** and send your first message. The initial model download may take time and needs storage and internet. Larger models require more RAM; use the smallest one first.
4. To send a photo, switch to **Qwen2.5 VL 3B** and use the attachment button.


### Gmail setup (one time)

1. In [Google Cloud Console](https://console.cloud.google.com/), create or select a project and **enable the Gmail API**.
2. Configure the OAuth consent screen. For a personal testing app, add your Google account(s) as **test users**. Add the Gmail read-only scope (`https://www.googleapis.com/auth/gmail.readonly`). Google classifies broad Gmail scopes as restricted; distribution beyond personal testing may require OAuth verification and further review.
3. Create an **iOS OAuth client** with bundle ID `com.divijwadhawan.QwenChat`, or set the Xcode target's bundle identifier and OAuth client to the same value.
4. Open `QwenChat/Info.plist`. Replace `REPLACE_WITH_IOS_CLIENT_ID` with the iOS client ID and `com.example.myprivateai.gmail` with its reversed URL scheme from Google Cloud Console (usually `com.googleusercontent.apps.<identifier>`). These are client identifiers, not client secrets.
5. Build on your iPhone. Open **Plugins → Gmail → Connect Gmail** and authorize read-only access. Search using Gmail syntax such as `is:unread` or `from:example.com newer_than:7d`, then tap a result to summarize it with the selected on-device model.

The Gmail plugin reads at most 10 matching messages per search. It never sends, deletes, archives, or drafts email. Gmail API requests require internet. Google Sign-In manages its own credentials; the app does not put tokens in the model prompt. The selected message text is processed by the on-device model and remains in the current in-memory conversation. Gmail OAuth setup must be completed before the plugin can connect. Google may limit unverified apps to configured test users.

The app keeps the active conversation in memory. Model files are stored in the app cache; iOS can evict cached files, in which case a download is needed again. Chat history is not persisted across launches. No server receives your prompts during ordinary local chat. Model downloads contact Hugging Face.

