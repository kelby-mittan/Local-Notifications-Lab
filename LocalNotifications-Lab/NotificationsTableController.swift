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
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        configureRefreshControl()
        checkForNotificationAuthorization()
        loadNotifications()
        center.delegate = self
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadNotifications), for: .valueChanged)
    }
    
    @objc private func loadNotifications() {
        pendingNotification.getPendingNotifications { (requests) in
            self.notifications = requests
            
            // stop the refresh control from animating and remove from the UI
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
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
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        
        let notification = notifications[indexPath.row]
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.body
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNotification(atIndexPath: indexPath)
        }
    }
    
    private func removeNotification(atIndexPath indexPath: IndexPath) {
        
        let notification = notifications[indexPath.row]
        let identifier = notification.identifier
        
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        notifications.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
    }
    
}

extension NotificationsTableController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
}
