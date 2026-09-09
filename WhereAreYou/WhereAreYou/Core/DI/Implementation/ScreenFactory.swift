//
//  ScreenFactory.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

import Foundation

/// DIContainer를 이용해 화면을 조립하는 책임을 전담
final class ScreenFactory {

    static let shared = ScreenFactory()

    let container: DIContainer

    init(container: DIContainer = .shared) {
        self.container = container
    }

}
