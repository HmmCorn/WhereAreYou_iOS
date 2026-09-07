//
//  MyPageScreenFactory.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

protocol MyPageScreenFactory: AnyObject {

    func makeMyPageViewController() -> MyPageViewController

}

extension ScreenFactory: MyPageScreenFactory { }
