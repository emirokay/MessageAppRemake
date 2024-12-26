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
	var name: String
	var imageUrl: String
	
	var memberIds: [String]
	var lastMessage: String
	var lastMessageBy: String
	var lastMessageId: String
	var lastMessageAt: Date
	
	let createdBy: String
	let createdAt: Date
	var bio: String
	var admins: [String]
	var isPinned: [String]
	var isMuted: [String]
	var isRead: [String]
	
	var unreadCount: [String: Int]
	var messages: [Message]
	
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
	
	init(id: String, type: ChatType, name: String, imageUrl: String, memberIds: [String], lastMessage: String, lastMessageBy: String, lastMessageId: String, lastMessageAt: Date, createdBy: String, createdAt: Date, bio: String, admins: [String], isPinned: [String], isMuted: [String], isRead: [String], unreadCount: [String: Int], messages: [Message]) {
		self.id = id
		self.type = type
		self.name = name
		self.imageUrl = imageUrl
		self.memberIds = memberIds
		self.lastMessage = lastMessage
		self.lastMessageBy = lastMessageBy
		self.lastMessageId = lastMessageId
		self.lastMessageAt = lastMessageAt
		
		self.createdBy = createdBy
		self.createdAt = createdAt
		self.bio = bio
		self.admins = admins
		self.isPinned = isPinned
		self.isMuted = isMuted
		self.isRead = isRead
		
		self.unreadCount = unreadCount
		self.messages = messages
	}
}
