//
//  VideoPicker.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI
import UIKit

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoUrl: URL?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    let videoMaximumDuration: TimeInterval = 300 // 限制影片長度五分鐘

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let mediaUrl = info[.mediaURL] as? URL {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let videoFilename = documentDirectory.appendingPathComponent(mediaUrl.lastPathComponent)

                do {
                    if FileManager.default.fileExists(atPath: videoFilename.path) {
                        try FileManager.default.removeItem(at: videoFilename)
                    }
                    try FileManager.default.copyItem(at: mediaUrl, to: videoFilename)
                    parent.videoUrl = videoFilename
                } catch {
                    print("Failed to copy video file: \(error.localizedDescription)")
                }
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.mediaTypes = ["public.movie"]
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.videoMaximumDuration = videoMaximumDuration

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
