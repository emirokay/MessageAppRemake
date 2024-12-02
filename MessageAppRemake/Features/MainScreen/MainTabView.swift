//
//  MainView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

struct MainTabView: View {
	var body: some View {
		TabView {
			InboxView(viewModel: InboxViewModel())
				.tabItem {
					Label("Chats", systemImage: "bubble.left.and.text.bubble.right.fill")
				}
			
			ProfileView(viewModel: ProfileViewModel())
				.tabItem {
					Label("Settings", systemImage: "gearshape.fill")
				}
		}
	}
}

#Preview {
	MainTabView()
}
