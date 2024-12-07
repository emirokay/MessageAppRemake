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
	let members: [String: String]
	let memberIds: [String]
	let lastMessage: String
	let lastMessageBy: String
	let lastMessageAt: Date
	let isPinned: Bool
	let isMuted: Bool
	let isRead: Bool
	let unreadCount: Int
	let messages: [Message]
	
	func chatName(for currentUserId: String) -> String {
		if type == .individual {
			return members.first(where: { $0.key != currentUserId })?.value ?? "Unknown User"
		}
		return name
	}
	
	enum ChatType: String, Codable {
		case individual
		case group
	}
	
	init(id: String, type: ChatType, name: String, imageUrl: String? = nil, members: [String: String], memberIds: [String], lastMessage: String, lastMessageBy: String, lastMessageAt: Date, isPinned: Bool, isMuted: Bool, isRead: Bool, unreadCount: Int, messages: [Message]) {
		self.id = id
		self.type = type
		self.name = name
		self.imageUrl = imageUrl
		self.members = members
		self.memberIds = memberIds
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
