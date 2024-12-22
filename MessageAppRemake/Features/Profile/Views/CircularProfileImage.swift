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
	var wSize: CGFloat = 64
	var hSize: CGFloat = 64
	var shape: AnyShape = AnyShape(Circle())
	
	@State private var fetchedImage: Image? = nil
	
	var body: some View {
		ZStack {
			if let image = image ?? fetchedImage {
				image
					.resizable()
					.scaledToFill()
					.frame(width: wSize, height: hSize)
					.clipShape(shape)
			} else {
				placeholder
					.resizable()
					.scaledToFill()
					.frame(width: wSize, height: hSize)
					.clipShape(shape)
					.overlay(
						ProgressView()
							.frame(width: wSize / 2, height: hSize / 2)
					)
			}
		}
		.onAppear {
			if let url = url {
				fetchImage(from: url)
			} else if url == nil && image == nil {
				fetchedImage = placeholder
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
			case .failure:
				DispatchQueue.main.async {
					self.fetchedImage = placeholder
				}
			}
		}
	}
}

struct AnyShape: Shape {
	private let _path: (CGRect) -> Path
	
	init<S: Shape>(_ shape: S) {
		self._path = { rect in
			shape.path(in: rect)
		}
	}
	
	func path(in rect: CGRect) -> Path {
		_path(rect)
	}
}
