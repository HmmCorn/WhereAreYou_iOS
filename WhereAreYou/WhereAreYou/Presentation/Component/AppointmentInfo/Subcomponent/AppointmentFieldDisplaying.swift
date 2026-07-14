//
//  AppointmentFieldDisplaying.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

/// AppointmentCard의 이름/날짜/장소 행이 mode에 따라 다른 뷰(TextFieldRow, ButtonRow, InfoRow)로
/// 그려지더라도 같은 프로퍼티(nameField, dateRow, placeRow)로 다룰 수 있게 해주는 공통 인터페이스
protocol AppointmentFieldDisplaying: UIView {
    var text: String? { get set }
}

extension TextFieldRow: AppointmentFieldDisplaying {}
extension ButtonRow: AppointmentFieldDisplaying {}
extension InfoRow: AppointmentFieldDisplaying {}
