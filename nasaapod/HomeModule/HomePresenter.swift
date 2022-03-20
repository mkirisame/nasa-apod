//
//  HomePresenter.swift
//  nasaapod
//
//  Created by Ivan Reinaldo on 3/19/22.
//

import Foundation
import UIKit
import NetworkLayer

protocol HomeViewInput: AnyObject {
    func transitionToViewState(title: String,
                               description: String,
                               mediaURL: URL,
                               isVideo: Bool)
    func transitionToErrorState()
    func transitionToLoadingState()
    func setMaximumDate(_ date: Date)
    func setEnableDatePicker(_ enabled: Bool)
}

protocol HomeViewOutput: AnyObject {
    func viewDidLoad()
    func didSelectDate(_ date: Date)
    func didTapRetry(with date: Date)
}

final class HomePresenter: HomeViewOutput {

    weak var view: HomeViewInput!
    unowned var networkClient: NetworkClient
    
    var hadDoneInitialRequest = false
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - view output
    func viewDidLoad() {
        view.setEnableDatePicker(false)
        makeRequest(date: nil)
    }
    
    func didSelectDate(_ date: Date) {
        makeRequest(date: date)
    }
    
    func didTapRetry(with date: Date) {
        if hadDoneInitialRequest {
            makeRequest(date: date)
        } else {
            makeRequest(date: nil)
        }
    }
    
    // MARK: - private methods
    private func makeRequest(date: Date?) {
        view.transitionToLoadingState()
        networkClient.makeRequest(NasaApodRequest(date: date), responseQueue: .main) { [weak view, weak self] res in
            switch res {
            case .success(let response):
                view?.transitionToViewState(
                    title: response.title,
                    description: response.explanation,
                    mediaURL: response.url,
                    isVideo: response.mediaType == .video
                )
                if !(self?.hadDoneInitialRequest ?? true) {
                    self?.hadDoneInitialRequest = true
                    view?.setMaximumDate(response.date)
                    view?.setEnableDatePicker(true)
                }
            case .failure:
                view?.transitionToErrorState()
            }
        }
    }
    
}
