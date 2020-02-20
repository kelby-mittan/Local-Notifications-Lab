//
//  ViewController.swift
//  LocalNotifications-Lab
//
//  Created by Kelby Mittan on 2/20/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsTableController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    private let center = UNUserNotificationCenter.current()
    
    private let pendingNotification = PendingNotification()
    
    private var notifications = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        checkForNotificationAuthorization()
    }

    private func checkForNotificationAuthorization() {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("app is authorized for notifications")
            } else {
                self.requestNotificationPermissions()
            }
        }
    }
    
    private func requestNotificationPermissions() {
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("error requesting authorization: \(error)")
                return
            }
            if granted {
                print("access was granted")
            } else {
                print("access denied")
            }
        }
    }

}

extension NotificationsTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        
        return cell
    }
    
    
}
