//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, urlResponse)):
				guard urlResponse.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}

				do {
					_ = try JSONDecoder().decode(APIFeedImageResponse.self, from: data)
					completion(.success([]))
				} catch {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}

// MARK: - APIFeedImage

struct APIFeedImageResponse: Decodable {
	let items: [APIFeedImage]
}

struct APIFeedImage: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL

	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}

	init(id: UUID, description: String?, location: String?, url: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
}
