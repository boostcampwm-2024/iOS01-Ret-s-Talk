//
//  NetworkComposerTests.swift
//  NetworkTests
//
//  Created on 11/5/24.
//

import XCTest

final class NetworkComposerTests: XCTestCase {
    private var composer: (any URLRequestComposable<String>)?
    
    // MARK: Set up
    
    override func setUp() {
        // composer = 구현
    }
    
    // MARK: Test
    
    func test_경로_합성_결과값이_기대값과_같은지() throws {
        let composer = try XCTUnwrap(composer)
        let expectedPath = "/test"
        
        let composed = composer.configurePath(expectedPath)
        
        XCTAssertEqual(composed.path, expectedPath)
    }

    func test_HTTPMethod_합성_결과값이_기대값과_같은지() throws {
        let composer = try XCTUnwrap(composer)
        let expectedHTTPMethod = HTTPMethod.get
        
        let composed = composer.configureMethod(expectedHTTPMethod)
        
        XCTAssertEqual(composed.method, expectedHTTPMethod)
    }
    
    func test_헤더를_합성_결과값이_기대값과_같은지() throws {
        let composer = try XCTUnwrap(composer)
        let expectedHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer YOUR_ACCESS_TOKEN",
            "Cache-Control": "no-cache",
        ]
        
        let composed = composer.configureHeader(expectedHeaders)
        
        XCTAssertEqual(composed.header, expectedHeaders)
    }
    
    func test_데이터_합성_결과값이_기대값과_같은지() throws {
        let composer = try XCTUnwrap(composer)
        let expectedString = #function
        let expectedStringData = expectedString.data(using: .utf8)
        
        let composed = composer.configureData(expectedStringData)
        
        let composedStringData = try XCTUnwrap(composed.data as? Data)
        let composedString = try XCTUnwrap(String(data: composedStringData, encoding: .utf8))
        XCTAssertEqual(composedString, expectedString)
    }
    
    func test_파라미터_합성_결과값이_기대값과_같은지() throws {
        let composer = try XCTUnwrap(composer)
        let expectedQuery = TestableParameter()
        let expectedQueryDict = try XCTUnwrap(expectedQuery.stringDictionary)
        
        let composed = composer.configureQuery(expectedQuery)
        
        let composedQueryDict = try XCTUnwrap(composed.query?.stringDictionary)
        
        XCTAssertEqual(composedQueryDict, expectedQueryDict)
    }
    
    // MARK: Helper
    
    private struct TestableParameter: Encodable {
        let key: String
        let value: String
        let date: Date
        
        init() {
            key = UUID().uuidString
            value = UUID().uuidString
            date = Date()
        }
    }
}
