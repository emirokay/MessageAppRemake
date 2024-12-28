//
//  MainView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

struct MainTabView: View {
	@StateObject private var inboxViewModel = InboxViewModel()
	@StateObject private var profileViewModel = ProfileViewModel()
	
	var body: some View {
		MainTabViewContent(
			inboxViewModel: inboxViewModel,
			profileViewModel: profileViewModel
		)
	}
}

private struct MainTabViewContent: View {
	@ObservedObject var inboxViewModel: InboxViewModel
	@ObservedObject var profileViewModel: ProfileViewModel
	
	var body: some View {
		TabView {
			InboxView(viewModel: inboxViewModel)
				.tabItem {
					Label("Chats", systemImage: "bubble.left.and.text.bubble.right.fill")
				}
			
			ProfileView(viewModel: profileViewModel)
				.tabItem {
					Label("Settings", systemImage: "gearshape.fill")
				}
		}
	}
}

#Preview {
	MainTabView()
}
