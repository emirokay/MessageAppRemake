//
//  MockData.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import Foundation

struct MockData {
	static let mocUser = User(id: "mocUser", name: "Moc User", email: "mocUser@example.com", profileImageURL: "profileImageURL", about: "Moc user is created for testing purposes.")
	
	static let mocUser2 = User(id: "mocUser2", name: "Moc User2", email: "mocUser2@example.com", profileImageURL: "profileImageURL", about: "Moc user2 is created for testing purposes.")
	
	static let mocChat = Chat(id: "1", type: .individual, name: "john doe", imageUrl: "", memberIds: [mocUser.id, mocUser2.id], lastMessage: "Hey, how are you?", lastMessageBy: mocUser.id, lastMessageId: "", lastMessageAt: Date(), createdBy: "1", createdAt: Date(), bio: "This is bio", admins: [mocUser.id], isPinned: [mocUser.id], isMuted: [mocUser.id], isRead: [mocUser.id], unreadCount: ["asd": 0], messages: [mocMessage,mocMessage2])
	
	static let mocChat2 = Chat(id: "2", type: .individual, name: "Bruce Wayne", imageUrl: "", memberIds: [mocUser.id, mocUser2.id], lastMessage: "Test Message", lastMessageBy: mocUser2.id, lastMessageId: "", lastMessageAt: Date(), createdBy: "1", createdAt: Date(), bio: "This is bio", admins: [mocUser.id], isPinned: [mocUser.id], isMuted: [mocUser.id], isRead: [mocUser.id], unreadCount: ["asd": 0], messages: [mocMessage,mocMessage2])
	
	static let mocMessage = Message(id: "1", chatId: "1", senderId: mocUser.id, text: "Test Message", imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/messageapp-c9541.appspot.com/o/MessageImages%2FAJh0BQDvbhT0HibYiuGoOL1RZyA3_ymTmYopJH9MY1sA59RYB3zEO0qS2%2FC18DBBEA-0C4F-49C5-9A37-5F01DB27EBE8.jpg", sentAt: Date(), seenBy: [mocUser.id, mocUser2.id])
	static let mocMessage2 = Message(id: "2", chatId: "1", senderId: mocUser2.id, text: "Test Message2", imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/messageapp-c9541.appspot.com/o/MessageImages%2FAJh0BQDvbhT0HibYiuGoOL1RZyA3_ymTmYopJH9MY1sA59RYB3zEO0qS2%2FC18DBBEA-0C4F-49C5-9A37-5F01DB27EBE8.jpg", sentAt: Date(), seenBy: [mocUser.id, mocUser2.id])
	
}
