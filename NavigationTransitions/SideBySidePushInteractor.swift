//
//  PushNavigationInteractor.swift
//  NavigationTransitions
//
//  Copyright © 2018 Chili. All rights reserved.
//

import UIKit

protocol NavigationInteractionProxy {
    var isPerforming: Bool { get }
}

class SideBySidePushInteractor: UIPercentDrivenInteractiveTransition, NavigationInteractionProxy {
    private weak var navigationController: UINavigationController?
    private let transitionCompletionThreshold: CGFloat = 0.5
    var completion: (() -> Void)?

    var isPerforming: Bool = false

    init?(attachTo viewController: UIViewController) {
        guard let nav = viewController.navigationController else { return nil }

        self.navigationController = nav
        super.init()
        setupBackGesture(view: viewController.view)
    }

    private func setupBackGesture(view: UIView) {
        let swipeBackGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleBackGesture(_:)))
        swipeBackGesture.edges = .left
        view.addGestureRecognizer(swipeBackGesture)
    }

    override func finish() {
        super.finish()
        completion?()
    }

    @objc private func handleBackGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let nav = navigationController else { return }

        let viewTranslation = gesture.translation(in: gesture.view?.superview)
        let transitionProgress = viewTranslation.x / nav.view.frame.width

        switch gesture.state {
        case .began:
            isPerforming = true
            nav.popViewController(animated: true)
        case .changed:
            update(transitionProgress)
        case .cancelled:
            isPerforming = false
            cancel()
        case .ended:
            if gesture.velocity(in: gesture.view).x > 300 {
                finish()
                return
            }
            isPerforming = false
            transitionProgress > transitionCompletionThreshold ? finish() : cancel()
        default:
            return
        }
    }
}
