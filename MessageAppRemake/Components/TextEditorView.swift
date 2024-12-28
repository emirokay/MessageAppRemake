//
//  TextEditorView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.12.2024.
//

import SwiftUI

struct TextEditorView: View {
	@Binding var about: String
	var currentAbout: String
	@Binding var showAboutView: Bool
	let action: () -> Void
	
	var body: some View {
		NavigationStack {
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
						action()
						showAboutView = false
					}
				}
			}
		}
	}
}
