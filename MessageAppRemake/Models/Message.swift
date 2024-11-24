//
//  Message.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import Foundation

struct Message: Identifiable, Codable {
	let id: String // Firestore document ID
	let chatId: String // ID of the chat this message belongs to
	let senderId: String // ID of the user who sent the message
	let text: String
	let imageUrl: String? // For media messages
	let sentAt: Date
	let seenBy: [String] // Array of user IDs who have seen the message
	
	// Initializer
	init(id: String, chatId: String, senderId: String, text: String, imageUrl: String? = nil, sentAt: Date, seenBy: [String] = []) {
		self.id = id
		self.chatId = chatId
		self.senderId = senderId
		self.text = text
		self.imageUrl = imageUrl
		self.sentAt = sentAt
		self.seenBy = seenBy
	}
}
