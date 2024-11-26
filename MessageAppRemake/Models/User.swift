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
	let about: String?

	// Initializer
	init(id: String, name: String, email: String, profileImageURL: String? = nil, about: String? = nil) {
		self.id = id
		self.name = name
		self.email = email
		self.profileImageURL = profileImageURL
		self.about = about
	}
}
