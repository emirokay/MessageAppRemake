//
//  AuthViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Combine

@MainActor
class ContentViewModel: ObservableObject {
	
	@Published var userSession: FirebaseAuth.User? {
		didSet { fetchCurrentUserData() }
	}
	
	@Published var isLoading = true
	@Published var appError: AppError? = nil
	
	private var cancellables = Set<AnyCancellable>()
	private let authService: AuthServiceProtocol
	private let appState: AppStateProtocol
	private let userService: UserServiceProtocol
	
	init(authService: AuthServiceProtocol = AuthService.shared, appState: AppStateProtocol = AppState.shared, userService: UserServiceProtocol = UserService.shared) {
		self.authService = authService
		self.appState = appState
		self.userService = userService
		setupSubscribers()
		setupAuthListener()
	}
	
	private func setupSubscribers() {
		authService.userSessionPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: &$userSession)
		
		appState.loadingPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: &$isLoading)
		
		appState.errorPublisher
			.receive(on: DispatchQueue.main)
			.sink { [weak self] appError in
				self?.appError = appError
			}
			.store(in: &cancellables)
		
	}
	
	private func setupAuthListener() {
		Auth.auth().addStateDidChangeListener { [weak self] _, user in
			self?.userSession = user
		}
	}
	
	private func fetchCurrentUserData() {
		performTaskWithLoading {
			try await self.userService.fetchCurrentUser()
		}
	}
	
	func login(email: String, password: String) {
		performTaskWithLoading {
			try await self.authService.login(withEmail: email, password: password)
		}
	}
	
	func signOut() {
		performTaskWithLoading {
			try await self.authService.signOut()
		}
	}
	
	func createUser(withEmail email: String, password: String, confirmPassword: String, fullname: String) {
		if password == confirmPassword {
			performTaskWithLoading {
				try await self.authService.createUser(withEmail: email, password: password, fullname: fullname)
			}
		} else {
			appState.setError("Sign Up Failed", "Passwords do not match")
		}
	}
	
	func clearError() {
		appState.clearError()
	}
	
	private func performTaskWithLoading(_ task: @escaping () async throws -> Void) {
		appState.setLoading(true)
		Task {
			defer { appState.setLoading(false) }
			do {
				try await task()
			} catch {
				appState.setError("Operation Failed", error.localizedDescription)
			}
		}
	}
	
}
