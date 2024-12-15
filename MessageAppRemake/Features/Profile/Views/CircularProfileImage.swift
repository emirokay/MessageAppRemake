//
//  CircularProfileImage.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 10.12.2024.
//

import SwiftUI
import Alamofire

struct CircularProfileImage: View {
	var image: Image? = nil
	var url: String? = nil
	var placeholder: Image = Image("nullProfile")
	var size: CGFloat = 64

	@State private var fetchedImage: Image? = nil

	var body: some View {
		ZStack {
			if let image = image ?? fetchedImage {
				image
					.resizable()
					.scaledToFill()
					.frame(width: size, height: size)
					.clipShape(Circle())
			} else {
				placeholder
					.resizable()
					.scaledToFill()
					.frame(width: size, height: size)
					.clipShape(Circle())
					.overlay(
						ProgressView()
							.frame(width: size / 2, height: size / 2)
					)
			}
		}
		.onAppear {
			if let url = url {
				fetchImage(from: url)
			}
		}
		.onChange(of: url) {
			guard let url else { return }
			fetchImage(from: url)
		}
	}
	
	private func fetchImage(from url: String) {
		guard !url.isEmpty, let validUrl = URL(string: url) else {
			self.fetchedImage = placeholder
			return
		}
		
		AF.request(validUrl).responseData { response in
			switch response.result {
			case .success(let data):
				if let uiImage = UIImage(data: data) {
					DispatchQueue.main.async {
						self.fetchedImage = Image(uiImage: uiImage)
					}
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self.fetchedImage = placeholder
				}
			}
		}
	}
}
