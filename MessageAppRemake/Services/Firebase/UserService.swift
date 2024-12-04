//
//  UserService.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.11.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine
import FirebaseAuth

protocol UserServiceProtocol {
	var currentUserPublisher: Published<User?>.Publisher { get }
	func fetchCurrentUser() async throws
	func uploadUserData(user: User, userId: String) async throws
	func deleteUserData(userId: String) async throws
	func uploadProfileImage(userId: String, imageData: Data) async throws -> String
}

final class UserService: UserServiceProtocol {
	static let shared = UserService()
	
	@Published private(set) var currentUser: User?
	var currentUserPublisher: Published<User?>.Publisher { $currentUser }
	
	private let firestore = Firestore.firestore()
	private let storage = Storage.storage()
	
	private init() {
	}
	
	@MainActor
	func fetchUser(userId: String) async throws -> User {
		let document = try await firestore.collection("users").document(userId).getDocument()
		guard let data = document.data() else {
			throw AppError(title: "Error", message: "User not found")
		}
		return try Firestore.Decoder().decode(User.self, from: data)
	}
	
	@MainActor
	func fetchCurrentUser() async throws {
		guard let uid = Auth.auth().currentUser?.uid else {
			return
		}
		self.currentUser = try await fetchUser(userId: uid)
	}
	
	func uploadUserData(user: User, userId: String) async throws {
		do {
			let encodedUser = try Firestore.Encoder().encode(user)
			try await firestore.collection("users").document(userId).setData(encodedUser)
			try await fetchCurrentUser()
		} catch {
			throw error
		}
	}
	
	func deleteUserData(userId: String) async throws {
		do {
			try await firestore.collection("users").document(userId).delete()
		} catch {
			throw error
		}
		
		let profileImageRef = storage.reference().child("ProfileImages").child(userId)
		do {
			try await profileImageRef.delete()
		} catch let error as NSError {
			if error.domain == StorageErrorDomain && error.code == StorageErrorCode.objectNotFound.rawValue {
				throw AppError(title: "Delete Failed", message: "No profile image found for deletion.")
			} else {
				throw error
			}
		}
		self.currentUser = nil
	}
	
	func uploadProfileImage(userId: String, imageData: Data) async throws -> String {
		let storageRef = storage.reference().child("ProfileImages").child(userId)
		let metadata = StorageMetadata()
		metadata.contentType = "image/jpeg"
		
		do {
			let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
			let downloadURL = try await storageRef.downloadURL()
			return downloadURL.absoluteString
		} catch {
			throw error
		}
	}
	
}
