//
//  SettingsViewController.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 04.07.22.
//

import UIKit
import CoreLocation

class SettingsViewController: UIViewController, LocationUser {
    
    var locationManager: CLLocationManager!

    @IBOutlet var pauseSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let autoPaused = UserDefaults.standard.bool(forKey: PausesVisitAutomatically)
        pauseSwitch.isOn = autoPaused
    }

    @IBAction func toggleAutomaticPauses(_ sender: UISwitch) {
        let autoPaused = sender.isOn
        locationManager.pausesLocationUpdatesAutomatically = autoPaused
        UserDefaults.standard.set(autoPaused, forKey: PausesVisitAutomatically)
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
