//
//  Waste.swift
//  SwiftCarbonFootprintApp
//
//  Created by  Ben Lee on 5/23/20.
//  Copyright © 2020  Ben Lee. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Waste: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var wasteScrollview: UIScrollView!
    @IBOutlet weak var wasteStackView: UIStackView!

    @IBOutlet weak var householdOccupantsTextField: UITextField!

    @IBOutlet weak var aluminumSwitch: UISwitch!
    @IBOutlet weak var plasticSwitch: UISwitch!
    @IBOutlet weak var glassSwitch: UISwitch!
    @IBOutlet weak var newspaperSwitch: UISwitch!
    @IBOutlet weak var magazinesSwitch: UISwitch!

    var houseHoldOccupants = 1.0
    var subviewHeightAdded = false

    @IBOutlet weak var outputTextView: UILabel!
    @IBOutlet weak var potentialCarbonSavingsLabel: UILabel!

    var ref: DatabaseReference!
    let user = Auth.auth().currentUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        householdOccupantsTextField.addDoneButtonOnKeyboard()
        wasteScrollview.delegate = self
        subviewHeightAdded = false
    }

    override func viewDidLayoutSubviews() {
        wasteScrollview.delegate = self
        wasteScrollview.addSubview(wasteStackView)

        if !subviewHeightAdded {
            self.subviewHeightAdded = true
            // The scrollview needs to know the content size for it to work correctly
            self.wasteScrollview.contentSize = CGSize(width: self.wasteStackView.frame.size.width, height: self.wasteStackView.frame.size.height + 300)
        }
    }

    @IBAction func getHouseholdOccupants(_ sender: UITextField) {
        houseHoldOccupants = Double(householdOccupantsTextField.text!) ?? 1.0
        switchValueChanged(aluminumSwitch)
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if householdOccupantsTextField.text == "" {
            return
        }
        // Avg pounds of carbon dioxide per household before recycling: 692
        var outputVal = 692.0 * houseHoldOccupants
        
        let ALUMINUM_CO2_PER_PERSON = 83.98
        let PLASTIC_CO2_PER_PERSON = 35.56
        let GLASS_CO2_PER_PERSON = 25.39
        let NEWSPAPER_CO2_PER_PERSON = 113.14
        let MAGAZINE_CO2_PER_PERSON = 27.46

        var carbonSavings = 0.0
        var all_checked = true

        if aluminumSwitch.isOn {
            outputVal -= (houseHoldOccupants * ALUMINUM_CO2_PER_PERSON)
        } else {
            carbonSavings += (houseHoldOccupants * ALUMINUM_CO2_PER_PERSON)
            all_checked = false
        }
        
        if plasticSwitch.isOn {
            outputVal -= (houseHoldOccupants * PLASTIC_CO2_PER_PERSON)
        } else {
            carbonSavings += (houseHoldOccupants * PLASTIC_CO2_PER_PERSON)
            all_checked = false
        }

        if glassSwitch.isOn {
            outputVal -= (houseHoldOccupants * GLASS_CO2_PER_PERSON)
        } else {
            carbonSavings += (houseHoldOccupants * GLASS_CO2_PER_PERSON)
            all_checked = false
        }

        if newspaperSwitch.isOn {
            outputVal -= (houseHoldOccupants * NEWSPAPER_CO2_PER_PERSON)
        } else {
            carbonSavings += (houseHoldOccupants * NEWSPAPER_CO2_PER_PERSON)
            all_checked = false
        }

        if magazinesSwitch.isOn {
            outputVal -= (houseHoldOccupants * MAGAZINE_CO2_PER_PERSON)
        } else {
            carbonSavings += (houseHoldOccupants * MAGAZINE_CO2_PER_PERSON)
            all_checked = false
        }

        // Set floating point precision to two decimal places.
        outputVal = round(100 * outputVal) / 100

        // Creating bolded text for output.
        let boldTextAttr = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
        let beginOutputText = NSMutableAttributedString(string: "Your waste carbon footprint contribution: \r\n")
        beginOutputText.append(NSMutableAttributedString(string: Helper.formatNumber(number:outputVal),
                                                         attributes:boldTextAttr))
        beginOutputText.append(NSMutableAttributedString(string:" lb CO2"))

        outputTextView.attributedText = beginOutputText
        outputTextView.isHidden = false
        self.updateOutput(total: outputVal)

        if !all_checked {
            // Create bolded text for waste reduction suggestions.
            let newText = NSMutableAttributedString(string: "You could save\r\n")
            newText.append(NSMutableAttributedString(string: String(Helper.formatNumber(number:carbonSavings)) + "lb CO2",
                                                     attributes:boldTextAttr))
            newText.append(NSMutableAttributedString(string: " annually\r\nby recycling all of the items above"))

            potentialCarbonSavingsLabel.attributedText = newText
            potentialCarbonSavingsLabel.isHidden = false
        } else {
            potentialCarbonSavingsLabel.text = ""
            potentialCarbonSavingsLabel.isHidden = true
        }
    }

    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }

    func updateOutput(total: Double) {
        // get the date time String from the date object
        let date = Date()
        let formattedDate = date.getFormattedDate(format: "yyyy-MM-dd") // Set output format
        let timestamp = NSDate().timeIntervalSince1970

        self.ref.child("0/Users/\(user.uid)/Waste/\(formattedDate)").setValue(["emissions": total.string, "timestamp": timestamp])
    }
}
