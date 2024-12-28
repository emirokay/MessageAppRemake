//
//  GroupBioSection.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 23.12.2024.
//

import SwiftUI

struct GroupBioSection: View {
	let about: String
	@Binding var showAboutView: Bool
	let isAdmin: Bool
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Biography")
				.font(.footnote)
				.foregroundColor(Color(.systemGray))
				.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
			
			Button {
				showAboutView = true
			} label: {
				HStack {
					Text(about.isEmpty ? (isAdmin ? "Add group bio" : "No group bio") : about)
						.foregroundStyle(about.isEmpty ? .gray : .primary)
					Spacer()
					Image(systemName: "chevron.right")
						.foregroundStyle(.gray)
						.opacity(isAdmin ? 1 : 0)
				}
			}
			.padding(12)
			.background(Color(.systemGray6))
			.cornerRadius(10)
			.disabled(!isAdmin)
		}
		.padding(.horizontal, 24)
	}
}
