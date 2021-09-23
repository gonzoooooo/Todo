//
//  ExtensionDelegate.swift
//  TodoApp
//
//  Created by gonzoooooo on 2021/09/19.
//  
//

import WatchKit

final class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                let watchExtension = WKExtension.shared()
                let targetDate = Date().addingTimeInterval(15.0 * 60.0)

                watchExtension.scheduleBackgroundRefresh(
                    withPreferredDate: targetDate,
                    userInfo: nil
                ) { error in
                    if let error = error {
                        print("error: \(error)")
                    }

                    backgroundTask.setTaskCompletedWithSnapshot(true)
                }
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}
