//
//  User.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import Foundation

import Foundation

struct User: Identifiable, Codable {
	let id: String // Firestore document ID
	let name: String
	let email: String
	let profileImageURL: String?
	let phoneNumber: String
	let about: String
	let lastSeen: Date?
	let isOnline: Bool

	// Initializer
	init(id: String, name: String, email: String, profileImageURL: String? = nil, phoneNumber: String, about: String, lastSeen: Date? = nil, isOnline: Bool = false) {
		self.id = id
		self.name = name
		self.email = email
		self.profileImageURL = profileImageURL
		self.phoneNumber = phoneNumber
		self.about = about
		self.lastSeen = lastSeen
		self.isOnline = isOnline
	}
}
