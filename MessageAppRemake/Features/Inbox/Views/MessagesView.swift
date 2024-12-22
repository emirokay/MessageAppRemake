//
//  MessagesVies.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI
import PhotosUI

struct MessagesView: View {
	@Namespace private var bottomID
	@Environment(\.dismiss) private var dismiss
	@StateObject var viewModel: MessagesViewModel
	@StateObject var imagePicker = ImagePicker()
	@State private var selectedImage: Image? = nil
	@State private var messageText: String = ""
	
	init(chat: Chat) {
		_viewModel = StateObject(wrappedValue: MessagesViewModel(chat: chat))
	}
	
	var body: some View {
		NavigationStack {
			VStack {
				messageScrollView
				inputBar
			}
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					chatHeader
				}
			}
			.toolbar(.hidden, for: .tabBar)
			.onChange(of: imagePicker.image) {
				selectedImage = imagePicker.image
			}
		}
	}
	
	private var messageScrollView: some View {
		ScrollViewReader { proxy in
			ScrollView {
				LazyVStack {
					ForEach(viewModel.messages.indices, id: \.self) { index in
						ChatMessageBubble(
							message: viewModel.messages[index],
							currentUserId: viewModel.currentUserId ?? "",
							chatType: viewModel.chat.type,
							users: viewModel.users,
							index: index,
							messages: viewModel.messages
						)
						.id(viewModel.messages[index].id)
					}
				}
			}
			.onChange(of: viewModel.messages) {
				withAnimation {
					proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
				}
			}
			.overlay {
				if let image = selectedImage {
					imageView(image: image)
				}
			}
		}
	}
	
	private func imageView(image: Image) -> some View {
		ZStack {
			Color.black.opacity(0.8)
			image
				.resizable()
				.scaledToFit()
				.frame(maxHeight: 500)
			closeButton
		}
		.offset(y: 7)
	}
	
	private var closeButton: some View {
		VStack {
			HStack {
				Spacer()
				Button {
					imagePicker.clearSelections()
				} label: {
					Image(systemName: "xmark.circle.fill")
						.resizable()
						.frame(width: 32, height: 32)
						.foregroundStyle(.white)
						.opacity(0.8)
						.padding()
				}
			}
			Spacer()
		}
	}
	
	private var inputBar: some View {
		HStack(spacing: 8) {
			PhotosPicker(selection: $imagePicker.imageSelection, matching: .images) {
				Image(systemName: "photo.on.rectangle.angled")
					.font(.system(size: 24))
					.foregroundColor(.blue)
			}
			
			TextField("Message...", text: $messageText)
				.padding(8)
				.background(Color(.systemGray6))
				.cornerRadius(20)
			
			Button {
				viewModel.sendMessage(messageText: messageText, imageData: imagePicker.imageData)
				messageText = ""
				imagePicker.clearSelections()
			} label: {
				Text("Send")
					.fontWeight(.bold)
					.foregroundColor(!messageText.isEmpty || selectedImage != nil ? .blue : .gray)
			}
			.disabled(messageText.isEmpty && selectedImage == nil || viewModel.isSending)
		}
		.padding()
		.background(Color(.systemGray5))
	}
	
	private var chatHeader: some View {
		NavigationLink {
			UserDetailsView(user: viewModel.chat.otherUser(for: viewModel.currentUserId ?? "", users: viewModel.users))
		} label: {
			ChatHeader(chat: viewModel.chat, viewModel: viewModel, onBack: { dismiss() })
		}
		.foregroundStyle(.primary)
	}
}

struct ChatHeader: View {
	let chat: Chat
	let viewModel: MessagesViewModel
	let onBack: () -> Void
	
	var body: some View {
		HStack(spacing: 8) {
			Button(action: onBack) {
				Image(systemName: "chevron.left")
					.font(.system(size: 16, weight: .medium))
					.foregroundColor(.blue)
			}
			CircularProfileImage(
				url: chat.displayImageURL(for: viewModel.currentUserId ?? "", users: viewModel.users),
				wSize: 35,
				hSize: 35
			)
			VStack(alignment: .leading) {
				Text(chat.chatName(for: viewModel.currentUserId ?? "", users: viewModel.users))
					.fontWeight(.semibold)
				Text("Tap for more info")
					.font(.footnote)
					.foregroundColor(.gray)
			}
		}
		.padding(.vertical, 10)
	}
}

struct ChatMessageBubble: View {
	let message: Message
	let currentUserId: String
	let chatType: Chat.ChatType
	let users: [User]
	let index: Int
	let messages: [Message]
	
	var body: some View {
		HStack {
			if isCurrentUser {
				Spacer()
				messageBubble(isFromCurrentUser: true)
			} else {
				messageBubble(isFromCurrentUser: false)
				Spacer()
			}
		}
		.padding(.horizontal)
		.padding(.top, isFirstMessageInSequence ? 8 : 0)
		.frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
	}
	
	private var isCurrentUser: Bool {
		message.senderId == currentUserId
	}
	
	@ViewBuilder
	private func messageBubble(isFromCurrentUser: Bool) -> some View {
		VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
			if chatType == .group, !isFromCurrentUser, isFirstMessageInSequence {
				HStack(spacing: 8) {
					CircularProfileImage(url: senderProfileImageUrl, wSize: 30, hSize: 30)
					Text(senderName)
						.font(.callout)
						.bold()
						.foregroundColor(.gray)
				}
			}
			
			HStack(alignment: .bottom, spacing: 4) {
				if !isFromCurrentUser && chatType == .group {
					Text(message.sentAt.formatted(.dateTime.hour().minute()))
						.font(.caption2)
						.foregroundColor(.gray)
				}
				
				VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
					if !message.imageUrl.isEmpty {
						CircularProfileImage(
							url: message.imageUrl,
							wSize: UIScreen.main.bounds.width * 0.7,
							hSize: 200,
							shape: AnyShape(RoundedRectangle(cornerRadius: 10))
						)
					}
					
					if !message.text.isEmpty {
						HStack(alignment: .bottom, spacing: 4) {
							if isFromCurrentUser {
								Spacer()
								Text(message.sentAt.formatted(.dateTime.hour().minute()))
									.font(.caption2)
									.foregroundColor(.gray)
									.padding(.top, 4)
							}
							
							Text(message.text)
								.padding(10)
								.foregroundColor(isFromCurrentUser ? .white : .black)
								.background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
								.clipShape(ChatBubble(isFromCurrentUser: isFromCurrentUser))
							
							if !isFromCurrentUser && chatType == .individual {
								Text(message.sentAt.formatted(.dateTime.hour().minute()))
									.font(.caption2)
									.foregroundColor(.gray)
									.padding(.top, 4)
							}
						}
					}
				}
				.frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isFromCurrentUser ? .trailing : .leading)
			}
		}
		.padding(.top, isFirstMessageInSequence ? 8 : 4)
	}
	
	private var isFirstMessageInSequence: Bool {
		guard index > 0 else { return true }
		return messages[index - 1].senderId != message.senderId
	}
	
	private var senderName: String {
		users.first(where: { $0.id == message.senderId })?.name ?? ""
	}
	
	private var senderProfileImageUrl: String {
		users.first(where: { $0.id == message.senderId })?.profileImageURL ?? ""
	}
}

struct ChatBubble: Shape {
	let isFromCurrentUser: Bool
	
	func path(in rect: CGRect) -> Path {
		let bubbleCornerRadius: CGFloat = 13
		let corners: UIRectCorner = isFromCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]
		let path = UIBezierPath(
			roundedRect: rect,
			byRoundingCorners: corners,
			cornerRadii: CGSize(width: bubbleCornerRadius, height: bubbleCornerRadius)
		)
		return Path(path.cgPath)
	}
}

#Preview {
	MessagesView(chat: MockData.mocChat)
}
