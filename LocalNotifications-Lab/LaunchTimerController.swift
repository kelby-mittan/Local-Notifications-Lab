//
//  LaunchTimerController.swift
//  LocalNotifications-Lab
//
//  Created by Kelby Mittan on 2/20/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import UIKit

protocol LaunchTimerControllerDelegate: AnyObject {
    func didCreateNotification(_ createNotificationController: LaunchTimerController)
}

class LaunchTimerController: UIViewController {
    
    @IBOutlet var titleTextField: UITextField!
    
    @IBOutlet var pickerView: UIPickerView!
    
    weak var delegate: LaunchTimerControllerDelegate?
    
    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow + 0.05
    
    public var totalSecs = 0.0
    
    public var hourSecs = 0.0
    
    public var minSecs = 0.0
    
    public var secs = 0.0
    
    public var countdownString = "N/A"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    private func createLocalNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = titleTextField.text ?? "No Title Given."
        content.body = countdownString
        content.subtitle = "Local Notifications Rock"
        content.sound = .default
        
        let identifier = UUID().uuidString
        
        if let imageURL = Bundle.main.url(forResource: "pursuit-logo", withExtension: "png") {
            do {
                let attatchment = try UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil)
                content.attachments = [attatchment]
            } catch {
                print("error getting attatchment: \(error)")
            }
        } else {
            print("image resource could not be found")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval + totalSecs, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("error adding request: \(error)")
            } else {
                print("request was successfully added")
            }
        }
        
    }
    
    
    @IBAction func launchTimerPressed(_ sender: UIBarButtonItem) {
        createLocalNotification()
        delegate?.didCreateNotification(self)
        dismiss(animated: true)
    }
}

extension LaunchTimerController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return 25
        } else {
            return 61
        }
    }
    
    
}

extension LaunchTimerController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var hours = [String]()
        for i in 0...25 {
            hours.append(i.description)
        }
        var secOrMin = [String]()
        for i in 0...61 {
            secOrMin.append(i.description)
        }
        switch component {
        case 0:
            if row == 0 {
                return "\(hours[row]) hours"
            } else {
                return hours[row]
            }
        case 1:
            if row == 0 {
                return "\(secOrMin[row]) mins"
            } else {
                return secOrMin[row]
            }
        default:
            if row == 0 {
                return "\(secOrMin[row]) secs"
            } else {
                return secOrMin[row]
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        
        switch component {
        case 0:
            hourSecs = Double(row) * 3600
        case 1:
            minSecs = Double(row) * 60
        default:
            secs = Double(row)
            
        }
        
        totalSecs = hourSecs + minSecs + secs
        
        countdownString = totalSecs.asString(style: .full)
        
        print(totalSecs)
        print(totalSecs.asString(style: .full))
    }
}


extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}
