//
//  QwenChatApp.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import SwiftUI
import GoogleSignIn

@main
struct QwenChatApp: App {
    var body: some Scene {
        WindowGroup {
            ChatView(viewModel: ChatViewModel(mlxService: MLXService()))
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
