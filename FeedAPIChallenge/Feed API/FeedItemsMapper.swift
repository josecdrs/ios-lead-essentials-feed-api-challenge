//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

struct FeedItemsMapper {
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
