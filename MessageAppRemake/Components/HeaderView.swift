//
//  HeaderView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

struct HeaderView: View {
	let title: String
	let subtitle: String
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(title)
					.bold()
					.font(.largeTitle)
				Text(subtitle)
					.foregroundColor(.gray)
			}
			.padding()
			Spacer()
		}
	}
}
