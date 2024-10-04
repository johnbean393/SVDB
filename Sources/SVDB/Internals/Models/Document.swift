//
//  File.swift
//
//
//  Created by Jordan Howlett on 8/4/23.
//

import Foundation
import NaturalLanguage

public struct Document: Codable, Identifiable {
	
    public let id: UUID
    public let text: String
    public let embedding: [Double]
    public let magnitude: Double

    public init(id: UUID? = nil, text: String, embedding: [Double]) {
        self.id = id ?? UUID()
        self.text = text
        self.embedding = embedding
        self.magnitude = sqrt(embedding.reduce(0) { $0 + $1 * $1 })
    }
	
	public init(text: String) throws {
		self.id = UUID()
		self.text = text
		// Identify text language
		let recognizer: NLLanguageRecognizer = NLLanguageRecognizer()
		recognizer.processString(text)
		let language: NLLanguage = recognizer.dominantLanguage ?? .english
		// Get embedding
		guard let embeddingModel: NLEmbedding = NLEmbedding.sentenceEmbedding(
			for: language
		) else {
			throw EmbeddingError.failedToInitEmbeddingModel
		}
		guard let embedding = embeddingModel.vector(for: text) else {
			throw EmbeddingError.failedToGetEmbedding
		}
		self.embedding = embedding
		self.magnitude = sqrt(embedding.reduce(0) { $0 + $1 * $1 })
	}
	
	public enum EmbeddingError: Error {
		case failedToInitEmbeddingModel
		case failedToGetEmbedding
	}
	
}
