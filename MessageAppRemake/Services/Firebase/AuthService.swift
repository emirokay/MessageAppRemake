//
//  AuthService.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.11.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import Combine

protocol AuthServiceProtocol {
	var userSessionPublisher: Published<FirebaseAuth.User?>.Publisher { get }
	func login(withEmail email: String, password: String) async throws
	func createUser(withEmail email: String, password: String, fullname: String) async throws
	func signOut() async throws
	func deleteAccount() async throws
}

final class AuthService: AuthServiceProtocol {
	static let shared = AuthService()
	
	@Published private(set) var userSession: FirebaseAuth.User?
	var userSessionPublisher: Published<FirebaseAuth.User?>.Publisher { $userSession }
	
	private let userService: UserServiceProtocol
	
	private init(userService: UserServiceProtocol = UserService.shared) {
		self.userService = userService
		self.userSession = Auth.auth().currentUser
	}
	
	@MainActor
	func login(withEmail email: String, password: String) async throws {
		let result = try await Auth.auth().signIn(withEmail: email, password: password)
		self.userSession = result.user
		try await userService.fetchCurrentUser()
	}
	
	@MainActor
	func signOut() async throws {
		try Auth.auth().signOut()
		self.userSession = nil
	}
	
	@MainActor
	func createUser(withEmail email: String, password: String, fullname: String) async throws {
		let result = try await Auth.auth().createUser(withEmail: email, password: password)
		self.userSession = result.user
		
		let user = User(
			id: result.user.uid,
			name: fullname,
			email: email,
			profileImageURL: "",
			about: ""
		)
		try await userService.uploadUserData(user: user, userId: result.user.uid)
		try await userService.fetchCurrentUser()
	}
	
	@MainActor
	func deleteAccount() async throws {
		guard let currentUser = Auth.auth().currentUser else { return }
		try await userService.deleteUserData(userId: currentUser.uid)
		try await currentUser.delete()
		self.userSession = nil
	}
}
