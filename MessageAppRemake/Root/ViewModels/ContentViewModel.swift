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
	
	@Published var userSession: FirebaseAuth.User?
	@Published var isLoading = false
	@Published var appError: AppError? = nil
	
	private var cancellables = Set<AnyCancellable>()
	private let authService: AuthServiceProtocol
	private let appState: AppStateProtocol
	
	init(authService: AuthServiceProtocol = AuthService.shared, appState: AppStateProtocol = AppState.shared) {
		self.authService = authService
		self.appState = appState
		setupSubscribers()
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
	
	func login(email: String, password: String) {
		Task {
			do {
				try await authService.login(withEmail: email, password: password)
			} catch {
				appState.setError("Login failed", error.localizedDescription)
			}
		}
	}
	
	func signOut() {
		Task {
			do {
				try await authService.signOut()
			} catch {
				appState.setError("Sign Out Failed", error.localizedDescription)
			}
		}
	}
	
	func clearError() {
		appState.clearError()
	}
	
}

