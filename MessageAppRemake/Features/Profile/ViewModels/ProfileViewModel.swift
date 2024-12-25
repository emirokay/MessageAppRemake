//
//  ProfileViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
	@Published var currentUser: User?
	
	private let userService: UserServiceProtocol
	private let appState: AppStateProtocol
	let settingsOptions = SettingsOption.allCases
	
	init(userService: UserServiceProtocol = UserService.shared, appState: AppStateProtocol = AppState.shared) {
		self.userService = userService
		self.appState = appState
		setupSubscribers()
	}
	
	private func setupSubscribers() {
		userService.currentUserPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: &$currentUser)
	}
	
	func signOut(authService: AuthServiceProtocol = AuthService.shared) {
		performTaskWithLoading {
			try await authService.signOut()
		}
	}
	//IDK WTF IS THIS
	func getCurrentUser() -> User {
		if let user = currentUser {
			return user
		}
		return  User(id: "0", name: "Unknown", email: "Unknown", profileImageURL: "", about: "Unknown")
	}
	
	func deleteAccount(authService: AuthServiceProtocol = AuthService.shared) {
		performTaskWithLoading {
			try await authService.deleteAccount()
		}
	}
	
	func saveUser(name: String, about: String, imageData: Data) {
		guard var user = currentUser else { return }
		user.name = name
		user.about = about
		
		performTaskWithLoading {
			if !imageData.isEmpty {
				let profileUrl = try await self.userService.uploadProfileImage(userId: user.id, imageData: imageData)
				user.profileImageURL = profileUrl
			}
			try await self.userService.uploadUserData(user: user, userId: user.id)
		}
	}
	
	private func performTaskWithLoading(_ task: @escaping () async throws -> Void) {
		appState.setLoading(true)
		Task {
			do {
				try await task()
			} catch {
				appState.setError("Operation Failed", error.localizedDescription)
			}
			appState.setLoading(false)
		}
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
