/*
 * telekom / geo-test-ios
 *
 * SettingsViewController.swift
 * Created by Alexander von Below on 04.07.22.
 * Copyright (c) 2022 Deutsche Telekom AG
 *
 * This program is made available under the terms of the 
 * MIT license which is available at
 * https://opensource.org/licenses/MIT
 *
 * SPDX-License-Identifier: MIT 
 */

import UIKit
import CoreLocation
import os.log

class SettingsViewController: UIViewController, LocationUser {
    
    var locationManager: CLLocationManager!

    @IBOutlet var pauseSwitch: UISwitch!
    @IBOutlet var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sheetController = self.presentationController as? UISheetPresentationController {
            sheetController.detents = [.medium(), .large()]
            sheetController.prefersGrabberVisible = true
        }

        let autoPaused = UserDefaults.standard.bool(forKey: PausesVisitAutomatically)
        pauseSwitch.isOn = autoPaused
        if let infoDict = Bundle.main.infoDictionary,
           let cfBundleVersion = infoDict["CFBundleVersion"],
           let cfBundleShortVersion = infoDict["CFBundleShortVersionString"] {
            let versionPretext = NSLocalizedString("Version:", comment: "")
            versionLabel.text = "\(versionPretext) \(cfBundleShortVersion)(\(cfBundleVersion))"
        } else {
            versionLabel.text = NSLocalizedString(
                "Version unknown",
                comment: "")
        }
    }

    @IBAction func toggleAutomaticPauses(_ sender: UISwitch) {
        let autoPaused = sender.isOn
        locationManager.pausesLocationUpdatesAutomatically = autoPaused
        UserDefaults.standard.set(autoPaused, forKey: PausesVisitAutomatically)
    }

    @IBAction func clearLogs() {
        presentClearAlert(
            title: NSLocalizedString(
                "Clear Log",
                comment: ""),
            message: NSLocalizedString(
                "Are you sure you want to delete the complete log?",
                comment: ""),
            buttonTitle: "Clear Log",
            handler: { _ in
                do {
                    let storage = PersistantStorage<EventRecord>()
                    try storage.deleteAll()
                } catch {
                    os.Logger().error("\(error)")
                }
            })
    }
    
    @IBAction func clearRegions() {
        
        presentClearAlert(
            title: NSLocalizedString(
                "Clear Regions",
                comment: ""),
            message: NSLocalizedString(
                "Are you sure you want to delete all monitored regions?",
                                       comment: ""),
            buttonTitle: NSLocalizedString(
                "Clear Regions",
                comment: "")
        ) { [self]_ in
            for region in self.locationManager.monitoredRegions {
                self.locationManager.stopMonitoring(for: region)
            }
            NotificationCenter.default.post(Notification(
                name: RegionsListViewController.UpdateNotificationName))
        }
    }
    
    func presentClearAlert(title: String?,
                            message: String?,
                            buttonTitle: String?,
                            handler: @escaping (UIAlertAction) -> Void) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: buttonTitle,
            style: .destructive,
            handler: handler))
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString(
                "Cancel",
                comment: ""),
            style: .cancel))
        self.present(
            alert,
            animated: true)
    }
    
    @IBAction func contactAlex() {
        let url = URL(string: "https://dt.enterprise.slack.com/user/@UDWJH0JE7")!
        UIApplication.shared.open(url)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
