//
//  MockServerTests.swift
//  NetworkTests
//
//  Created on 11/5/24.
//

import XCTest

final class MockServerTests: XCTestCase {
    private var fetcher: NetworkRequestable?
    
    // MARK: Set up and tear down
    
    override func setUp() {
        super.setUp()
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: sessionConfiguration)
        fetcher = CLOVAStudioManager(urlSession: mockSession)
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        
        super.tearDown()
    }
 
    // MARK: Test
    
    func test_URLRequest생성결과_URL이_기댓값과_동일() async throws {
        // given
        let urlString = "https://clovastudio.stream.ntruss.com/testapp/v1/chat-completions/HCX-DASH-001"
        let expectedURL = try XCTUnwrap(URL(string: urlString))
        
        // when
        MockURLProtocol.requestHandler = { request in
            // then
            XCTAssertEqual(request.url, expectedURL)
            return try self.fetchResponse(for: request)
        }
        
        _ = try await fetcher?.request(with: CLOVAStudioAPI(path: .chatbot))
    }
    
    func test_URLRequest생성결과_Method가_기댓값과_동일() async throws {
        // given
        let expectedMethod = HTTPMethod.get
        let endpoint = CLOVAStudioAPI(path: .chatbot).configureMethod(expectedMethod)
        
        // when
        MockURLProtocol.requestHandler = { request in
            // then
            XCTAssertEqual(request.httpMethod, expectedMethod.value)
            return try self.fetchResponse(for: request)
        }
        
        _ = try await fetcher?.request(with: endpoint)
    }
    
    func test_URLRequest생성결과_Header가_기댓값과_동일() async throws {
        // given
        let expectedHeaders = ["Content-Type": "application/json"]
        let endpoint = CLOVAStudioAPI(path: .chatbot).configureHeader(expectedHeaders)
        
        // when
        MockURLProtocol.requestHandler = { request in
            for (key, value) in expectedHeaders {
                // then
                XCTAssertEqual(request.value(forHTTPHeaderField: key), value, "\(key) 헤더가 기댓값과 다름")
            }
            return try self.fetchResponse(for: request)
        }
        
        _ = try await fetcher?.request(with: endpoint)
    }
    
    // MARK: Helper
    
    private func fetchResponse(for request: URLRequest) throws -> (HTTPURLResponse, Data) {
        let url = try XCTUnwrap(request.url)
        let response = try XCTUnwrap(
            HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        return (response, Data())
    }
}
