//
//  LoadingView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.11.2024.
//

import SwiftUI

struct LoadingView: View {
	let show: Bool
	var body: some View {
		if show {
			ZStack {
				Group {
					Rectangle()
						.fill(.black.opacity(0.25))
						.ignoresSafeArea()
					
					ProgressView()
						.padding(15)
						.background(.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
				}
			}
			.animation(.easeInOut(duration: 0.25), value: show)
		}
	}
}
