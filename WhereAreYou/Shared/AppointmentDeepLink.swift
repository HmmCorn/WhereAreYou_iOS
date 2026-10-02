//
//  AppointmentDeepLink.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-26.
//

import Foundation

/// 라이브 액티비티에서 앱으로 들어오는 링크 — 위젯은 URL을 만들고 앱은 URL을 해석한다.
/// 형식: whereareyou://appointment/{약속 ID}/{route | share-location}
enum AppointmentDeepLink {

    /// 약속 지도 화면 열기
    case route(appointmentID: String)
    /// 채팅방을 열고 내 위치를 바로 전송
    case shareLocation(appointmentID: String)

    var appointmentID: String {
        switch self {
        case .route(let appointmentID), .shareLocation(let appointmentID):
            return appointmentID
        }
    }

    static let scheme = "whereareyou"
    private static let host = "appointment"
    private static let routePath = "route"
    private static let shareLocationPath = "share-location"

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        switch self {
        case .route(let appointmentID):
            components.path = "/\(appointmentID)/\(Self.routePath)"
        case .shareLocation(let appointmentID):
            components.path = "/\(appointmentID)/\(Self.shareLocationPath)"
        }
        // path에 들어가는 값은 약속 ID뿐이라 URL 생성이 실패하지 않는다
        return components.url!
    }

    init?(url: URL) {
        guard url.scheme == Self.scheme, url.host == Self.host else { return nil }

        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard pathComponents.count == 2 else { return nil }

        let appointmentID = pathComponents[0]
        switch pathComponents[1] {
        case Self.routePath:
            self = .route(appointmentID: appointmentID)
        case Self.shareLocationPath:
            self = .shareLocation(appointmentID: appointmentID)
        default:
            return nil
        }
    }

}
