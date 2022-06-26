//
//  RegionViewController.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 26.06.22.
//

import UIKit
import CoreLocation

class RegionViewController: UIViewController {

    var locationManager: CLLocationManager!

    @IBOutlet var identifierLabel: UILabel!
    public var identifier: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        identifierLabel.text = identifier;
    }
    
    @IBAction func deleteRegion() {

        for region in locationManager.monitoredRegions.filter({ region in
            region.identifier == identifier
        }) {
            locationManager.stopMonitoring(for: region)
        }
        self.dismiss(animated: true)
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
