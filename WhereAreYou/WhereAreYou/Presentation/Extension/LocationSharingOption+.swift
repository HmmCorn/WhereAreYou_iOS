//
//  LocationSharingOption+.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

extension LocationSharingOption {

    var title: String {
        switch self {
        case .always: return "항상 공유"
        case .onlyDuringAppointment: return "약속 참여 중에만 공유"
        case .never: return "공유 안 함"
        }
    }

    var description: String {
        switch self {
        case .always: return "내 위치 항상 공유"
        case .onlyDuringAppointment: return "약속 진행 중일 때만 공유"
        case .never: return "내 위치 공유 안함"
        }
    }

    var iconName: String {
        switch self {
        case .always: return "location.fill"
        case .onlyDuringAppointment: return "location"
        case .never: return "location.slash"
        }
    }

}
