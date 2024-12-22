//
//  Message.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
	let id: String
	let chatId: String
	let senderId: String
	let text: String
	let imageUrl: String
	let sentAt: Date
	let seenBy: [String]
	
	init(id: String, chatId: String, senderId: String, text: String, imageUrl: String, sentAt: Date, seenBy: [String] = []) {
		self.id = id
		self.chatId = chatId
		self.senderId = senderId
		self.text = text
		self.imageUrl = imageUrl
		self.sentAt = sentAt
		self.seenBy = seenBy
	}
}
