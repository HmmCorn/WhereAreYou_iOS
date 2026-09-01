//
//  DIContainer.swift
//  WhereAreYou
//
//  Created by 김성훈 on 8/26/26.
//

import Foundation

/// register/resolve 방식의 DI 컨테이너
final class DIContainer {

    static let shared = DIContainer()

    private var factories: [ObjectIdentifier: () -> Any] = [:]

    private init() { }

    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
    }

    func register<T>(_ type: T.Type, instance: T) {
        factories[ObjectIdentifier(type)] = { instance }
    }

    func resolve<T>(_ type: T.Type = T.self) -> T {
        guard let factory = factories[ObjectIdentifier(type)], let resolved = factory() as? T else {
            fatalError("\(type)가 DIContainer에 등록되어 있지 않습니다.")
        }
        return resolved
    }

}
