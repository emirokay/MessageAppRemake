//
//  User.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import Foundation

struct User: Identifiable, Codable {
	let id: String
	var name: String
	var email: String
	var profileImageURL: String?
	var about: String
	
	init(id: String, name: String, email: String, profileImageURL: String? = nil, about: String) {
		self.id = id
		self.name = name
		self.email = email
		self.profileImageURL = profileImageURL
		self.about = about
	}
}
