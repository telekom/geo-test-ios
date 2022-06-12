//
//  RegionsDetailControllerViewController.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 13.06.22.
//

import UIKit
import MapKit

class RegionsDetailControllerViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    var region: CLRegion? {
        didSet {
            self.updateMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateMap()
    }
    
    func updateMap() {
        guard mapView != nil else {
            return
        }
        
        if let region = region as? CLCircularRegion {
            let overlay = MKCircle(center: region.center, radius: region.radius)
            mapView.addOverlay(overlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.blue.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
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
