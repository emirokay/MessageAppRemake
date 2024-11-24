//
//  ViewModifiers.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

struct PrimaryButtonStyle: ViewModifier {
	let backgroundColor: Color
	let width: CGFloat
	let sysyemImage: String
	
	func body(content: Content) -> some View {
		HStack {
			content
			Image(systemName: sysyemImage)
		}
		.padding()
		.frame(width: width)
		.foregroundStyle(.white)
		.background(backgroundColor)
		.clipShape(RoundedRectangle(cornerRadius: 25))
	}
}
