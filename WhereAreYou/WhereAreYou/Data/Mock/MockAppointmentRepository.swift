//
//  MockAppointmentRepository.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

/// 약속은 Firestore로 옮겨졌고, 아직 Mock인 경로 저장소가 쓰는 고정 값만 남았다 — 경로 Firestore 연동 때 함께 제거한다
enum MockAppointmentRepository {

    /// true면 내 Mock 경로를 30분 앞당긴다 — 약속 시간이 지난 경로의 라이브 액티비티 확인용.
    /// 약속 시각은 실제 문서 값이라 함께 당겨지지 않는다
    static var startsAfterAppointmentTime = false
    static let place = Place(
        id: "place_starbucks_gangnam",
        name: "스타벅스 강남역점",
        address: "서울 강남구 강남대로 396",
        coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276),
        type: .cafe
    )
    /// 로그인 정보가 없을 때 쓰는 내 ID
    static let fallbackCurrentUserID = "user_me"

}
