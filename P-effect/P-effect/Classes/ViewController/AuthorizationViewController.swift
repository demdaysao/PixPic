//
//  AuthorizationViewController.swift
//  P-effect
//
//  Created by anna on 1/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast
import ParseFacebookUtilsV4

final class AuthorizationViewController: UIViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Authorization
    
    var router: protocol<FeedPresenter, AlertManagerDelegate>!
    private weak var locator: ServiceLocator!
    
    lazy var locator = ServiceLocator()

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: убрать, это будет происходить в роутере
        locator.registerService(ReachabilityService())
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertManager.sharedInstance.registerAlertListener(router)
    }
    
    @IBAction private func logInWithFBButtonTapped() {
        view.makeToastActivity(CSToastPositionCenter)
        signInWithFacebook()
    }
    
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    private func signInWithFacebook() {
        let authService: AuthService = locator.getService()
        authService.signInWithFacebookInController(self) { [weak self] _, error in
            if let error = error {
                handleError(error)
                self?.proceedWithoutAuthorization()
            } else {
                authService.signInWithPermission { _, error -> Void in
                    if let error = error {
                        handleError(error)
                    } else {
                        PFInstallation.addPFUserToCurrentInstallation()
                    }
                }
                self?.view.hideToastActivity()
                self?.router.showFeed()
            }
        }
    }
    
    private func proceedWithoutAuthorization() {
        router.showFeed()
	let reachabilityService: ReachabilityService = locator.getService()
        if reachabilityService.isReachable() {
            AlertService.simpleAlert("No internet connection")
        }
    }
    
}