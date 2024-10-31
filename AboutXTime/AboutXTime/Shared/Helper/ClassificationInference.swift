//
//  ClassificationInference.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import Foundation
import CoreML
import Vision
import CoreImage
import UIKit

class ClassificationInference {
    var detector: VNCoreMLModel

    init() {
        guard let mlModel = try? yolov8x(configuration: .init()) else {
            fatalError("Failed to load the model.")
        }
        guard let model = try? VNCoreMLModel(for: mlModel.model) else {
            fatalError("Failed to create VNCoreMLModel.")
        }
        self.detector = model
    }

    func performInference(on image: UIImage, completion: @escaping ([Int]) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            print("Error converting UIImage to CIImage.")
            completion([])
            return
        }

        let request = VNCoreMLRequest(model: detector) { [weak self] request, error in
            self?.processObservations(for: request, error: error, completion: completion)
        }
        request.imageCropAndScaleOption = .scaleFill

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        do {
            try handler.perform([request])

        } catch {
            print("Failed to perform vision request: \(error)")
            completion([])
        }
    }

    private func processObservations(for request: VNRequest, error: Error?, completion: @escaping ([Int]) -> Void) {
        if let results = request.results as? [VNRecognizedObjectObservation] {
            var detectedLabelIndices: [Int] = []

            for observation in results {
                if let bestClass = observation.labels.first?.identifier,
                   let labelIndex = labelMapping[bestClass] {
                    detectedLabelIndices.append(labelIndex)
                    print(
                        """
Detected \(bestClass) as index \(labelIndex) with confidence \(observation.labels.first!.confidence * 100)%
"""
                    )
                }
            }

            DispatchQueue.main.async {
                completion(detectedLabelIndices)
            }
        } else {
            print("No results or an error occurred: \(error?.localizedDescription ?? "Unknown error")")
            DispatchQueue.main.async {
                completion([])
            }
        }
    }
}
