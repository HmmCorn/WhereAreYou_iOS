//
//  Functions+App.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-10-29.
//

import FirebaseFunctions

/// 이 앱이 호출하는 Functions — 리전을 지정하지 않으면 us-central1로 요청이 가므로, 서버 설정(setGlobalOptions)과 같은 리전으로 고정한다
extension Functions {

    static let app = Functions.functions(region: "asia-northeast3")

}
