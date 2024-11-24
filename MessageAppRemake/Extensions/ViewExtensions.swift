//
//  ViewExtensions.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

extension View {
	func primaryButtonStyle(backgroundColor: Color = .blue, width: CGFloat = 120, systemImage: String = "arrow.right") -> some View {
		self.modifier(PrimaryButtonStyle(backgroundColor: backgroundColor, width: width, sysyemImage: systemImage))
	}
}
