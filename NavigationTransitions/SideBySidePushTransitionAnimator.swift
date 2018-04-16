//
//  TransitionAnimator.swift
//  NavigationTransitions
//
//  Copyright © 2018 Chili. All rights reserved.
//

import UIKit

class SideBySidePushTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum PushTransitionDirection {
        case left
        case right
    }

    private let nav: BaseNC
    private var duration = 0.4
    private let direction: PushTransitionDirection

    init(direction: PushTransitionDirection, navigationControl: BaseNC) {
        self.direction = direction
        self.nav = navigationControl
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        let width = fromView.frame.size.width
        let centerFrame = CGRect(x: 0, y: 0, width: width, height: fromView.frame.height)
        let completeLeftFrame = CGRect(x: -width, y: 0, width: width, height: fromView.frame.height)
        let completeRightFrame = CGRect(x: width, y: 0, width: width, height: fromView.frame.height)

        switch direction {
        case .left:
            transitionContext.containerView.addSubview(toView)
            toView.frame = completeRightFrame
        case .right:
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
            toView.frame = completeLeftFrame
        }

        toView.layoutIfNeeded()

        let animations: (() -> Void) = { [weak self] in
            guard let direction = self?.direction else { return }
            switch direction {
            case .left:

                self?.nav.increaseBackgroundOffset()
                fromView.frame = completeLeftFrame
            case .right:
                if transitionContext.viewController(forKey: .to) == self?.nav.viewControllers.first {
                    self?.nav.resetBackgroundOffset()
                } else {
                    self?.nav.decreaseBackgroundOffset()
                }

                fromView.frame = completeRightFrame
            }

            toView.frame = centerFrame
        }

        let completion: ((Bool) -> Void) = { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        if transitionContext.isInteractive && direction == .right {
            regular(animations, duration: 0.5, completion: completion)
        } else {
            spring(animations, duration: duration, completion: completion)
        }
    }

    private func spring(_ animations: @escaping (() -> Void), duration: TimeInterval, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .allowUserInteraction,
                       animations: animations, completion: completion)
    }

    private func regular(_ animations: @escaping (() -> Void), duration: TimeInterval, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
