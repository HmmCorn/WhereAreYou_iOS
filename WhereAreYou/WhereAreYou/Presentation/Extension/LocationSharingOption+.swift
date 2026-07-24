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

}
