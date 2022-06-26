//: A MapKit based Playground

import MapKit
import PlaygroundSupport


func boundingCoordinates(_ input: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
    
    var minLat: CLLocationDegrees?
    var maxLat: CLLocationDegrees?
    var minLon: CLLocationDegrees?
    var maxLon: CLLocationDegrees?
    
    for coordinate in input {
        let latitude = coordinate.latitude
        if let minValue = minLat {
            if latitude < minValue {
                minLat = latitude
            }
        } else {
            minLat = latitude
        }
        
        if let maxValue = maxLat {
            if latitude > maxValue {
                maxLat = latitude
            }
        } else {
            maxLat = latitude
        }
        
        let longitude = coordinate.longitude
        if let minValue = minLon {
            if longitude < minValue {
                minLon = longitude
            }
        } else {
            minLon = longitude
        }
        if let maxValue = maxLon {
            if longitude > maxValue {
                maxLon = longitude
            }
        } else {
            maxLon = longitude
        }
    }
    var result = MKCoordinateRegion()
    
    guard let minLat = minLat,
            let maxLat = maxLat,
            let minLon = minLon,
            let maxLon = maxLon else {
        return result
    }

    let latitudeSpan = maxLat - minLat
    let longitudeSpan = maxLon - minLon
    let latMid = latitudeSpan/2 + minLat
    let lonMid = longitudeSpan/2 + minLon
    result.center = CLLocationCoordinate2DMake(latMid, lonMid)
    result.span.longitudeDelta = latitudeSpan
    result.span.longitudeDelta = longitudeSpan
    return result
}

let appleParkWayCoordinates = CLLocationCoordinate2DMake(37.334922, -122.009033)

let kanneCoordinates = CLLocationCoordinate2DMake(37.271082, -121.967619)

let goldenGateCoordinates = CLLocationCoordinate2DMake(37.819724, -122.478557)

let coordinates = [appleParkWayCoordinates, kanneCoordinates, goldenGateCoordinates]

// Now let's create a MKMapView
let mapView = MKMapView(frame: CGRect(x:0, y:0, width:800, height:800))

// Define a region for our map view
var mapRegion = MKCoordinateRegion()

let mapRegionSpan = 0.02
mapRegion.center = appleParkWayCoordinates
mapRegion.span.latitudeDelta = mapRegionSpan
mapRegion.span.longitudeDelta = mapRegionSpan

 mapRegion = boundingCoordinates(coordinates)
mapView.setRegion(mapRegion, animated: true)

// Create a map annotation
let annotationKanne = MKPointAnnotation()
annotationKanne.coordinate = kanneCoordinates
annotationKanne.title = "Kanne Home"
annotationKanne.subtitle = ""

mapView.addAnnotation(annotationKanne)

let annotationGG = MKPointAnnotation()
annotationGG.coordinate = goldenGateCoordinates
annotationGG.title = "Golden Gate Bridge"
mapView.addAnnotation(annotationGG)

let annotation = MKPointAnnotation()
annotation.coordinate = appleParkWayCoordinates
annotation.title = "Apple Inc."
annotation.subtitle = "One Apple Park Way, Cupertino, California."

mapView.addAnnotation(annotation)

// Add the created mapView to our Playground Live View
PlaygroundPage.current.liveView = mapView
