//
//  LoadingVC.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 02/11/2020.
//

import UIKit

extension UIViewController {

    func showLoadingAnimation() {
        guard let window = UIApplication.shared.windows.first, window.subviews.filter({ $0.isKind(of: LoadingView.self)}).isEmpty else {
            return }
        window.addContentView(LoadingView())
    }

    func hideLoadingAnimation() {
        guard let window = UIApplication.shared.windows.first, let loadingView = window.subviews.filter({ $0.isKind(of: LoadingView.self)}).first else {
            return }
        loadingView.removeFromSuperview()
    }
}

extension UIWindow {

    override open func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if let loading = subviews.filter({ $0.isKind(of: LoadingView.self)}).first as? LoadingView {
            bringSubviewToFront(loading)
        }
    }
}

class LoadingView: UIView {

    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .white
        let act = UIActivityIndicatorView(style: .large)
        act.tintColor = .darkGray
        act.startAnimating()
        addContentView(act)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
