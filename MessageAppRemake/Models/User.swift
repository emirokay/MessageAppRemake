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
	var profileImageURL: String
	var about: String
}
