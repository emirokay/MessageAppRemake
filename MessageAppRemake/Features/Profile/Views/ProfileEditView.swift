//
//  ProfileUpdateView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 3.12.2024.
//

import SwiftUI

struct ProfileEditView: View {
	@ObservedObject var viewModel: ProfileViewModel
	@State private var name: String = ""
	@State private var about: String = ""
	@State private var showAboutView = false
	@State private var showEdit = false
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					HStack {
						Image(systemName: "person.circle.fill")
							.resizable()
							.frame(width: 64, height: 64)
							.padding(.trailing, 8)
						Text("Enter your name and choose a profile picture")
					}
					TextField("Enter your name", text: $name)
						.padding(6)
				}
				
				Section("Email") {
					Text(viewModel.getCurrentUser().email)
				}
				
				Section("About") {
					Button {
						showAboutView.toggle()
					}label: {
						HStack {
							Text(viewModel.getCurrentUser().about.isEmpty ? "Add something about yourself" : viewModel.getCurrentUser().about)
							
							Spacer()
							Image(systemName: "chevron.right")
								.foregroundStyle(.gray)
						}
					}
					.foregroundStyle(.primary)
				}
			}
			.navigationTitle("Edit Profile")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden()
			.onChange(of: name, {
				if name != viewModel.getCurrentUser().name {
					showEdit = true
				}
			})
			.onAppear {
				self.name = viewModel.getCurrentUser().name
				self.about = viewModel.getCurrentUser().about
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					if showEdit {
						Button("Save"){
							viewModel.saveUser(name: name, about: about)
							showEdit = false
						}
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					if showEdit {
						Button("Cancel"){
							
							self.name = viewModel.getCurrentUser().name
							showEdit.toggle()
						}.foregroundStyle(.red)
					} else {
						Button {
							dismiss()
						} label: {
							Image(systemName: "chevron.left")
								.font(.system(size: 16, weight: .medium))
								.foregroundColor(.blue)
						}
					}
				}
			}
			.fullScreenCover(isPresented: $showAboutView) {
				NavigationStack{
					VStack(alignment: .leading) {
						TextEditor(text: $about)
							.padding(4)
							.frame(maxHeight: UIScreen.main.bounds.height / 5)
							.textEditorStyle(PlainTextEditorStyle())
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
							Button("Cancel"){
								showAboutView.toggle()
							}
							.foregroundColor(.red)
						}
						
						ToolbarItem(placement: .topBarTrailing) {
							Button("Save"){
								viewModel.saveUser(name: name, about: about)
								showAboutView = false
							}
						}
					}
				}
			}
		}
	}
}

#Preview {
	ProfileEditView(viewModel: ProfileViewModel())
}
