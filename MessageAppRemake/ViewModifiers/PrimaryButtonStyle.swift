//
//  ViewModifiers.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

struct PrimaryButtonStyle: View {
	let text: String
	let sysyemImage: String
	let backgroundColor: Color
	let width: CGFloat
	
	var body: some View {
		HStack {
			Text(text)
			Image(systemName: sysyemImage)
		}
		.padding()
		.frame(width: width)
		.foregroundStyle(.white)
		.background(backgroundColor)
		.clipShape(RoundedRectangle(cornerRadius: 25))
	}
}
