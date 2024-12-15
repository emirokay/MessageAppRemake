//
//  MainView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

struct MainTabView: View {
	@StateObject var inboxViewModel = InboxViewModel()
	@StateObject var profileViewModel = ProfileViewModel()
	
	var body: some View {
		MainTabView2(inboxViewModel: inboxViewModel, profileViewModel: profileViewModel)
	}
}

struct MainTabView2: View {
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
