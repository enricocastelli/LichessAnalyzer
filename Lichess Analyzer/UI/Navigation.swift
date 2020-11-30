//
//  Navigation.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 09/11/2020.
//

import UIKit

class Navigation: UINavigationController {

    var swipe: UIPanGestureRecognizer!
    var lastVC: UIViewController? {
        return self.viewControllers.last
    }
    var firstVC: UIViewController? {
        return self.viewControllers.first
    }
    var canSwipe = true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.isEnabled = false
        swipe = UIPanGestureRecognizer(target: self, action: #selector(swiped(_:)))
        swipe.delegate = self
        view.addGestureRecognizer(swipe)
    }

    @objc func swiped(_ swipe: UIPanGestureRecognizer) {
        guard canSwipe else { return }
        let loc = swipe.location(in: view)
        guard viewControllers.count > 1, let direction = swipe.direction else { return }
        switch swipe.state {
        case .ended: pop()
        case .began: swipeBegan(loc, direction)
        default: break
        }
    }

    private func swipeBegan(_ loc: CGPoint, _ direction: GestureDirection) {
        guard loc.x < view.frame.width/2, direction == .Right else {
            swipe.isEnabled = false
            defer { swipe.isEnabled = true }
            return
        }
    }

    func push(_ toVC: UIViewController, shouldRemove: Bool = false) {
        guard let window = UIApplication.shared.windows.first,
            let fromVC = lastVC else { return }
        let preanimationPosition: CGFloat = 4.0
        let previousPagePosition = -view.frame.width
        let nextPagePosition = view.frame.width
        toVC.view.frame = UIScreen.main.bounds
        toVC.view.transform = CGAffineTransform(translationX: nextPagePosition, y: 0)
        window.addSubview(toVC.view)
        UIView.animate(withDuration: 0.07, animations: {
            fromVC.view.transform = CGAffineTransform(translationX: preanimationPosition, y: 0)
        }, completion: { (_) in
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: [.allowUserInteraction], animations: {
                fromVC.view.transform = CGAffineTransform(translationX: previousPagePosition, y: 0)
                toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (_) in
                self.viewControllers.append(toVC)
                if shouldRemove {
                    self.viewControllers = [toVC]
                }
            })
        })
    }

    func pop() {
        guard let window = UIApplication.shared.delegate?.window,
            self.viewControllers.count > 1,
            let fromVC = lastVC,
            let index = self.viewControllers.firstIndex(of: fromVC) else { return }
        let toVC = self.viewControllers[index - 1]
        let preanimationPosition: CGFloat = -8.0
        let previousPagePosition = view.frame.width
        let nextPagePosition = -view.frame.width
        toVC.view.transform = CGAffineTransform(translationX: nextPagePosition, y: 0)
        window?.addSubview(toVC.view)
        UIView.animate(withDuration: 0.07, animations: {
            fromVC.view.transform = CGAffineTransform(translationX: preanimationPosition, y: 0)
        }, completion: { (_) in
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.allowUserInteraction], animations: {
                fromVC.view.transform = CGAffineTransform(translationX: previousPagePosition, y: 0)
                toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (_) in
                self.viewControllers.removeLast()
            })
        })
    }
}

extension Navigation: UIGestureRecognizerDelegate {

}

extension UIPanGestureRecognizer {

    var direction: GestureDirection? {
        let vel = velocity(in: view)
        let vertical = abs(vel.y) > abs(vel.x)
        switch (vertical, vel.x, vel.y) {
        case (true, _, let y) where y < 0: return .Up
        case (true, _, let y) where y > 0: return .Down
        case (false, let x, _) where x > 0: return .Right
        case (false, let x, _) where x < 0: return .Left
        default: return nil
        }
    }
}


enum GestureDirection: Int {
    case Up
    case Down
    case Left
    case Right

    public var isX: Bool { return self == .Left || self == .Right }
    public var isY: Bool { return !isX }
}
