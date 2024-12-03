//
//  SortedRetrospects.swift
//  RetsTalk
//
//  Created by HanSeung on 12/2/24.
//

struct SortedRetrospects {
    private let retrospects: [[Retrospect]]
    
    init(_ retrospects: [[Retrospect]] = [[], [], []]) {
        self.retrospects = retrospects
    }
    
    subscript(row: Int) -> [Retrospect] { retrospects[row] }
    subscript(row: Int, column: Int) -> Retrospect { retrospects[row][column] }
}
