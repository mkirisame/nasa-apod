//
//  HomeRouter.swift
//  nasaapod
//
//  Created by Ivan Reinaldo on 3/20/22.
//

import Foundation
import UIKit
import NetworkLayer

final class HomeRouter {

    private var networkClient = DefaultNetworkClient()

    func start() -> UIViewController {
        let vc = HomeViewController()
        let presenter = HomePresenter(networkClient: networkClient)
        vc.presenter = presenter
        presenter.view = vc
        vc.loadViewIfNeeded()
        return vc
    }
}
