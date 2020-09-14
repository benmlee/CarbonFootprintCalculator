//
//  ViewController.swift
//  SwiftCarbonFootprintApp
//
//  Created by  Ben Lee on 5/22/20.
//  Copyright © 2020  Ben Lee. All rights reserved.
//

import UIKit
import Firebase

class HomeEnergy: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleStackView: UIStackView!

    @IBOutlet weak var homeEnergyScrollView: UIScrollView!
    @IBOutlet weak var homeEnergyOuterStackView: UIStackView!

    @IBOutlet weak var homeEnergyInputType: UISegmentedControl!

    @IBOutlet weak var naturalGasText: UITextField!

    @IBOutlet weak var electricityText: UITextField!
    @IBOutlet weak var greenEnergySwitch: UISwitch!
    @IBOutlet weak var greenEnergyStackView: UIStackView!
    @IBOutlet weak var greenEnergyPercentageInput: UITextField!
    @IBOutlet weak var electricityValuesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var zipCodeTextField: UITextField!

    @IBOutlet weak var enterInputTypeLabel: UILabel!

    @IBOutlet weak var fuelOilText: UITextField!

    @IBOutlet weak var propaneText: UITextField!

    @IBOutlet weak var totalOutput: UILabel!

    var subviewHeightAdded = false

    // Track values for types of emissions.
    var naturalGasVal = 0.0
    var electricityVal = 0.0
    var fuelOilVal = 0.0
    var propaneVal = 0.0
    var total = 0.0

    var ref: DatabaseReference!
    let user = Auth.auth().currentUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = Color.lightBackground.value
        self.titleLabel.textColor = Color.lightText.value
        self.titleStackView.addBackground(color: Color.darkBackground.value)

        ref = Database.database().reference()

        // Add done button to keyboard.
        naturalGasText.addDoneButtonOnKeyboard()
        electricityText.addDoneButtonOnKeyboard()
        fuelOilText.addDoneButtonOnKeyboard()
        propaneText.addDoneButtonOnKeyboard()
        electricityText.addDoneButtonOnKeyboard()
        greenEnergyPercentageInput.addDoneButtonOnKeyboard()
        zipCodeTextField.addDoneButtonOnKeyboard()

        // Dynamically adjust text size to fit on all iPhone models.
        enterInputTypeLabel.adjustsFontSizeToFitWidth = true
        enterInputTypeLabel.minimumScaleFactor = 0.5

        totalOutput.adjustsFontSizeToFitWidth = true
        totalOutput.minimumScaleFactor = 0.5

        self.subviewHeightAdded = false
        homeEnergyScrollView.delegate = self

        self.total = 0.0

    }

    override func viewDidLayoutSubviews() {
        homeEnergyScrollView.delegate = self
        homeEnergyScrollView.addSubview(homeEnergyOuterStackView)

        if !subviewHeightAdded {
            self.subviewHeightAdded = true
            // The scrollview needs to know the content size for it to work correctly
            self.homeEnergyScrollView.contentSize = CGSize(width: self.homeEnergyOuterStackView.frame.size.width,
                                                           height: self.homeEnergyOuterStackView.frame.size.height + 300)
        }
    }

    @IBAction func inputSelectionControl(_ sender: UISegmentedControl) {
        if !naturalGasText.text!.isEmpty {
            naturalGasInput(naturalGasText);
        }
        if !electricityText.text!.isEmpty {
            electricityInput(electricityText);
        }
        if !fuelOilText.text!.isEmpty {
            fuelOilInput(fuelOilText);
        }
        if !propaneText.text!.isEmpty {
            propaneInput(propaneText);
        }
    }

    @IBAction func naturalGasInput(_ sender: UITextField) {
        self.total -= naturalGasVal
        let input = Double(naturalGasText.text!)
        // Natural gas emission factor.
        let EF_NATURAL_GAS = 119.58
        // Price per 1000 cubic ft.
        let NATURAL_GAS_COST = 10.68

        // Check to see if input is in dollars
        if homeEnergyInputType.selectedSegmentIndex == 0 {
            naturalGasVal = ((input ?? 0) / NATURAL_GAS_COST) * EF_NATURAL_GAS * 12
        }
        // Input is in 1000 cubic ft.
        else {
            naturalGasVal = (input ?? 0) * EF_NATURAL_GAS * 12
        }

        self.updateOutput(value: naturalGasVal)
    }

    @IBAction func electricityInput(_ sender: UITextField) {
        self.total -= electricityVal

        let input = Double(electricityText.text!)
        let cost_per_kWh = 0.1188
        var e_factor_value = 0.0 // zipcode dependent
        let inputIndex = electricityValuesSegmentedControl.selectedSegmentIndex

        let zipcode = String(zipCodeTextField.text!)

        if !zipCodeTextField.text!.isEmpty {
            self.ref.child("1").child(zipcode).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                e_factor_value = snapshot.value as? Double ?? 0.0

                if self.greenEnergySwitch.isOn {
                    var input_percentage_greenEnergy = Double(self.greenEnergyPercentageInput.text!)
                    input_percentage_greenEnergy = (input_percentage_greenEnergy ?? 0) / 100

                    if inputIndex == 0 {
                        self.electricityVal = (((input ?? 0) / cost_per_kWh) * e_factor_value * 12)
                        self.electricityVal = self.electricityVal * (1 - (input_percentage_greenEnergy ?? 0))
                    } else {
                        self.electricityVal = (input ?? 0) * 12 * (1 - (input_percentage_greenEnergy ?? 0)) * e_factor_value
                    }
                } else {
                    if inputIndex == 0 {
                        self.electricityVal = ((input ?? 0) / cost_per_kWh) * e_factor_value * 12
                    } else {
                        self.electricityVal = (input ?? 0) * e_factor_value * 12
                    }
                }

                self.updateOutput(value: self.electricityVal)

              }) { (error) in
                print("Failed with error")
            }
        }
    }

    @IBAction func greenEnergySwitchDidChange(_ sender: UISwitch) {
        if greenEnergySwitch.isOn {
            greenEnergyStackView.isHidden = false
        } else {
            greenEnergyStackView.isHidden = true
        }
        if !electricityText.text!.isEmpty {
            electricityInput(electricityText);
        }
    }

    @IBAction func electricityInputDidChange(_ sender: UISegmentedControl) {
        if !electricityText.text!.isEmpty {
            electricityInput(electricityText);
        }
    }

    @IBAction func fuelOilInput(_ sender: UITextField) {
        self.total -= fuelOilVal
        let input = Double(fuelOilText.text!)
        // Fuel Oil cost per gallon.
        let FUEL_OIL_COST = 4.02
        // Fuel Oil Emission factor.
        let EF_FUEL_OIL_GALLON = 22.61

        if homeEnergyInputType.selectedSegmentIndex == 0 {
            fuelOilVal = ((input ?? 0) / FUEL_OIL_COST) * EF_FUEL_OIL_GALLON * 12
        } else {
            fuelOilVal = EF_FUEL_OIL_GALLON * (input ?? 0) * 12
        }
        self.updateOutput(value: fuelOilVal)
    }

    @IBAction func propaneInput(_ sender: UITextField) {
        self.total -= propaneVal
        let input = Double(propaneText.text!)
        // Propane cost per gallon.
        let PROPANE_COST = 2.47
        // Propane Emission Factor.
        let EF_PROPANE = 12.43

        if homeEnergyInputType.selectedSegmentIndex == 0 {
            propaneVal = ((input ?? 0) / PROPANE_COST) * EF_PROPANE * 12
        } else {
            propaneVal = EF_PROPANE * (input ?? 0) * 12
        }
        self.updateOutput(value: propaneVal)
    }

    func updateOutput(value: Double) {
        totalOutput.text = "Total emissions: \n" + Helper.formatNumber(number: (value + total)) + " lb CO2"
        // Update total emissions stored.
        self.total += value

        let emissionsOutput = total.string

        // get the date time String from the date object
        let date = Date()
        let formattedDate = date.getFormattedDate(format: "yyyy-MM-dd") // Set output format
        let timestamp = NSDate().timeIntervalSince1970

        self.ref.child("0/Users/\(user.uid)/HomeEnergy/\(formattedDate)").setValue(["emissions": emissionsOutput, "timestamp": timestamp ])
    }
} // CLASS
