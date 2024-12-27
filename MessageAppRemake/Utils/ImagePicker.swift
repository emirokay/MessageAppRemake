//
//  Untitled.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 7.12.2024.
//

import PhotosUI
import SwiftUI

@MainActor
class ImagePicker: ObservableObject {
	@Published var image: Image?
	@Published var imageData: Data? 
	
	@Published var imageSelection : PhotosPickerItem? {
		didSet {
			if let imageSelection {
				Task {
					await loadImage(from: imageSelection)
				}
			}
		}
	}
	
	func clearSelections() {
		self.image = nil
		self.imageData = nil
		self.imageSelection = nil
	}
	
	private func loadImage(from imageSelection: PhotosPickerItem) async {
		do {
			if let data = try await imageSelection.loadTransferable(type: Data.self),
			   let uiImage = UIImage(data: data) {
				self.imageData = uiImage.jpegData(compressionQuality: 0.5)
				DispatchQueue.main.async {
					self.image = Image(uiImage: uiImage)
				}
			}
		} catch {
			print("Error loading image: \(error.localizedDescription)")
		}
	}
}
