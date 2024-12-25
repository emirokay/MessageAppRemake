//
//  ChatService.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 3.12.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine

protocol ChatRepositoryProtocol {
	func fetchChats(for userId: String) -> AnyPublisher<[Chat], Error>
	func fetchMessages(chatId: String) -> AnyPublisher<[Message], Error>
	func fetchUsersInChats(for userIds: [String]) -> AnyPublisher<[User], Error>
	func fetchAllUsers() async throws -> [User]
	func createChat(chat: Chat) async throws
	func sendMessage(chatId: String, message: Message) async throws
	func uploadImage(chatId: String, imageData: Data, isGroup: Bool) async throws -> String
	func uploadChatData(chat: Chat, userId: String) async throws 
	func markMessagesAsSeen(chatId: String, messageIds: [String], userId: String) async throws
}

final class ChatRepository: ChatRepositoryProtocol {
	private let db = Firestore.firestore()
	private let storage = Storage.storage()
	
	func fetchChats(for userId: String) -> AnyPublisher<[Chat], Error> {
		let subject = PassthroughSubject<[Chat], Error>()
		db.collection("chats")
			.whereField("memberIds", arrayContains: userId)
			.addSnapshotListener { snapshot, error in
				if let error = error {
					subject.send(completion: .failure(error))
				} else {
					let chats = snapshot?.documents.compactMap { try? $0.data(as: Chat.self) } ?? []
					subject.send(chats)
				}
			}
		return subject.eraseToAnyPublisher()
	}
	
	func createChat(chat: Chat) async throws {
		let chatRef = db.collection("chats").document(chat.id)
		try chatRef.setData(from: chat)
	}
	
	func fetchAllUsers() async throws -> [User] {
		let snapshot = try await db.collection("users").getDocuments()
		return snapshot.documents.compactMap { try? $0.data(as: User.self) }
	}
	
	func fetchUsersInChats(for userIds: [String]) -> AnyPublisher<[User], Error> {
		let subject = PassthroughSubject<[User], Error>()
		
		guard !userIds.isEmpty else {
			subject.send([])
			subject.send(completion: .finished)
			return subject.eraseToAnyPublisher()
		}
		
		db.collection("users")
			.whereField("id", in: userIds)
			.addSnapshotListener { snapshot, error in
				if let error = error {
					subject.send(completion: .failure(error))
				} else if let documents = snapshot?.documents {
					do {
						let users = try documents.map { try $0.data(as: User.self) }
						subject.send(users)
					} catch {
						subject.send(completion: .failure(error))
					}
				}
			}
		
		return subject.eraseToAnyPublisher()
	}
	
	func fetchMessages(chatId: String) -> AnyPublisher<[Message], Error> {
		let subject = PassthroughSubject<[Message], Error>()
		db.collection("chats")
			.document(chatId)
			.collection("messages")
			.order(by: "sentAt", descending: false)
			.addSnapshotListener { snapshot, error in
				if let error = error {
					subject.send(completion: .failure(error))
				} else {
					let messages = snapshot?.documents.compactMap { try? $0.data(as: Message.self) } ?? []
					subject.send(messages)
				}
			}
		return subject.eraseToAnyPublisher()
	}
	
	func sendMessage(chatId: String, message: Message) async throws {
		var lastMessage = message.text
		if message.text.isEmpty && !message.imageUrl.isEmpty {
			lastMessage = "Photo"
		}
		
		let chatRef = db.collection("chats").document(chatId)
		let messageRef = chatRef.collection("messages").document(message.id)
		
		let batch = db.batch()
		try batch.setData(from: message, forDocument: messageRef)
		batch.updateData([
			"lastMessage": lastMessage,
			"lastMessageBy": message.senderId,
			"lastMessageAt": Timestamp(date: message.sentAt)
		], forDocument: chatRef)
		try await batch.commit()
	}
	
	func uploadImage(chatId: String, imageData: Data, isGroup: Bool) async throws -> String {
		let imageId = UUID().uuidString
		
		let path = isGroup ? "GroupProfileImages/\(chatId).jpg" : "MessageImages/\(chatId)/\(imageId).jpg"
		let storageRef =  storage.reference().child(path)
		
		let _ = try await storageRef.putDataAsync(imageData)
		
		return try await storageRef.downloadURL().absoluteString
	}
	
	func uploadChatData(chat: Chat, userId: String) async throws {
		do {
			let encodedChat = try Firestore.Encoder().encode(chat)
			try await db.collection("chats").document(chat.id).setData(encodedChat)
			
		} catch {
			throw error
		}
	}
	
	func markMessagesAsSeen(chatId: String, messageIds: [String], userId: String) async throws {
		let chatRef = db.collection("chats").document(chatId)
		let batch = db.batch()
		
		for messageId in messageIds {
			let messageRef = chatRef.collection("messages").document(messageId)
			batch.updateData(["seenBy": FieldValue.arrayUnion([userId])], forDocument: messageRef)
		}
		try await batch.commit()
	}
	
}
