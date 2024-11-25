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
	
	private init() {}
	
	@MainActor
	func fetchCurrentUser() async throws {
		
	}
	
	func uploadUserData(user: User, userId: String) async throws {
		
	}
	
	func deleteUserData(userId: String) async throws {
		
	}
	
	func uploadProfileImage(userId: String, imageData: Data) async throws -> String {
		return ""
	}
	
}
