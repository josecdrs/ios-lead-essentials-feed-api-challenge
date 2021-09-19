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
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, urlResponse)):
				completion(FeedItemsMapper.decode(data, urlResponse))
			}
		}
	}
}

// MARK: - Helpers

private struct FeedItemsMapper {
	private static var OK_200: Int {
		200
	}

	private struct APIFeedImageResponse: Decodable {
		let items: [APIFeedImage]
	}

	private struct APIFeedImage: Decodable {
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

		func mapToFeedImage() -> FeedImage {
			FeedImage(id: id,
			          description: description,
			          location: location,
			          url: url)
		}
	}

	static func decode(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard
			response.statusCode == OK_200,
			let decoded = try? JSONDecoder().decode(APIFeedImageResponse.self, from: data)
		else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(decoded.items.map { $0.mapToFeedImage() })
	}
}
