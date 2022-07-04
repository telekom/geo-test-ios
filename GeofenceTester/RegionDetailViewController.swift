//
//  RegionViewController.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 26.06.22.
//

import UIKit
import CoreLocation
import os.log

class RegionDetailViewController: UIViewController, Loggable, LocationUser {

    var locationManager: CLLocationManager!
    var logger: Logger!

    @IBOutlet var identifierField: UITextField!
    @IBOutlet var radiusLabel: UILabel!
    @IBOutlet var radiusSlider: UISlider!
    
    public var identifier: String!
    public var radius: CLLocationDistance!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        identifierField.text = identifier;
        
        guard let input = radius else {
            return
        }
        radiusSlider.value = Float(input)
        self.updateRadiusValue(input)
    }
    
    private func updateRadiusValue(_ input: CLLocationDistance) {
        let measurement: Measurement<UnitLength>
        let meters = Measurement(value: input, unit: UnitLength.meters)
        if Locale.current.usesMetricSystem {
            measurement = meters
        } else {
            let feet = meters.converted(to: .feet)
            measurement = feet
        }
        self.radiusLabel.text = measurement.formatted()
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let input = Double(sender.value)
        updateRadiusValue(input)
    }
    
    @IBAction func changeRegion() {
        
        let newRadius = CLLocationDistance(radiusSlider.value)
        
        if let newId = identifierField.text, newId != identifier || newRadius != radius {
            // Only change if we really have new values
            
            guard let region = locationManager.monitoredRegions.first(where: {
                $0.identifier == identifier
            }) as? CLCircularRegion else {
                logger.error("Unable to find monitored region with identifier \(self.identifier)")
                return
            }
            
            let newRegion = CLCircularRegion(center: region.center,
                                             radius: newRadius,
                                             identifier: newId)
            locationManager.stopMonitoring(for: region)
            locationManager.startMonitoring(for: newRegion)
        }
        self.performSegue(withIdentifier: "unwindSegue", sender: self)
    }
    
    @IBAction func deleteRegion() {

        for region in locationManager.monitoredRegions.filter({ region in
            region.identifier == identifier
        }) {
            locationManager.stopMonitoring(for: region)
        }
        self.performSegue(withIdentifier: "unwindSegue", sender: self)
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
