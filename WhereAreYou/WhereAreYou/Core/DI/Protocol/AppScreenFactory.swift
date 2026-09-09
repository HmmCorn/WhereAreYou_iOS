//
//  AppScreenFactory.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

protocol AppScreenFactory: AnyObject {

    func makeLoginViewController() -> LoginViewController

}

extension ScreenFactory: AppScreenFactory { }
