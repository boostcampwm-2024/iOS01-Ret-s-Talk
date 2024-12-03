//
//  Persistable.swift
//  RetsTalk
//
//  Created by MoonGoon on 11/11/24.
//

import Foundation

protocol Persistable: Actor {
    /// 로컬 저장소에 엔티티 데이터를 추가합니다.
    /// - Parameter entities: 추가할 엔티티 배열.
    /// - Returns: 추가된 데이터.
    func add<Entity>(contentsOf entities: [Entity]) async throws -> [Entity] where Entity: EntityRepresentable
    /// 로컬 저장소에서 요청 조건에 맞는 엔티티 데이터를 불러옵니다.
    /// - Parameter request: 요청 조건.
    /// - Returns: 엔티티 데이터.
    func fetch<Entity>(
        by request: any PersistFetchRequestable<Entity>
    ) async throws -> [Entity] where Entity: EntityRepresentable
    /// 로컬 저장소의 엔티티 데이터에 대한 최신화를 수행합니다.
    /// - Parameters:
    ///   - entity: 최신화할 엔티티 값.
    ///   - predicate: 최신화 할 엔티티 데이터를 찾기 위한 조건문.
    /// - Returns: 최신화 된 엔티티 데이터.
    func update<Entity>(
        from sourceEntity: Entity,
        to updatingEntity: Entity
    ) async throws -> Entity where Entity: EntityRepresentable
    /// 로컬 저장소에서 엔티티 데이터를 제거합니다.
    /// - Parameter entities: 제거할 엔티티 데이터.
    func delete<Entity>(contentsOf entities: [Entity]) async throws where Entity: EntityRepresentable
}
