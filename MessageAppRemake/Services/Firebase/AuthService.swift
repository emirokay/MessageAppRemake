//
//  AuthService.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.11.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
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
		do {
			let result = try await Auth.auth().signIn(withEmail: email, password: password)
			self.userSession = result.user
			try await userService.fetchCurrentUser()
		} catch {
			throw error
		}
	}
	
	@MainActor
	func signOut() async throws {
		do {
			try Auth.auth().signOut()
			self.userSession = nil
		} catch {
			throw error
		}
	}
	
	@MainActor
	func createUser(withEmail email: String, password: String, fullname: String) async throws {
		do {
			let result = try await Auth.auth().createUser(withEmail: email, password: password)
			self.userSession = result.user
			
			let user = User(
				id: result.user.uid,
				name: fullname,
				email: email,
				profileImageURL: nil,
				about: nil
			)
			try await userService.uploadUserData(user: user, userId: result.user.uid)
			try await userService.fetchCurrentUser()
			
		} catch {
			throw error
		}
	}
	
	@MainActor
	func deleteAccount() async throws {
		do {
			guard let uid = Auth.auth().currentUser?.uid else { return }
			
//			try await userService.deleteUserData(userId: uid) // Delegate to UserService
//			try await Auth.auth().currentUser?.delete()       // Delete user authentication
			
			// Delete profile image (if exists)
			let storageReference = Storage.storage().reference().child("ProfileImages").child(uid)
			let profileImageExists = try await storageReference.listAll().items.count > 0
			if profileImageExists {
				try await storageReference.delete()
			}
			
			// Delete user document
			let userDocumentReference = Firestore.firestore().collection("users").document(uid)
			try await userDocumentReference.delete()
			
			// Delete authentication account
			try await Auth.auth().currentUser?.delete()
			
			self.userSession = nil
			//UserService.shared.currentUser = nil
		} catch {
			throw error
		}
	}
}
