//
//  InputField.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

struct InputFieldView: View {
	let icon: String
	let placeholder: String
	@Binding var text: String
	var isSecure: Bool = false
	
	var body: some View {
		HStack {
			Image(systemName: icon)
				.foregroundStyle(.gray)
			if isSecure {
				SecureField(placeholder, text: $text)
			} else {
				TextField(placeholder, text: $text)
			}
		}
		.padding()
		.background(Color(.systemGray6))
		.cornerRadius(10)
		.padding(.horizontal)
	}
}
