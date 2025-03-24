//
//  StormDetailInterfaceController.swift
//  Hurricane
//
//  Created by Virendra Sehrawat on 19/07/16.
//  Copyright © 2016 PNSDigital. All rights reserved.
//

import WatchKit
import Foundation

class StormDetailInterfaceController: WKInterfaceController {

    @IBOutlet weak var svcLabel: WKInterfaceLabel!

    @IBOutlet weak var speedLabel: WKInterfaceLabel!
    @IBOutlet weak var mbPressure: WKInterfaceLabel!
    @IBOutlet weak var inchPressure: WKInterfaceLabel!

    @IBOutlet weak var Heading: WKInterfaceLabel!
    @IBOutlet weak var longitude: WKInterfaceLabel!
    @IBOutlet weak var latitude: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let context = context as? NSDictionary {
            if let name = context.value(forKey: "name") as? String {
                self.svcLabel.setText(name)
            }

            if let dict = context.value(forKey: "summary") as? NSDictionary {
                if let wind_mph = dict.value(forKey: "wind_mph") {
                    self.speedLabel.setText("\(wind_mph) mph")
                }

                if let pressure_mb =  dict.value(forKey: "pressure_mb") as? String {
                    self.mbPressure.setText("\(pressure_mb) mb")
                } else {// HAPP-536
                    if let pressure_mb = dict.value(forKey: "pressure_mb") {
                        self.mbPressure.setText("\(String(describing: pressure_mb)) mb")
                    } else {
                        self.mbPressure.setText("")
                    }
                }

                if let inch_pressure = dict.value(forKey: "pressure_in") as? String {
                    self.inchPressure.setText("\(inch_pressure) in")
                } else {// HAPP-536
                    if let inch_pressure = dict.value(forKey: "pressure_in") {
                        self.inchPressure.setText("\(String(describing: inch_pressure)) in")
                    } else {
                        self.inchPressure.setText("")
                    }
                }

                if let movement = dict.value(forKey: "movement") as? String {
                    self.Heading.setText(movement)
                }

                if let longitude =  dict.value(forKey: "lon") as? String {
                    self.longitude.setText(longitude)
                }

                if let latitude = dict.value(forKey: "lat") as? String {
                    self.latitude.setText(latitude)// HAPP-536
                }

            }

        }
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
