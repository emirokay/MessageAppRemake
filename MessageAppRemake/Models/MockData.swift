//
//  MockData.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import Foundation

struct MockData {
	static let mocUser = User(id: "mocUser", name: "Moc User", email: "mocUser@example.com", about: "Moc user is created for testing purposes.")
	
	static let mocUser2 = User(id: "mocUser2", name: "Moc User2", email: "mocUser2@example.com", about: "Moc user2 is created for testing purposes.")
	
	static let mocChat = Chat(id: "1", type: .individual, name: "John Doe", imageUrl: "https://example.com/profile.jpg", members: [mocUser.id, mocUser2.id], lastMessage: "Hey, how are you?", lastMessageBy: mocUser.id, lastMessageAt: Date(), isPinned: true, isMuted: true, isRead: false, unreadCount: 2, messages: [mocMessage,mocMessage2])
	
	static let mocChat2 = Chat(id: "2", type: .individual, name: "Bruce Wayne", imageUrl: "https://example.com/profile.jpg", members: [mocUser.id, mocUser2.id], lastMessage: "Test Message", lastMessageBy: mocUser2.id, lastMessageAt: Date(), isPinned: true, isMuted: true, isRead: false, unreadCount: 2, messages: [mocMessage,mocMessage2])
	
	static let mocMessage = Message(id: "1", chatId: "1", senderId: mocUser.id, text: "Test Message", imageUrl: "", sentAt: Date(), seenBy: [mocUser.id, mocUser2.id])
	static let mocMessage2 = Message(id: "2", chatId: "1", senderId: mocUser2.id, text: "Test Message2", imageUrl: "", sentAt: Date(), seenBy: [mocUser.id, mocUser2.id])
	
}
