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
		didSet {
			fetchCurrentUserData()
		}
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
	
	func login(email: String, password: String) {
		appState.setLoading(true)
		Task {
			do {
				try await authService.login(withEmail: email, password: password)
			} catch {
				appState.setError("Login failed", error.localizedDescription)
			}
		}
		appState.setLoading(false)
	}
	
	func signOut() {
		appState.setLoading(true)
		Task {
			do {
				try await authService.signOut()
			} catch {
				appState.setError("Sign Out Failed", error.localizedDescription)
			}
		}
		appState.setLoading(false)
	}
	
	func createUser(withEmail email: String, password: String, confirmPassword: String, fullname: String) {
		if password == confirmPassword {
			appState.setLoading(true)
			Task {
				do {
					try await authService.createUser(withEmail: email, password: password, fullname: fullname)
				} catch {
					appState.setError("Sign Up Failed", error.localizedDescription)
				}
			}
		} else {
			appState.setError("Sign Up Failed", "Passwords do not match")
		}
		appState.setLoading(false)
	}
	
	func clearError() {
		appState.clearError()
	}
	
}

