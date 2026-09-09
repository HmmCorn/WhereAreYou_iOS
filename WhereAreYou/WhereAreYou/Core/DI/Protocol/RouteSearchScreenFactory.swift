//
//  RouteSearchScreenFactory.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/7/26.
//

protocol RouteSearchScreenFactory: SearchPlaceScreenFactory {

    func makeRouteSearchViewController(departure: Place?, destination: Place?) -> RouteSearchViewController

}

extension ScreenFactory: RouteSearchScreenFactory { }
