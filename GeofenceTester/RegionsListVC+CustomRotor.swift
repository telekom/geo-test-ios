/*
 * telekom / geo-test-ios
 *
 * RegionsListVC+CustomRotor.swift
 * Created by Alexander von Below on 08.07.22.
 * Copyright (c) 2022 Deutsche Telekom AG
 *
 * This program is made available under the terms of the 
 * MIT license which is available at
 * https://opensource.org/licenses/MIT
 *
 * SPDX-License-Identifier: MIT 
 */

import UIKit
import MapKit

extension RegionsListViewController {
    func setupCustomRotor () {
        // https://stackoverflow.com/questions/42170870/create-a-custom-voiceover-rotor-to-navigate-mkannotationviews
        
        let markerRotor = UIAccessibilityCustomRotor(name: NSLocalizedString("Markers",
                                                                             comment: "Rotor Title"))
        { predicate in
            let forward = (predicate.searchDirection == .next)
            
            // which element is currently highlighted
            if (predicate.currentItem.targetElement == nil) {
                self.errorHandler.logger.info("Current Item Target Element is nil")
            }
            let currentAnnotationView = predicate.currentItem.targetElement as? MKAnnotationView
            if (currentAnnotationView == nil) {
                self.errorHandler.logger.error("Target Element is \(predicate.currentItem.targetElement.debugDescription)")
            }
            let currentAnnotation = (currentAnnotationView?.annotation as? MKAnnotation)
            
            // easy reference to all possible annotations
            let allAnnotations = self.mapView.annotations
            
            // we'll start our index either 1 less or 1 more, so we enter at either 0 or last element
            var currentIndex = forward ? -1 : allAnnotations.count
            
            // set our index to currentAnnotation's index if we can find it in allAnnotations
            if let currentAnnotation = currentAnnotation {
                if let index = allAnnotations.firstIndex(where: { (annotation) -> Bool in
                    return (annotation.coordinate.latitude == currentAnnotation.coordinate.latitude) &&
                    (annotation.coordinate.longitude == currentAnnotation.coordinate.longitude)
                }) {
                    currentIndex = index
                }
            }
            
            // now that we have our currentIndex, here's a helper to give us the next element
            // the user is requesting
            let nextIndex = {(index:Int) -> Int in forward ? index + 1 : index - 1}
            
            currentIndex = nextIndex(currentIndex)
            
            while currentIndex >= 0 && currentIndex < allAnnotations.count {
                let requestedAnnotation = allAnnotations[currentIndex]
                
                // i can't stress how important it is to have animated set to false. save yourself the 10 hours i burnt, and just go with it. if you set it to true, the map starts moving to the annotation, but there's no guarantee the annotation has an associated view yet, because it could still be animating. in which case the line below this one will be nil, and you'll have a whole bunch of annotations that can't be navigated to
                self.mapView.setCenter(requestedAnnotation.coordinate, animated: false)
                if let annotationView = self.mapView.view(for: requestedAnnotation) {
                    let title: String = (requestedAnnotation.title ?? "Unknown") ?? "Unknown"
                    self.errorHandler.logger.info("We want to be returning \(title) Index \(currentIndex)")
                    return UIAccessibilityCustomRotorItemResult(targetElement: annotationView, targetRange: nil)
                }
                
                currentIndex = nextIndex(currentIndex)
            }
            self.errorHandler.logger.info("We have nothing")
            return nil
        }
        self.mapView.accessibilityCustomRotors = [markerRotor]
    }
}
