//
//  HouseholdVehicles.swift
//  SwiftCarbonFootprintApp
//
//  Created by  Ben Lee on 5/24/20.
//  Copyright © 2020  Ben Lee. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Vehicles: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var householdVehiclesScrollView: UIScrollView!
    @IBOutlet weak var householdVehiclesOuterStackview: UIStackView!

    @IBOutlet weak var numberOfVehiclesLabel: UILabel!
    @IBOutlet weak var numberOfVehiclesPickerView: UIPickerView!

    @IBOutlet weak var maintenanceStackview: UIStackView!
    @IBOutlet weak var maintenancePerformed: UISwitch!
    @IBOutlet weak var usaAveragesLabel: UILabel!
    
    @IBOutlet weak var weeklyMiles1: UITextField!
    @IBOutlet weak var mpg1: UITextField!
    @IBOutlet weak var weeklyMiles2: UITextField!
    @IBOutlet weak var mpg2: UITextField!
    @IBOutlet weak var weeklyMiles3: UITextField!
    @IBOutlet weak var mpg3: UITextField!
    @IBOutlet weak var weeklyMiles4: UITextField!
    @IBOutlet weak var mpg4: UITextField!
    @IBOutlet weak var weeklyMiles5: UITextField!
    @IBOutlet weak var mpg5: UITextField!
    
    @IBOutlet weak var emissionsLabel: UILabel!
    @IBOutlet weak var emissionsOutput: UILabel!

    var pickerData: [Int] = [Int]()
    var subviewHeightAdded = false
    
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()

        // Connect modified keyboard to all textboxes.
        weeklyMiles1.addDoneButtonOnKeyboard()
        mpg1.addDoneButtonOnKeyboard()
        weeklyMiles2.addDoneButtonOnKeyboard()
        mpg2.addDoneButtonOnKeyboard()
        weeklyMiles3.addDoneButtonOnKeyboard()
        mpg3.addDoneButtonOnKeyboard()
        weeklyMiles4.addDoneButtonOnKeyboard()
        mpg4.addDoneButtonOnKeyboard()
        weeklyMiles5.addDoneButtonOnKeyboard()
        mpg5.addDoneButtonOnKeyboard()
        
        numberOfVehiclesLabel.adjustsFontSizeToFitWidth = true
        numberOfVehiclesLabel.minimumScaleFactor = 0.5

        emissionsOutput.adjustsFontSizeToFitWidth = true
        emissionsOutput.minimumScaleFactor = 0.5
        
        usaAveragesLabel.adjustsFontSizeToFitWidth = true
        usaAveragesLabel.minimumScaleFactor = 0.5

        // Connect data:
       self.numberOfVehiclesPickerView.delegate = self
       self.numberOfVehiclesPickerView.dataSource = self
        
        pickerData = [0, 1, 2, 3, 4, 5]
        householdVehiclesScrollView.delegate = self
        subviewHeightAdded = false
    }

    override func viewDidLayoutSubviews() {
        householdVehiclesScrollView.delegate = self
        householdVehiclesScrollView.addSubview(householdVehiclesOuterStackview)
            
        if !subviewHeightAdded {
            self.subviewHeightAdded = true
            // The scrollview needs to know the content size for it to work correctly
            self.householdVehiclesScrollView.contentSize = CGSize(width: self.householdVehiclesOuterStackview.frame.size.width,
                                                                  height: self.householdVehiclesOuterStackview.frame.size.height + 800)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        if row == 0 {
            maintenanceStackview.isHidden = true
            usaAveragesLabel.isHidden = true
            emissionsOutput.text = "0 lb CO2"
        }

        let start_index = row + 1
        for n in 1...5 {
            if n < start_index {
                self.view.viewWithTag(n)?.isHidden = false
                maintenanceStackview.isHidden = false
                usaAveragesLabel.isHidden = false
            } else {
                self.view.viewWithTag(n)?.isHidden = true
            }
        }
    }

    // Recalculate emissions if maintenance switch value changes.
    @IBAction func maintenanceStatusDidChange(_ sender: UISwitch) {
        calculateOutput(weeklyMiles1)
    }

    @IBAction func calculateOutput(_ sender: UITextField) {
        var output = 0.0
        let EF_passenger_vehicle = 19.6
        let nonCO2_vehicle_emissions_ratio = 1.01
        let vehicle_efficiency_improvements = 0.04

        var vehicleOneEmissions = 0.0
        var vehicleTwoEmissions = 0.0
        var vehicleThreeEmissions = 0.0
        var vehicleFourEmissions = 0.0
        var vehicleFiveEmissions = 0.0
        let maintenancePerformed = self.maintenancePerformed.isOn

        if !(self.view.viewWithTag(1)?.isHidden ?? true) {
            let weeklyMiles = Double(self.weeklyMiles1.text!)
            let mpg = Double(self.mpg1.text!)
            vehicleOneEmissions = ((weeklyMiles ?? 0) * 52) / (mpg ?? 0)
            vehicleOneEmissions *= EF_passenger_vehicle * nonCO2_vehicle_emissions_ratio
            vehicleOneEmissions = maintenancePerformed ? vehicleOneEmissions : vehicleOneEmissions * 1.04
        }

        if !(self.view.viewWithTag(2)?.isHidden ?? true) {
            let weeklyMiles = Double(self.weeklyMiles2.text!)
            let mpg = Double(self.mpg2.text!)
            vehicleTwoEmissions = ((weeklyMiles ?? 0) * 52) / (mpg ?? 0)
            vehicleTwoEmissions *= EF_passenger_vehicle * nonCO2_vehicle_emissions_ratio
            vehicleTwoEmissions = maintenancePerformed ? vehicleTwoEmissions : vehicleTwoEmissions * 1.04
        }

        if !(self.view.viewWithTag(3)?.isHidden ?? true) {
            let weeklyMiles = Double(self.weeklyMiles3.text!)
            let mpg = Double(self.mpg3.text!)
            vehicleThreeEmissions = ((weeklyMiles ?? 0) * 52) / (mpg ?? 0)
            vehicleThreeEmissions *= EF_passenger_vehicle * nonCO2_vehicle_emissions_ratio
            vehicleThreeEmissions = maintenancePerformed ? vehicleThreeEmissions : vehicleThreeEmissions * 1.04
        }

        if !(self.view.viewWithTag(4)?.isHidden ?? true) {
            let weeklyMiles = Double(self.weeklyMiles4.text!)
            let mpg = Double(self.mpg4.text!)
            vehicleFourEmissions = ((weeklyMiles ?? 0) * 52) / (mpg ?? 0)
            vehicleFourEmissions *= EF_passenger_vehicle * nonCO2_vehicle_emissions_ratio
            vehicleFourEmissions = maintenancePerformed ? vehicleFourEmissions : vehicleFourEmissions * 1.04
        }

        if !(self.view.viewWithTag(5)?.isHidden ?? true) {
            let weeklyMiles = Double(self.weeklyMiles5.text!)
            let mpg = Double(self.mpg5.text!)
            vehicleFiveEmissions = ((weeklyMiles ?? 0) * 52) / (mpg ?? 0)
            vehicleFiveEmissions *= EF_passenger_vehicle * nonCO2_vehicle_emissions_ratio
            vehicleFiveEmissions = maintenancePerformed ? vehicleFiveEmissions : vehicleFiveEmissions * 1.04
        }

        output = vehicleOneEmissions +
                 vehicleTwoEmissions +
                 vehicleThreeEmissions +
                 vehicleFourEmissions +
                 vehicleFiveEmissions
        emissionsOutput.text = Helper.formatNumber(number: output) + "lb CO2"
        self.updateOutput(total: output)
    }

    func updateOutput(total: Double) {
        // get the date time String from the date object
        let date = Date()
        let formattedDate = date.getFormattedDate(format: "yyyy-MM-dd") // Set output format
        let timestamp = NSDate().timeIntervalSince1970

        self.ref.child("0/Users/\(user.uid)/HouseholdVehicles/\(formattedDate)").setValue(["emissions": total.string, "timestamp": timestamp])
    }
}
