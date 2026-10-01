//
//  WhereAreYouWidgetBundle.swift
//  WhereAreYouWidget
//
//  Created by 이상유 on 2026-09-26.
//

import SwiftUI
import WidgetKit

/// 위젯 익스텐션 진입점 — 현재는 약속 이동 라이브 액티비티만 제공한다
@main
struct WhereAreYouWidgetBundle: WidgetBundle {

    var body: some Widget {
        AppointmentRouteLiveActivity()
    }

}
