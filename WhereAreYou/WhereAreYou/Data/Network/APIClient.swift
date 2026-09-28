//
//  APIClient.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// Endpoint 기반 네트워크 요청 실행기
protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

/// URLSession 기반 APIClient 구현
final class URLSessionAPIClient: APIClient {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.makeURLRequest()
        } catch {
            throw (error as? NetworkError ?? .invalidURL).appError
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw NetworkError.transport(error).appError
        }

        return try decode(data: data, response: response)
    }

    // MARK: - Private

    /// 응답 검증 및 디코딩
    private func decode<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse.appError
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpStatus(httpResponse.statusCode).appError
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error).appError
        }
    }
}
