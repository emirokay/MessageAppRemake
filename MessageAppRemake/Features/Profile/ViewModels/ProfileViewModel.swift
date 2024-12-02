//
//  ProfileViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
	@Published var currentUser: User? = MockData.mocUser
	
	//Settings
	let settingsOptions = SettingsOption.allCases
	
	func signOut() {
		//Signout logic
	}
	
	func deleteAccount() {
		//Delete account logic 
	}
}


enum SettingsOption: CaseIterable, Identifiable {
	case starredMessages
	case account
	case darkMode
	case privacy
	case chats
	case notifications
	case activityStatus
	case accessibility
	
	var id: String { title }
	
	var title: String {
		switch self {
		case .starredMessages: return "Starred Messages"
		case .account: return "Account"
		case .darkMode: return "Dark Mode"
		case .privacy: return "Privacy"
		case .chats: return "Chats"
		case .notifications: return "Notifications"
		case .activityStatus: return "Activity Status"
		case .accessibility: return "Accessibility"
		}
	}
	
	var iconName: String {
		switch self {
		case .starredMessages: return "star"
		case .account: return "person"
		case .darkMode: return "moon"
		case .privacy: return "lock"
		case .chats: return "message"
		case .notifications: return "bell"
		case .activityStatus: return "message.badge"
		case .accessibility: return "accessibility"
		}
	}
	
	var destination: AnyView {
		switch self {
		case .starredMessages: return AnyView(Text("Starred Messages View"))
		case .account: return AnyView(Text("Account Settings View"))
		case .darkMode: return AnyView(Text("Dark Mode Settings View"))
		case .privacy: return AnyView(Text("Privacy Settings View"))
		case .chats: return AnyView(Text("Chat Settings View"))
		case .notifications: return AnyView(Text("Notifications Settings View"))
		case .activityStatus: return AnyView(Text("Activity Status View"))
		case .accessibility: return AnyView(Text("Accessibility Settings View"))
		}
	}
}
