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
	//func loadCurrentUserData() async throws
}

final class AuthService: AuthServiceProtocol {
	static let shared = AuthService()
	
	@Published private(set) var userSession: FirebaseAuth.User?
	var userSessionPublisher: Published<FirebaseAuth.User?>.Publisher { $userSession }
	
	private init() {
		self.userSession = Auth.auth().currentUser
	}
	
	@MainActor
	func login(withEmail email: String, password: String) async throws {
		AppState.shared.setLoading(true)
		do {
			let result = try await Auth.auth().signIn(withEmail: email, password: password)
			self.userSession = result.user
			//try await loadCurrentUserData()
		} catch {
			AppState.shared.setError("Login Failed", error.localizedDescription)
			throw error
		}
		AppState.shared.setLoading(false)
	}
	
	@MainActor
	func signOut() async throws {
		AppState.shared.setLoading(true)
		do {
			try Auth.auth().signOut()
			self.userSession = nil
			//UserService.shared.currentUser = nil
		} catch {
			AppState.shared.setError("Sign Out Failed", error.localizedDescription)
			throw error
		}
		AppState.shared.setLoading(false)
	}
	
	@MainActor
	func createUser(withEmail email: String, password: String, fullname: String) async throws {
		AppState.shared.setLoading(true)
		do {
			let result = try await Auth.auth().createUser(withEmail: email, password: password)
			self.userSession = result.user
			//try await uploadUserData(email: email, fullname: fullname, id: result.user.uid)
			//try await loadCurrentUserData()
		} catch {
			AppState.shared.setError("Registration Failed", error.localizedDescription)
			throw error
		}
		AppState.shared.setLoading(false)
	}
	
	@MainActor
	func deleteAccount() async throws {
		AppState.shared.setLoading(true)
		do {
			guard let uid = Auth.auth().currentUser?.uid else { return }
			
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
			AppState.shared.setError("Account Deletion Failed", error.localizedDescription)
			throw error
		}
		AppState.shared.setLoading(false)
	}
}
