//
//  NewGroupChatView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI
import PhotosUI

struct NewGroupChatView: View {
	@State var searchText = ""
	@StateObject var viewModel: NewChatViewModel
	@State var preSelectedUsers: [User] = [User]()
	@State var chatName = ""
	@StateObject var imagePicker = ImagePicker()
	@State private var selectedImage: Image? = nil
	@State private var showImagePicker = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					HStack {
						CircularProfileImage(image: selectedImage)
							.onTapGesture {
								showImagePicker = true
							}
							.overlay {
								Image(systemName: selectedImage != nil ? "xmark.circle.fill" : "plus.circle.fill")
									.font(.title2)
									.foregroundStyle(selectedImage != nil ? .gray : .blue)
									.offset(x:25 , y: -25)
									.onTapGesture {
										if selectedImage != nil {
											imagePicker.clearSelections()
										} else {
											showImagePicker = true
										}
									}
							}
						TextField("Group name", text: $chatName)
					}
				}
				
				// User List
				Section("Friends") {
					ForEach(viewModel.filteredUsers(searchText: searchText)) { user in
						HStack {
							UserRow(user: user) {
								if preSelectedUsers.contains(where: { $0.id == user.id }) {
									preSelectedUsers.removeAll(where: { $0.id == user.id })
								} else {
									preSelectedUsers.append(user)
								}
							}.foregroundStyle(.primary)
							Spacer()
							Image(systemName: preSelectedUsers.contains(where: { $0.id == user.id }) ? "checkmark.circle.fill" : "circle")
								.foregroundColor(preSelectedUsers.contains(where: { $0.id == user.id }) ? .blue : .gray)
						}
					}
				}
			}
			.photosPicker(isPresented: $showImagePicker, selection: $imagePicker.imageSelection, matching: .images)
			.searchable(text: $searchText)
			.onChange(of: imagePicker.image) {
				selectedImage = imagePicker.image
			}
			.navigationTitle("New Group Chat")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Create") {
						viewModel.startChat(with: preSelectedUsers, chatName: chatName, imageData: imagePicker.imageData)
					}
				}
			}
		}
	}
}



#Preview {
	NewGroupChatView(viewModel: NewChatViewModel())
}
