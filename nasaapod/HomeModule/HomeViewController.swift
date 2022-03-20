//
//  ViewController.swift
//  nasaapod
//
//  Created by Ivan Reinaldo on 3/19/22.
//

import UIKit
import PinLayout
import Kingfisher
import WebKit

final class HomeViewController: UIViewController, HomeViewInput {
    var presenter: HomeViewOutput!
    
    private var initialDate = Date()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker(frame: .zero)
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.contentHorizontalAlignment = .left
        initialDate = picker.date
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .editingDidEnd)
        return picker
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var stateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry Now", for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(retry(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var descLabel: UILabel! = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var webView: WKWebView! = {
        let view = WKWebView()
        view.configuration.allowsInlineMediaPlayback = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView! = {
        let scrollView = UIScrollView(frame: .zero)
        return scrollView
    }()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(datePicker)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(descLabel)
        scrollView.addSubview(webView)
        scrollView.addSubview(stateLabel)
        scrollView.addSubview(retryButton)
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let defaultSpacing: CGFloat = 8
        var totalHeight: CGFloat = 0
        scrollView.pin.all(view.pin.safeArea).margin(defaultSpacing)
        stateLabel.pin.left().top().sizeToFit(.content)
        
        if !retryButton.isHidden {
            retryButton.pin.below(of: stateLabel).margin(defaultSpacing).sizeToFit(.content)
            datePicker.pin.below(of: retryButton).margin(defaultSpacing).left()
            totalHeight += retryButton.bounds.height + defaultSpacing * 2
        } else {
            datePicker.pin.below(of: stateLabel).left()
        }
        titleLabel.pin.below(of: datePicker).margin(defaultSpacing)
            .left()
            .right()
            .sizeToFit(.width)
        totalHeight += datePicker.bounds.height
            + titleLabel.bounds.height
            + stateLabel.bounds.height
            + defaultSpacing
        if !imageView.isHidden {
            imageView.pin.below(of: titleLabel).left().right().aspectRatio()
            descLabel.pin.below(of: imageView).left().right().sizeToFit(.width)
            totalHeight += imageView.bounds.height + descLabel.bounds.height
        } else if !webView.isHidden {
            webView.pin.below(of: titleLabel).left().right().aspectRatio(4/3)
            descLabel.pin.below(of: webView).left().right().sizeToFit(.width)
            totalHeight += webView.bounds.height + descLabel.bounds.height
        }
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width,
                                        height: totalHeight)

    }
    
    // MARK: - view input
    func transitionToViewState(title: String, description: String, mediaURL: URL, isVideo: Bool) {
        retryButton.isHidden = true
        stateLabel.text = "Choose Date"
        imageView.isHidden = isVideo
        webView.isHidden = !isVideo
        titleLabel.text = title
        descLabel.text = description
        imageView.kf.cancelDownloadTask()
        if isVideo {
            webView.load(URLRequest(url: mediaURL))
        } else {
            imageView.kf.setImage(with: mediaURL) { [weak view] res in
                switch res {
                default:
                    view?.setNeedsLayout()
                }
            }
            webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
        view.setNeedsLayout()
    }

    func transitionToErrorState() {
        stateLabel.text = "Error requesting media. Please try again"
        retryButton.isHidden = false
        imageView.image = nil
        descLabel.text = nil
        titleLabel.text = nil
        view.setNeedsLayout()
    }
    
    func transitionToLoadingState() {
        stateLabel.text = "Loading..."
        retryButton.isHidden = true
        imageView.image = nil
        descLabel.text = nil
        titleLabel.text = nil
        view.setNeedsLayout()
    }
    
    func setMaximumDate(_ date: Date) {
        datePicker.maximumDate = date
    }
 
    func setEnableDatePicker(_ enabled: Bool) {
        datePicker.isEnabled = enabled
    }

    // MARK: - private methods
    
    @objc
    private func dateChanged(_ picker: UIDatePicker) {
        if initialDate != picker.date {
            presenter.didSelectDate(picker.date)
            initialDate = picker.date
        }
    }
    
    @objc
    private func retry(_ sender: Any) {
        presenter.didTapRetry(with: datePicker.date)
    }
    
}
