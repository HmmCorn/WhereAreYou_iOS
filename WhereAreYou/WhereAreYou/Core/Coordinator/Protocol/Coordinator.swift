//
//  Coordinator.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/3/26.
//

/// 화면전환 책임을 전담하는 타입이 채택하는 프로토콜
protocol Coordinator: AnyObject {

    /// 이 Coordinator가 관리하는 화면 흐름을 시작
    func start()

}
