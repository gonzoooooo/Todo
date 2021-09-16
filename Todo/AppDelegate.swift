//
//  AppDelegate.swift
//  Todo
//
//  Created by gonzoooooo on 2021/09/10.
//  
//

import Foundation
import UIKit
import UserNotifications

public final class AppDelegate: UIResponder, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        Task {
            if await NotificationClient.shared.requestAuthorization() {
                print("granted")
            }
        }

        return true
    }
}
