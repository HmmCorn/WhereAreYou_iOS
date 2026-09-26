//
//  MockAppointmentDetailRepository.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import Foundation

final class MockAppointmentDetailRepository: AppointmentDetailRepository {

    func fetchAppointment(
        appointmentID: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserID: String), Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let appointment = Self.makeMockAppointment(appointmentID: appointmentID)
            completion(.success((appointment: appointment, currentUserID: Self.currentUserID)))
        }
    }

    func fetchAppointment(
        code: String,
        completion: @escaping (Result<(appointment: Appointment, currentUserID: String), Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard code == Self.mockCode else {
                completion(.failure(AppError.notFound))
                return
            }
            let appointment = Self.makeMockAppointment(appointmentID: "appointment_joined")
            completion(.success((appointment: appointment, currentUserID: Self.currentUserID)))
        }
    }

    private static let currentUserID = "user_me"

    /// 내 경로 시나리오 — DEBUG 라이브 액티비티 시작 메뉴에서 바꿔 가며 확인한다
    static var myRouteScenario: MockMyRouteScenario = .subwayTransfer
    /// true면 약속 시각을 5분 전으로 당긴다 — 약속 시간이 지난 상태의 라이브 액티비티 확인용
    static var startsAfterAppointmentTime = false
    private static let mockCode = "MOCK1234"

    private static func makeMockAppointment(appointmentID: String) -> Appointment {
        let place = Place(
            id: "place_starbucks_gangnam",
            name: "스타벅스 강남역점",
            address: "서울 강남구 강남대로 396",
            coordinate: Coordinate(latitude: 37.4979, longitude: 127.0276),
            type: .cafe
        )

        let now = Date()
        // 약속 시각과 내 경로만 당긴다. 다른 참여자 경로는 지도 표시용이라 그대로 둔다
        let myTimelineBase = startsAfterAppointmentTime ? now.addingTimeInterval(-30 * 60) : now

        let users: [User] = [
            User(
                id: currentUserID,
                nickname: "나",
                profileImage: "shark",
                defaultTransportMode: .car,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_minji",
                nickname: "김민지",
                profileImage: "turtle",
                defaultTransportMode: .transit,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_seoyeon",
                nickname: "이서연",
                profileImage: "shark",
                defaultTransportMode: .car,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_junwoo",
                nickname: "박준우",
                profileImage: "turtle",
                defaultTransportMode: .transit,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_gildong",
                nickname: "최길동",
                profileImage: "shark",
                defaultTransportMode: .walk,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
            User(
                id: "user_subin",
                nickname: "정수빈",
                profileImage: "turtle",
                defaultTransportMode: .car,
                locationSharingScope: .onlyDuringAppointment,
                isNotificationEnabled: true,
                appointmentsNotification: [:]
            ),
        ]

        let routes: [String: Route] = [
            currentUserID: makeMyRoute(
                to: place, departureTime: myTimelineBase.addingTimeInterval(1 * 60)
            ),
            "user_minji": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-40 * 60),
                arrivalTime: now.addingTimeInterval(8 * 60),
                start: Coordinate(latitude: 37.5040, longitude: 127.0350),
                transportType: .transit
            ),
            "user_seoyeon": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-38 * 60),
                arrivalTime: now.addingTimeInterval(7 * 60),
                start: Coordinate(latitude: 37.4990, longitude: 127.0120),
                transportType: .car
            ),
            "user_junwoo": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-30 * 60),
                arrivalTime: now.addingTimeInterval(10 * 60),
                start: Coordinate(latitude: 37.4900, longitude: 127.0300),
                transportType: .transit
            ),
            "user_gildong": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-25 * 60),
                arrivalTime: now.addingTimeInterval(15 * 60),
                start: Coordinate(latitude: 37.4965, longitude: 127.0230),
                transportType: .walk
            ),
            "user_subin": makeRoute(
                to: place, departureTime: now.addingTimeInterval(-20 * 60),
                arrivalTime: now.addingTimeInterval(11 * 60),
                start: Coordinate(latitude: 37.5010, longitude: 127.0400),
                transportType: .car
            ),
        ]

        return Appointment(
            id: appointmentID,
            code: Self.mockCode,
            name: "고기굽는방앗간 이수역점",
            dateTime: myTimelineBase.addingTimeInterval(25 * 60),
            place: place,
            participants: users,
            routes: routes,
            placeVoteStatus: [:]
        )
    }

    private static func makeRoute(
        to destination: Place,
        departureTime: Date,
        arrivalTime: Date,
        start: Coordinate,
        transportType: TransportType
    ) -> Route {
        let departurePlace = Place(
            id: "start_\(UUID().uuidString)",
            name: "출발지",
            address: "",
            coordinate: start,
            type: .other
        )

        let path = interpolatedPath(from: start, to: destination.coordinate, segments: 6)

        let step = RouteStep(
            departurePoint: departurePlace,
            destination: destination,
            estimatedTime: arrivalTime.timeIntervalSince(departureTime) / 60,
            distance: start.distance(to: destination.coordinate),
            transportType: transportType,
            path: path
        )

        return Route(
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            step: [step],
            totalDistance: step.distance
        )
    }

    private static func interpolatedPath(
        from start: Coordinate, to end: Coordinate, segments: Int
    ) -> [Coordinate] {
        (0...segments).map { index in
            let ratio = Double(index) / Double(segments)
            let jitter = (index % 2 == 0 ? 1.0 : -1.0) * 0.0006 * (1 - ratio)
            return Coordinate(
                latitude: start.latitude + (end.latitude - start.latitude) * ratio + jitter,
                longitude: start.longitude + (end.longitude - start.longitude) * ratio
            )
        }
    }

    /// 모든 시나리오가 1분 뒤 출발, 23분 이동, 약속 1분 전 도착으로 맞춰져 있다
    private static func makeMyRoute(to destination: Place, departureTime: Date) -> Route {
        let steps: [RouteStep]
        switch myRouteScenario {
        case .subwayTransfer:
            steps = makeSubwayTransferSteps(to: destination)
        case .busAndSubway:
            steps = makeBusAndSubwaySteps(to: destination)
        case .car:
            steps = makeCarSteps(to: destination)
        }

        let totalMinutes = steps.reduce(0) { $0 + $1.estimatedTime }
        return Route(
            departureTime: departureTime,
            arrivalTime: departureTime.addingTimeInterval(totalMinutes * 60),
            step: steps,
            totalDistance: steps.reduce(0) { $0 + $1.distance }
        )
    }

    private static let mockHome = Place(
        id: "mock_home", name: "출발지", address: "",
        coordinate: Coordinate(latitude: 37.4880, longitude: 126.9870), type: .other
    )

    /// 도보 → 4호선 → 환승 도보 → 2호선 → 도보
    /// 단계: 출발 → 이수역 → 사당역 → 강남역 → 도착
    private static func makeSubwayTransferSteps(to destination: Place) -> [RouteStep] {
        let isu = Place(
            id: "mock_station_isu", name: "이수역", address: "",
            coordinate: Coordinate(latitude: 37.4863, longitude: 126.9819), type: .subway
        )
        let sadang4 = Place(
            id: "mock_station_sadang_4", name: "사당역", address: "",
            coordinate: Coordinate(latitude: 37.4766, longitude: 126.9816), type: .subway
        )
        let sadang2 = Place(
            id: "mock_station_sadang_2", name: "사당역", address: "",
            coordinate: Coordinate(latitude: 37.4765, longitude: 126.9814), type: .subway
        )
        let gangnam = Place(
            id: "mock_station_gangnam", name: "강남역", address: "",
            coordinate: Coordinate(latitude: 37.4980, longitude: 127.0276), type: .subway
        )

        return [
            makeStep(from: mockHome, to: isu, minutes: 6, transportType: .walk),
            makeStep(from: isu, to: sadang4, minutes: 2, transportType: .transit,
                     lineName: "4호선", lineColorHex: "#00A5DE", stopCount: 1),
            makeStep(from: sadang4, to: sadang2, minutes: 3, transportType: .walk),
            makeStep(from: sadang2, to: gangnam, minutes: 8, transportType: .transit,
                     lineName: "2호선", lineColorHex: "#00A84D", stopCount: 4),
            makeStep(from: gangnam, to: destination, minutes: 4, transportType: .walk),
        ]
    }

    /// 도보 → 간선버스 740 → 환승 도보 → 2호선 → 도보
    /// 단계: 출발 → 방배경찰서 → 교대역 → 강남역 → 도착
    private static func makeBusAndSubwaySteps(to destination: Place) -> [RouteStep] {
        let busStop = Place(
            id: "mock_bus_stop_bangbae", name: "방배경찰서", address: "",
            coordinate: Coordinate(latitude: 37.4895, longitude: 126.9935), type: .station
        )
        let busStopGyodae = Place(
            id: "mock_bus_stop_gyodae", name: "교대역", address: "",
            coordinate: Coordinate(latitude: 37.4930, longitude: 127.0130), type: .station
        )
        let gyodae = Place(
            id: "mock_station_gyodae", name: "교대역", address: "",
            coordinate: Coordinate(latitude: 37.4934, longitude: 127.0142), type: .subway
        )
        let gangnam = Place(
            id: "mock_station_gangnam", name: "강남역", address: "",
            coordinate: Coordinate(latitude: 37.4980, longitude: 127.0276), type: .subway
        )

        return [
            makeStep(from: mockHome, to: busStop, minutes: 3, transportType: .walk),
            makeStep(from: busStop, to: busStopGyodae, minutes: 12, transportType: .transit,
                     lineName: "740", lineColorHex: "#3D5BAB", stopCount: 5),
            makeStep(from: busStopGyodae, to: gyodae, minutes: 2, transportType: .walk),
            makeStep(from: gyodae, to: gangnam, minutes: 2, transportType: .transit,
                     lineName: "2호선", lineColorHex: "#00A84D", stopCount: 1),
            makeStep(from: gangnam, to: destination, minutes: 4, transportType: .walk),
        ]
    }

    /// 도보 → 자차 → 도보
    /// 단계: 출발 → 도착 (탑승역이 없으므로 중간 단계 없음)
    private static func makeCarSteps(to destination: Place) -> [RouteStep] {
        let homeParking = Place(
            id: "mock_parking_home", name: "집 주차장", address: "",
            coordinate: Coordinate(latitude: 37.4884, longitude: 126.9876), type: .other
        )
        let gangnamParking = Place(
            id: "mock_parking_gangnam", name: "강남역 공영주차장", address: "",
            coordinate: Coordinate(latitude: 37.4972, longitude: 127.0262), type: .other
        )

        return [
            makeStep(from: mockHome, to: homeParking, minutes: 2, transportType: .walk),
            makeStep(from: homeParking, to: gangnamParking, minutes: 17, transportType: .car),
            makeStep(from: gangnamParking, to: destination, minutes: 4, transportType: .walk),
        ]
    }

    private static func makeStep(
        from: Place,
        to: Place,
        minutes: Double,
        transportType: TransportType,
        lineName: String? = nil,
        lineColorHex: String? = nil,
        stopCount: Int? = nil
    ) -> RouteStep {
        RouteStep(
            departurePoint: from,
            destination: to,
            estimatedTime: minutes,
            distance: from.coordinate.distance(to: to.coordinate),
            transportType: transportType,
            path: interpolatedPath(from: from.coordinate, to: to.coordinate, segments: 3),
            lineName: lineName,
            lineColorHex: lineColorHex,
            stopCount: stopCount
        )
    }

}

/// MockAppointmentDetailRepository가 돌려주는 내 경로 종류
enum MockMyRouteScenario: CaseIterable {

    case subwayTransfer
    case busAndSubway
    case car

    var title: String {
        switch self {
        case .subwayTransfer: return "지하철 환승"
        case .busAndSubway: return "버스 + 지하철"
        case .car: return "자차"
        }
    }

}
