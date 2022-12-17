//
//  Pipeline.swift
//  Diffusion
//
//  Created by Pedro Cuenca on December 2022.
//  See LICENSE at https://github.com/huggingface/swift-coreml-diffusers/LICENSE
//

import Foundation
import CoreML
import Combine

typealias StableDiffusionProgress = StableDiffusionPipeline.Progress

class Pipeline {
    let pipeline: StableDiffusionPipeline
    
    var progress: StableDiffusionProgress? = nil {
        didSet {
            progressPublisher.value = progress
        }
    }
    lazy private(set) var progressPublisher: CurrentValueSubject<StableDiffusionProgress?, Never> = CurrentValueSubject(progress)


    init(_ pipeline: StableDiffusionPipeline) {
        self.pipeline = pipeline
    }
    
	func generate(prompt: String, scheduler: StableDiffusionScheduler, numInferenceSteps stepCount: Int = 50, imageCount: Int = 1, safetyOn: Bool = false, seed: Int? = nil) throws -> CGImage {
        let beginDate = Date()
        print("Generating...")
        let theSeed = seed ?? Int.random(in: 0..<Int.max)
        let images = try pipeline.generateImages(
            prompt: prompt,
            imageCount: imageCount,
            stepCount: stepCount,
            seed: theSeed,
			disableSafety: !safetyOn,
            scheduler: scheduler
        ) { progress in
            handleProgress(progress)
            return true
        }
        print("Got images: \(images) in \(Date().timeIntervalSince(beginDate))")
        
        // unwrap the 1 image we asked for
        guard let image = images.compactMap({ $0 }).first else { throw "Generation failed" }
        return image
    }

    func handleProgress(_ progress: StableDiffusionPipeline.Progress) {
        self.progress = progress
    }
}
