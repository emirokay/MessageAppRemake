//
//  SwiftUIView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 28.12.2024.
//

import SwiftUI

struct SwiftUIView: View {
	@State var messages = ["1", "2", "3"]
	
    var body: some View {
		NavigationStack {
			VStack {
				ScrollViewReader { proxy in
					ScrollView {
						LazyVStack {
							ForEach(messages.indices, id: \.self) { index in
								Text(messages[index])
									.id(messages[index].id)
							}
						}
						//.rotationEffect(.degrees(180)) // Flip the content
					}
					//.rotationEffect(.degrees(180)) // Flip the ScrollView back
					.onChange(of: .messages) {
						withAnimation {
							proxy.scrollTo(messages.last?.id, anchor: .bottom)
						}
					}
					
				}
			}
		}
    }
}

#Preview {
    SwiftUIView()
}
