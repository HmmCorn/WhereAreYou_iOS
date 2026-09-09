//
//  SearchPlaceScreenFactory.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

protocol SearchPlaceScreenFactory: AnyObject {

    func makeSearchPlaceCardViewController(
        selectionButtonTitle: String,
        style: SearchPlaceCardViewController.Style
    ) -> SearchPlaceCardViewController

}

extension ScreenFactory: SearchPlaceScreenFactory { }
