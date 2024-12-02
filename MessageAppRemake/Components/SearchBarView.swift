//
//  SearchBarView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

struct SearchBarView: View {
	@Binding var searchText: String

	var body: some View {
		HStack {
			// Search Icon
			Image(systemName: "magnifyingglass")
				.foregroundColor(.gray)

			// Text Field
			TextField("Search", text: $searchText)

			// Clear Button
			if !searchText.isEmpty {
				Button(action: {
					searchText = ""
				}) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.gray)
				}
			}
		}
		.padding(10)
		.background(Color(.systemGray5).opacity(0.5)) // Background color
		.cornerRadius(10)
		.padding(.horizontal)
	}
}


#Preview {
	@Previewable @State var searchText = ""
	SearchBarView(searchText: $searchText)
}
