//
//  InboxViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 26.11.2024.
//

import Foundation
import Combine

@MainActor
class MainViewModel: ObservableObject {
	@Published var currentUser: User?
	
	private let userService: UserServiceProtocol
	private let appState: AppStateProtocol
	private var cancellables = Set<AnyCancellable>()
	
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
	
	func fetchCurrentUserData() {
		appState.setLoading(true)
		Task {
			do {
				try await userService.fetchCurrentUser()
			} catch {
				appState.setError("Load User Failed", error.localizedDescription)
			}
		}
		appState.setLoading(false)
	}
	
	func signOut(authService: AuthServiceProtocol = AuthService.shared) {
		appState.setLoading(false)
		Task {
			do {
				try await authService.signOut()
			} catch {
				appState.setError("Sign Out Failed", error.localizedDescription)
			}
		}
		appState.setLoading(false)
	}
	
}
