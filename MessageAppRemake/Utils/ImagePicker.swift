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
	@Published var imageData: Data?  //= Data()
	@Published var images: [Image?] = []
	@Published var imageDatas: [Data] = []
	
	@Published var imageSelection : PhotosPickerItem? {
		didSet {
			if let imageSelection {
				Task {
					await loadImage(from: imageSelection)
				}
			}
		}
	}
	
	@Published var imageSelections: [PhotosPickerItem] = [] {
		didSet {
			Task {
				if !imageSelections.isEmpty {
					await loadImages(from: imageSelections)
				}
			}
		}
	}
	
	func clearSelections() {
		self.image = nil
		self.imageData = nil
		self.images.removeAll()
		self.imageDatas.removeAll()
		self.imageSelection = nil
	}
	
	private func loadImage(from imageSelection: PhotosPickerItem) async {
		do {
			if let data = try await imageSelection.loadTransferable(type: Data.self),
				let uiImage = UIImage(data: data) {
				self.imageData = data
				DispatchQueue.main.async {
					self.image = Image(uiImage: uiImage)
				}
			}
		} catch {
			print("Error loading image: \(error.localizedDescription)")
		}
	}
	
	private func loadImages(from imageSelections: [PhotosPickerItem]) async {
		do {
			for imageSelection in imageSelections {
				if let data = try await imageSelection.loadTransferable(type: Data.self),
				   let uiImage = UIImage(data: data) {
					self.imageDatas.append(data)
					DispatchQueue.main.async {
						self.images.append(Image(uiImage: uiImage))
					}
				}
			}
		} catch {
			print("Error loading images: \(error.localizedDescription)")
		}
	}
	
}
