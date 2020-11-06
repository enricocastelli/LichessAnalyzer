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
        window.backgroundColor = .clear
        let loadingView = LoadingView()
        loadingView.alpha = 0
        window.addContentView(loadingView)
        UIView.animate(withDuration: 0.4) {
            loadingView.alpha = 1
        }
    }

    func hideLoadingAnimation() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first, let loadingView = window.subviews.filter({ $0.isKind(of: LoadingView.self)}).first else {
                return }
            UIView.animate(withDuration: 0.4) {
                loadingView.alpha = 0
            } completion: { (_) in
                loadingView.removeFromSuperview()
            }
        }
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
        backgroundColor = UIColor.white.withAlphaComponent(0)
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        addContentView(blurView)
        let act = UIActivityIndicatorView(style: .large)
        act.tintColor = .darkGray
        act.startAnimating()
        addContentView(act)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
