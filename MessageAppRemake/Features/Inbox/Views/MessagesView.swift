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
	@State var messageText: String = ""
	
	init(chat: Chat) {
		_viewModel = StateObject(wrappedValue: MessagesViewModel(chat: chat))
	}
	
	var body: some View {
		NavigationStack {
			VStack {
				ScrollViewReader { proxy in
					ScrollView {
						LazyVStack {
							ForEach(viewModel.messages) { message in
								ChatMessageBubble(message: message, currentUserId: viewModel.currentUserId ?? "")
									.id(message.id)
							}.padding(.top, 8)
						}
					}
					.onChange(of: viewModel.messages) {
						withAnimation {
							proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
						}
					}
					.overlay {
						if selectedImage != nil {
							imageView
						}
					}
				}
				inputBar
			}
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					NavigationLink {
						UserDetailsView(user: viewModel.chat.otherUser(for: viewModel.currentUserId ?? "", users: viewModel.users))
					} label: {
						ChatHeader(chat: viewModel.chat, viewModel: viewModel) {
							dismiss()
						}
					}.foregroundStyle(.primary)
				}
			}
			.toolbar(.hidden, for: .tabBar)
			.onChange(of: imagePicker.image) {
				selectedImage = imagePicker.image
			}
		}
	}
	
	private var imageView: some View {
		ZStack {
			Color.black.opacity(0.8)
			selectedImage!
				.resizable()
				.scaledToFit()
				.frame(maxHeight: 500)
			VStack {
				HStack {
					Spacer()
					Button {
						imagePicker.clearSelections()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.resizable()
							.frame(width: 32, height: 32)
							.foregroundStyle(.white).opacity(0.8)
							.padding()
					}
				}
				Spacer()
			}
		}
		.offset(y: 7)
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
			.disabled(!(messageText.isEmpty == false || selectedImage != nil) || viewModel.isSending)
		}
		.padding()
		.background(Color(.systemGray5))
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
			.padding(.trailing)
			CircularProfileImage(url: chat.displayImageURL(for: viewModel.currentUserId ?? "", users: viewModel.users), wSize: 35, hSize: 35)
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
	
	var body: some View {
		HStack {
			if message.senderId == currentUserId {
				Spacer()
				VStack(alignment: .trailing, spacing: 4) {
					VStack(alignment: .leading) {
						if message.imageUrl != "" {
							CircularProfileImage(url: message.imageUrl, wSize: 300, hSize: 200, shape: AnyShape(RoundedRectangle(cornerRadius: 10)))
						}
						if message.text != "" {
							Text(message.text)
								.foregroundColor(.white)
						}
					}
					.padding(8)
					.background(Color.blue)
					.clipShape(ChatBuble(isFromCurrentUser: true))
					
					Text(message.sentAt.formatted(date: .omitted, time: .shortened))
						.font(.caption2)
						.foregroundColor(.gray)
				}
				.frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
			} else {
				VStack(alignment: .leading, spacing: 4) {
					Text(message.text)
						.padding(10)
						.foregroundColor(.black)
						.background(Color(.systemGray5))
						.clipShape(ChatBuble(isFromCurrentUser: false))
					Text(message.sentAt.formatted(date: .omitted, time: .shortened))
						.font(.caption2)
						.foregroundColor(.gray)
				}
				.frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
				Spacer()
			}
		}
		.padding(.horizontal, 8)
	}
}

struct ChatBuble: Shape {
	let isFromCurrentUser: Bool
	
	func path(in rect: CGRect) -> Path {
		let bubbleCornerRadius: CGFloat = min(rect.height / 2, 16)
		let path = UIBezierPath(roundedRect: rect,
								byRoundingCorners: [
									.topLeft,
									.topRight,
									isFromCurrentUser ? .bottomLeft : .bottomRight
								],
								cornerRadii: CGSize(width: bubbleCornerRadius, height: bubbleCornerRadius))
		return Path(path.cgPath)
	}
}

#Preview {
	MessagesView(chat: MockData.mocChat)
}
