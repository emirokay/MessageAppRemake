//
//  UserService.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.11.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

protocol UserServiceProtocol {
	var currentUserPublisher: Published<User?>.Publisher { get }
	func fetchUser(userId: String) async throws -> User
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
	
	private init() {}
	
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
		guard let uid = Auth.auth().currentUser?.uid else { return }
		self.currentUser = try await fetchUser(userId: uid)
	}
	
	func uploadUserData(user: User, userId: String) async throws {
		let encodedUser = try Firestore.Encoder().encode(user)
		try await firestore.collection("users").document(userId).setData(encodedUser)
		try await fetchCurrentUser()
	}
	
	func deleteUserData(userId: String) async throws {
		try await firestore.collection("users").document(userId).delete()
		
		let profileImageRef = storage.reference().child("ProfileImages").child(userId)
		if (try? await profileImageRef.getMetadata()) != nil {
			try await profileImageRef.delete()
		}
		
		self.currentUser = nil
	}
	
	func uploadProfileImage(userId: String, imageData: Data) async throws -> String {
		let storageRef = storage.reference().child("ProfileImages").child(userId)
		let metadata = StorageMetadata()
		metadata.contentType = "image/jpeg"
		
		let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
		return try await storageRef.downloadURL().absoluteString
	}
}
