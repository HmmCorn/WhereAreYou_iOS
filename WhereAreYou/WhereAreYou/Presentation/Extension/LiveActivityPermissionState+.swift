//
//  LiveActivityPermissionState+.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

extension LiveActivityPermissionState {

    var title: String {
        switch self {
        case .allowed: return "허용"
        case .denied: return "허용 안 함"
        }
    }

}
