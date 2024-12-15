//
//  ProfileUpdateView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 3.12.2024.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
	@ObservedObject var viewModel: ProfileViewModel
	@StateObject var imagePicker = ImagePicker()
	@State private var selectedImage: Image? = nil
	@State private var name: String = ""
	@State private var about: String = ""
	@State private var showAboutView = false
	@State private var showEdit = false
	@Environment(\.dismiss) private var dismiss
	
	init(viewModel: ProfileViewModel) {
		_viewModel = ObservedObject(wrappedValue: viewModel)
		let currentUser = viewModel.getCurrentUser()
		_name = State(initialValue: currentUser.name)
		_about = State(initialValue: currentUser.about)
	}
	
	private func checkForChanges() {
		let currentUser = viewModel.getCurrentUser()
		showEdit = name != currentUser.name ||
		about != currentUser.about ||
		selectedImage != nil
	}
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					HStack {
						PhotosPicker(selection: $imagePicker.imageSelection, matching: .images) {
							if let selectedImage = selectedImage {
								CircularProfileImage(image: selectedImage)
							} else {
								CircularProfileImage(url: viewModel.getCurrentUser().profileImageURL)
							}
						}
						Text("Enter your name and choose a profile picture")
					}
					TextField("Enter your name", text: $name)
						.padding(6)
				}
				Section("Email") {
					Text(viewModel.getCurrentUser().email)
				}
				AboutSection(about: $about, showAboutView: $showAboutView)
			}
			.navigationTitle("Edit Profile")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden()
			.onChange(of: name) { checkForChanges() }
			.onChange(of: about) { checkForChanges() }
			.onChange(of: imagePicker.image) {
				selectedImage = imagePicker.image
				checkForChanges()
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					if showEdit {
						Button("Save", action: {
							let imageData = imagePicker.imageData ?? Data()
							viewModel.saveUser(name: name, about: about, imageData: imageData)
							showEdit = false
						})
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					if showEdit {
						Button("Cancel", action: {
							name = viewModel.getCurrentUser().name
							about = viewModel.getCurrentUser().about
							imagePicker.clearSelections()
							showEdit = false
						})
						.foregroundStyle(.red)
					} else {
						Button("Back") {
							dismiss()
						}
					}
				}
			}
			.fullScreenCover(isPresented: $showAboutView) {
				NavigationStack {
					TextEditorView(about: $about, currentAbout: viewModel.getCurrentUser().about ,showAboutView: $showAboutView)
				}
			}
		}
	}
	
	struct AboutSection: View {
		@Binding var about: String
		@Binding var showAboutView: Bool
		
		var body: some View {
			Section("About") {
				Button {
					showAboutView.toggle()
				} label: {
					HStack {
						Text(about.isEmpty ? "Add something about yourself" : about)
							.foregroundStyle(about.isEmpty ? .gray : .primary)
						
						Spacer()
						Image(systemName: "chevron.right")
							.foregroundStyle(.gray)
					}
				}
				.foregroundStyle(.primary)
			}
		}
	}
	
	struct TextEditorView: View {
		@Binding var about: String
		var currentAbout: String
		@Binding var showAboutView: Bool
		
		var body: some View {
			VStack(alignment: .leading) {
				TextEditor(text: $about)
					.padding(4)
					.frame(maxHeight: UIScreen.main.bounds.height / 5)
					.background(Color(.tertiarySystemBackground))
					.cornerRadius(10)
					.padding(.horizontal, 24)
				
				Spacer()
			}
			.padding(.top)
			.background(Color(.secondarySystemBackground))
			.navigationTitle("About")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel") {
						about = currentAbout
						showAboutView = false
					}
					.foregroundColor(.red)
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button("Done") {
						showAboutView = false
					}
				}
			}
		}
	}
}

#Preview {
	ProfileEditView(viewModel: ProfileViewModel())
}
