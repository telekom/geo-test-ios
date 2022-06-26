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
    var regions: Set<CLRegion>? {
        didSet {
           // self.updateMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Monitored Regions"
        
        registerMapAnnotationViews()
        
        updateMap()
    }
    
    let defaultReuseIdentifier = "defaultAnnotationView"
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: defaultReuseIdentifier)
//        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(SanFranciscoAnnotation.self))
    }
    
    func updateMap() {
        guard mapView != nil else {
            return
        }
        
        guard let regions = self.regions else {
            return
        }
        
        var mapAnnotations = [MKAnnotation]()
        
        for region in regions {
            if let region = region as? CLCircularRegion {
//                let overlay = MKCircle(center: region.center, radius: region.radius)
//                mapView.addOverlay(overlay)
                let annotation = MKPointAnnotation()
                annotation.title = region.identifier
                annotation.coordinate = region.center
                mapAnnotations.append(annotation)
            }
        }
        mapView.addAnnotations(mapAnnotations)
        mapView.showAnnotations(mapAnnotations, animated: true)
    }
    
    func coordinate(from coordinate: CLLocationCoordinate2D, latitudeDistance: CLLocationDistance, longitudeDistance: CLLocationDistance) -> CLLocationCoordinate2D {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: latitudeDistance, longitudinalMeters: longitudeDistance)

        let newLatitude = coordinate.latitude + region.span.latitudeDelta
        let newLongitude = coordinate.longitude + region.span.longitudeDelta

        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: defaultReuseIdentifier,
                                                                   for: annotation)
        annotationView.canShowCallout = true
        let rightButton = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = rightButton
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.blue.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
    }
    
    func mapView(_ mapView: MKMapView,
           annotationView view: MKAnnotationView,
                          calloutAccessoryControlTapped control: UIControl){
        let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
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
