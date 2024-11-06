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
    
 
    func test_URLRequest생성결과_URL이_기댓값과_동일() async throws {
        // given
        let expectedURL = URL(string: "https://api.example.com")!
        
        // when
        MockURLProtocol.requestHandler = { request in
            //then
            XCTAssertEqual(request.url, expectedURL)
            
            guard let response = HTTPURLResponse(
                url: expectedURL, statusCode: 200, httpVersion: nil, headerFields: nil
            )
            else {
                throw XCTSkip("URLResponse is nil")
            }
            return (response, Data())
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
            
            guard let url = request.url else {
                throw XCTSkip("URL is nil")
            }
            guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                throw XCTSkip("URLResponse is nil")
            }
            return (response, Data())
        }
        
        // 네트워크 요청부분, 구현체 필요
        // try await fetcher?.request(with: <#T##any URLRequestComposable#>)
    }
    
    
    func test_URLRequest생성결과_Header가_기댓값과_동일() async throws {
        // given
        let expectedHeaders = ["Content-Type": "application/json"]
        
        // when
        MockURLProtocol.requestHandler = { request in
            // then
            for (key, value) in expectedHeaders {
                XCTAssertEqual(request.value(forHTTPHeaderField: key), value, "\(key) 헤더가 기댓값과 다름")
            }
            
            guard let url = request.url else {
                throw XCTSkip("URL is nil")
            }
            guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                throw XCTSkip("URLResponse is nil")
            }
            return (response, Data())
        }
        
        // 네트워크 요청부분, 구현체 필요
        // try await fetcher?.request(with: <#T##any URLRequestComposable#>)
    }
}
