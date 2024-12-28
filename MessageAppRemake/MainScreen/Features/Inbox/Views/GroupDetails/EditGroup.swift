//
//  EditGroup.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.12.2024.
//

import SwiftUI

struct EditGroup: View {
	@State var chat: Chat
	@State var chatName: String
	@ObservedObject var viewModel: MessagesViewModel
	
	@StateObject var imagePicker = ImagePicker()
	@State var showImagePicker = false
	@State var selectedImage: Image?
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack{
			VStack {
				CircularProfileImage(image: selectedImage, url: chat.imageUrl, wSize: 100, hSize: 100)
					.onTapGesture {
						showImagePicker = true
					}
					.overlay {
						Image(systemName: selectedImage != nil ? "xmark.circle.fill" : "plus.circle.fill")
							.font(.largeTitle)
							.foregroundStyle(selectedImage != nil ? .gray : .blue)
							.background(.white)
							.clipShape(Circle())
							.offset(x:40 , y: -40)
							.onTapGesture {
								if selectedImage != nil {
									imagePicker.clearSelections()
								} else {
									showImagePicker = true
								}
							}
					}
					.padding()
				
				Text("Edit group name and picture")
					.font(.footnote)
					.foregroundStyle(.gray)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.horizontal)
				
				TextField("Chat Name", text: $chatName)
					.font(.body)
					.padding(10)
					.background(Color(.secondarySystemBackground))
					.cornerRadius(10)
					.padding(.horizontal)
				
				Spacer()
			}
			.onChange(of: imagePicker.image) {
				self.selectedImage = imagePicker.image
			}
			.photosPicker(isPresented: $showImagePicker, selection: $imagePicker.imageSelection, matching: .images)
			.navigationTitle("Edit Group Info")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Save") {
						viewModel.saveGroupInfo(chatName: chatName, about: "", imageData: imagePicker.imageData)
						dismiss()
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel") {
						dismiss()
					}.foregroundStyle(.red)
				}
			}
		}
	}
}
