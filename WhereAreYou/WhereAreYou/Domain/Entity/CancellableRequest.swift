//
//  CancellableRequest.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

/// 진행 중인 요청을 취소하기 위한 핸들
protocol CancellableRequest {
    func cancel()
}
