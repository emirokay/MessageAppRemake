//
//  Chat.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import Foundation

struct Chat: Identifiable, Codable {
	let id: String // Firestore document ID
	let type: ChatType // "individual" or "group"
	let name: String? // Group name
	let imageUrl: String? // Group profile picture
	let members: [String] // Array of User IDs
	let lastMessage: String
	let lastMessageBy: String
	let lastMessageAt: Date

	enum ChatType: String, Codable {
		case individual
		case group
	}
	
	// Initializer
	init(id: String, type: ChatType, name: String? = nil, imageUrl: String? = nil, members: [String], lastMessage: String, lastMessageBy: String, lastMessageAt: Date) {
		self.id = id
		self.type = type
		self.name = name
		self.imageUrl = imageUrl
		self.members = members
		self.lastMessage = lastMessage
		self.lastMessageBy = lastMessageBy
		self.lastMessageAt = lastMessageAt
	}
}
