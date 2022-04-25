//
//  SwiftUI_ChatApp.swift
//  SwiftUI_Chat
//
//  Created by tw on 2022/04/24.
//

import SwiftUI
import Firebase

@main
struct SwiftUI_ChatApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
