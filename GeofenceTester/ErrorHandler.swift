//
//  ErrorHandler.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 14.11.22.
//

import Foundation
import AppCenterAnalytics
import os.log

struct ErrorHandler {
    internal var logger = os.Logger()

    public func handleError (_ error: Error) {
        handleError(error.localizedDescription)
    }
    
    public func handleError (_ error: String) {
        Analytics.trackEvent(error, withProperties: [:], flags: .critical)
        logger.error("\(error)")
    }
}
