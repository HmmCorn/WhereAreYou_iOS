//
//  APIClient.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

/// Endpoint 기반 네트워크 요청 실행기
protocol APIClient {
    @discardableResult
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> CancellableRequest
}

/// URLSession 기반 APIClient 구현
final class URLSessionAPIClient: APIClient {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    @discardableResult
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> CancellableRequest {
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.makeURLRequest()
        } catch {
            completion(.failure((error as? NetworkError ?? .invalidURL).appError))
            return NoOpCancellableRequest()
        }

        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self else { return }
            self.handle(data: data, response: response, error: error, completion: completion)
        }
        task.resume()
        return task
    }

    // MARK: - Private

    /// 응답 검증 및 디코딩
    private func handle<T: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let error {
            let nsError = error as NSError
            guard nsError.code != NSURLErrorCancelled else { return }
            completion(.failure(NetworkError.transport(error).appError))
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(NetworkError.invalidResponse.appError))
            return
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            completion(.failure(NetworkError.httpStatus(httpResponse.statusCode).appError))
            return
        }
        guard let data else {
            completion(.failure(NetworkError.invalidResponse.appError))
            return
        }
        do {
            let decoded = try decoder.decode(T.self, from: data)
            completion(.success(decoded))
        } catch {
            completion(.failure(NetworkError.decoding(error).appError))
        }
    }
}

/// 요청을 시작조차 못했을 때 반환하는 no-op 취소 핸들
private struct NoOpCancellableRequest: CancellableRequest {
    func cancel() {}
}
