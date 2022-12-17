//
//  PreviewView.swift
//  Diffusion
//
//  Created by Fahim Farook on 15/12/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct PreviewView: View {
	var image: Binding<CGImage?>
	var prompt: Binding<String>
		
	var body: some View {
		if let theImage = image.wrappedValue {
			let imageView = Image(theImage, scale: 1, label: Text("generated"))
			return AnyView(
				VStack {
				imageView.resizable().clipShape(RoundedRectangle(cornerRadius: 20))
					HStack {
						ShareLink(item: imageView, preview: SharePreview(prompt.wrappedValue, image: imageView))
						Button("Save", action: {
							saveImage(cgi: theImage)
						})
					}
			})
		}
		return AnyView(Image("placeholder").resizable())
	}
	
	private func saveImage(cgi: CGImage) {
#if os(macOS)
		let panel = NSSavePanel()
		panel.allowedContentTypes = [.png, .jpeg]
		panel.canCreateDirectories = true
		panel.isExtensionHidden = false
		panel.title = "Save your image"
		panel.message = "Choose a folder and a name to store the image."
		panel.nameFieldLabel = "Image file name:"
		let resp = panel.runModal()
		if resp != .OK {
			return
		}
		guard let url = panel.url else { return }
		let ext = url.pathExtension.lowercased()
		if ext == "png" {
			guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
			CGImageDestinationAddImage(dest, cgi, nil)
			CGImageDestinationFinalize(dest)
		} else if ext == "jpg" {
			guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else { return }
			CGImageDestinationAddImage(dest, cgi, nil)
			CGImageDestinationFinalize(dest)
		} else {
			NSLog("*** Unknown image extension: \(ext)")
		}
#endif
	}
}


struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
		PreviewView(image: .constant(nil), prompt: .constant("Test prompt"))
    }
}
