//
//  CancellableRequest+Foundation.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/29/26.
//

import Foundation

extension URLSessionDataTask: CancellableRequest {}

extension DispatchWorkItem: CancellableRequest {}
