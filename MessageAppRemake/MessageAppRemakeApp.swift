//
//  MessageAppRemakeApp.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI
import FirebaseCore

@main
struct MessageAppRemakeApp: App {
	
	init() {
		FirebaseApp.configure()
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
