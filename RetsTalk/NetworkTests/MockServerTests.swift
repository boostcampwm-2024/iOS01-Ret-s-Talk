//
//  MockServerTests.swift
//  NetworkTests
//
//  Created on 11/5/24.
//

import XCTest

final class MockServerTests: XCTestCase {
    private var fetcher: NetworkRequestable?
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        // 리퀘스터 구현체 필요, 이후 URLSession 주입
        // fetcher = NetworkRequestable구현체(urlSession: URLSession(configuration: config))
    }
    
    override func tearDown() {
        fetcher = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
 
    private func fetchResponse(for request: URLRequest) throws -> (HTTPURLResponse, Data) {
        let url = try XCTUnwrap(request.url)
        let response = try XCTUnwrap(
            HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        return (response, Data())
    }
    
    func test_URLRequest생성결과_URL이_기댓값과_동일() async throws {
        // given
        let expectedURL = try XCTUnwrap(URL(string: "https://aip.example.com"))
        
        // when
        MockURLProtocol.requestHandler = { request in
            //then
            XCTAssertEqual(request.url, expectedURL)
            return try self.fetchResponse(for: request)
        }
        
        // 네트워크 요청부분, 구현체 필요
        // try await fetcher?.request(with: <#T##any URLRequestComposable#>)
    }
    
    func test_URLRequest생성결과_Method가_기댓값과_동일() async throws {
        // given
        let expectedMethod = "GET"
        
        // when
        MockURLProtocol.requestHandler = { request in
            // then
            XCTAssertEqual(request.httpMethod, expectedMethod)
            return try self.fetchResponse(for: request)
        }
        
        // 네트워크 요청부분, 구현체 필요
        // try await fetcher?.request(with: <#T##any URLRequestComposable#>)
    }
    
    func test_URLRequest생성결과_Header가_기댓값과_동일() async throws {
        // given
        let expectedHeaders = ["Content-Type": "application/json"]
        
        // when
        MockURLProtocol.requestHandler = { request in
            for (key, value) in expectedHeaders {
                //then
                XCTAssertEqual(request.value(forHTTPHeaderField: key), value, "\(key) 헤더가 기댓값과 다름")
            }
            return try self.fetchResponse(for: request)
        }
        
        // 네트워크 요청부분, 구현체 필요
        // try await fetcher?.request(with: <#T##any URLRequestComposable#>)
    }
}
