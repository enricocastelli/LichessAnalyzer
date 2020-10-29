//
//  Observable.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 28/10/2020.
//

import UIKit


extension NSNotification.Name {

    static let NewGames = NSNotification.Name("newGames")
    static let CallFinished = NSNotification.Name("callFinished")

}


class FloatingButtonController: UIViewController {

    private(set) var containerView: UIView!
    private(set) var progressView: UIProgressView!
    private(set) var loadingLabel: UILabel!

    private(set) var timer: Timer!

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(note:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    private let window = FloatingButtonWindow()

    override func loadView() {
        let view = UIView()
        let containerView = UIView(frame: CGRect(x: 16, y: 64, width: UIScreen.main.bounds.width - 32, height: 80))
        containerView.backgroundColor = UIColor.white
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize.zero
        containerView.sizeToFit()
        containerView.autoresizingMask = []
        view.addSubview(containerView)
        containerView.layer.cornerRadius = 8
        progressView = UIProgressView()
        containerView.addSubview(progressView)
        progressView.setConstraint(constraint: .leading, constant: 16)
        progressView.setConstraint(constraint: .top, constant: 8)
        progressView.setConstraint(constraint: .trailing, constant: -16)
        progressView.setSelfConstraint(constraint: .height, constant: 8)
        progressView.progress = 0.1
        progressView.isUserInteractionEnabled = false
        loadingLabel = UILabel()
        containerView.addSubview(loadingLabel)
        loadingLabel.setConstraint(constraint: .leading, constant: 16)
        loadingLabel.setConstraint(constraint: .bottom, constant: -16)
        loadingLabel.setConstraint(constraint: .trailing, constant: -16)
        loadingLabel.setSelfConstraint(constraint: .height, constant: 32)
        loadingLabel.textAlignment = .center
        loadingLabel.font = Font.with(.light, 14)
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .black
        loadingLabel.isUserInteractionEnabled = false
        self.view = view
        self.containerView = containerView
        window.containerView = containerView
        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire(panner:)))
        containerView.addGestureRecognizer(panner)
        startTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(remove), name: .CallFinished, object: nil)
    }

    @objc func panDidFire(panner: UIPanGestureRecognizer) {
        let offset = panner.translation(in: view)
        panner.setTranslation(CGPoint.zero, in: view)
        var center = containerView.center
        center.x += offset.x
        center.y += offset.y
        containerView.center = center
        if panner.state == .ended || panner.state == .cancelled {
            UIView.animate(withDuration: 0.3) {
                self.snapButtonToSocket()
            }
        }
    }

    @objc func remove() {
        view.removeFromSuperview()
        removeFromParent()
        window.windowScene = nil
        timer.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardDidShow(note: NSNotification) {
        window.windowLevel = UIWindow.Level(rawValue: 0)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }

    private func snapButtonToSocket() {
        var bestSocket = CGPoint.zero
        var distanceToBestSocket = CGFloat.infinity
        let center = containerView.center
        for socket in sockets {
            let distance = hypot(center.x - socket.x, center.y - socket.y)
            if distance < distanceToBestSocket {
                distanceToBestSocket = distance
                bestSocket = socket
            }
        }
        containerView.center = bestSocket
    }

    private var sockets: [CGPoint] {
        let buttonSize = containerView.bounds.size
        let rect = view.bounds.insetBy(dx: buttonSize.width/2, dy: buttonSize.height/2)
        let sockets: [CGPoint] = [
            CGPoint(x: rect.midX, y: rect.minY + 40),
            CGPoint(x: rect.midX, y: rect.maxY - 20),
            CGPoint(x: rect.midX, y: rect.midY)
        ]
        return sockets
    }

    private func startTimer() {
        var updateLabelCount = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
            updateLabelCount += 0.2
            DispatchQueue.main.async {
                if updateLabelCount == 1 {
                    updateLabelCount = 0
                    self.updateLabel()
                }
                if self.progressView.progress > 0.95 {
                    self.progressView.progress = 0
                } else {
                    self.progressView.progress += 0.05
                }
            }
        }
    }

    var secondsElapsed = 0

    private func updateLabel() {
        secondsElapsed += 1
        loadingLabel.text = estimatedDownloadTime()
    }


    func estimatedDownloadTime() -> String {
        guard let gamesNuber = UserData.shared.account?.numberOfGamesForType(UserData.shared.search.gameType) else { return "Loading.."}
        let timeRemaining = ((gamesNuber)/60) - secondsElapsed
        guard timeRemaining > 0 else { return "Loading..." }
        return timeRemaining.secondsToMinutesSecondsString()
    }


}

private class FloatingButtonWindow: UIWindow {

    var containerView: UIView?

    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let containerView = containerView else { return false }
        let buttonPoint = convert(point, to: containerView)
        return containerView.point(inside: buttonPoint, with: event)
    }
}
