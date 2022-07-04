//: A MapKit based Playground

import Foundation

let converter = UnitConverterLinear()

let meters = Measurement(value: 10, unit: UnitLength.meters)

let feet = meters.converted(to: .feet)

feet.formatted()

