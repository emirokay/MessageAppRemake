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
	let imageUrl: String
	
	let memberIds: [String]
	let lastMessage: String
	let lastMessageBy: String
	let lastMessageAt: Date
	
	let isPinned: Bool
	let isMuted: Bool
	let isRead: Bool
	let unreadCount: Int
	let messages: [Message]
	
	func chatName(for currentUserId: String, users: [User]? = nil) -> String {
		switch type {
		case .individual:
			return otherUser(for: currentUserId, users: users)?.name ?? "Unknown User"
		case .group:
			return name
		}
	}
	
	func displayImageURL(for currentUserId: String, users: [User]? = nil) -> String? {
		switch type {
		case .individual:
			return otherUser(for: currentUserId, users: users)?.profileImageURL
		case .group:
			return imageUrl
		}
	}
	
	func otherUser(for currentUserId: String, users: [User]?) -> User? {
		guard type == .individual else { return nil }
		guard let otherUserId = memberIds.first(where: { $0 != currentUserId }) else { return nil }
		return users?.first(where: { $0.id == otherUserId })
	}
	
	enum ChatType: String, Codable {
		case individual
		case group
	}
	
	init(id: String, type: ChatType, name: String, imageUrl: String, memberIds: [String], lastMessage: String, lastMessageBy: String, lastMessageAt: Date, isPinned: Bool, isMuted: Bool, isRead: Bool, unreadCount: Int, messages: [Message]) {
		self.id = id
		self.type = type
		self.name = name
		self.imageUrl = imageUrl
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
