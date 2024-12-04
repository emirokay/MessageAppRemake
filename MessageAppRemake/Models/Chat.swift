//
//  Chat.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import Foundation

struct Chat: Identifiable, Codable, Equatable {
	let id: String
	let type: ChatType
	let name: String
	let imageUrl: String?
	let members: [String]
	let lastMessage: String
	let lastMessageBy: String
	let lastMessageAt: Date
	let isPinned: Bool
	let isMuted: Bool
	let isRead: Bool
	let unreadCount: Int
	let messages: [Message]
	
	enum ChatType: String, Codable {
		case individual
		case group
	}
	
	init(id: String, type: ChatType, name: String, imageUrl: String? = nil, members: [String], lastMessage: String, lastMessageBy: String, lastMessageAt: Date, isPinned: Bool, isMuted: Bool, isRead: Bool, unreadCount: Int, messages: [Message]) {
		self.id = id
		self.type = type
		self.name = name
		self.imageUrl = imageUrl
		self.members = members
		self.lastMessage = lastMessage
		self.lastMessageBy = lastMessageBy
		self.lastMessageAt = lastMessageAt
		self.isPinned = isPinned
		self.isMuted = isMuted
		self.isRead = isRead
		self.unreadCount = unreadCount
		self.messages = messages
	}
}
