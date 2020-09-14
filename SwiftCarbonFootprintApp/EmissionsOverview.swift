//
//  UserSettings.swift
//  SwiftCarbonFootprintApp
//
//  Created by  Ben Lee on 5/27/20.
//  Copyright © 2020  Ben Lee. All rights reserved.
//

import AuthenticationServices
import Foundation
import UIKit
import Firebase
import Security
import FirebaseUI
import Charts

class EmissionsOverview: UIViewController, FUIAuthDelegate, ChartViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var emissionsScrollView: UIScrollView!
    @IBOutlet weak var outerEmissionsStackView: UIStackView!

    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!

    var ref: DatabaseReference!
    let user = Auth.auth().currentUser!
    
    let labels = ["Home Energy", "Waste", "Household Vehicles"]
    var emissionsArray = [Double]()

    var subviewHeightAdded = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subviewHeightAdded = false
        emissionsScrollView.delegate = self

        if user == nil {
            // User is not signed in.
            // Transition to sign in view.
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "Welcome")
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }

        ref = Database.database().reference()
        self.setUpPieChart()

        // Do any additional setup after loading the view.
        usernameLabel.text = "Welcome, " + String(user.displayName ?? "user")
        
        self.configureRefreshControl()
    }
    
    func configureRefreshControl () {
        emissionsScrollView.refreshControl = UIRefreshControl()
        emissionsScrollView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        emissionsScrollView.refreshControl?.addTarget(self, action:
                                                      #selector(handleRefreshControl),
                                                      for: .valueChanged)
    }
        
    @objc func handleRefreshControl() {
        // Update pie chart on refresh.
        self.setUpPieChart()

        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.emissionsScrollView.refreshControl?.endRefreshing()
        }
    }

    override func viewDidLayoutSubviews() {

        emissionsScrollView.delegate = self
        emissionsScrollView.addSubview(outerEmissionsStackView)

        if (!subviewHeightAdded) {
            self.subviewHeightAdded = true
            // The scrollview needs to know the content size for it to work correctly
            self.emissionsScrollView.contentSize = CGSize(width: self.outerEmissionsStackView.frame.size.width, height: self.outerEmissionsStackView.frame.size.height + 300)
        }
    }

    @IBAction func signUserOut(_ sender: UIButton) {
        try? Auth.auth().signOut()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Welcome")
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }

    func customizeChart(dataPoints: [String], values: [Double]) {
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
          let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
          dataEntries.append(dataEntry)
        }
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        // 4. Assign it to the chart’s data
        pieChartView.data = pieChartData

        pieChartView.animate(xAxisDuration: 1.5, easingOption: ChartEasingOption.easeOutCirc)
    }

    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        let colors: [UIColor] = [UIColor.systemTeal, UIColor.systemRed, UIColor.systemIndigo]
        return colors
    }

    func setUpPieChart() {
        
        let myGroup = DispatchGroup()

        myGroup.enter()
        self.ref.child("0/Users/\(user.uid)/HomeEnergy").queryOrdered(byChild: "timestamp").queryLimited(toLast:1).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            // Get user value
            let snapshotDictionary = snapshot.value as? [String: Any]
            let emissionsVal = snapshotDictionary?["emissions"] as? String ?? ""
            let emissionsDouble = Double(emissionsVal) ?? 0.0

            self.emissionsArray.append(emissionsDouble)
            myGroup.leave()
          }) { (error) in
            print("Failed with error")
            myGroup.leave()
        }

        myGroup.enter()
        self.ref.child("0/Users/\(user.uid)/Waste").queryOrdered(byChild: "timestamp").queryLimited(toLast:1).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            // Get user value
            let snapshotDictionary = snapshot.value as? [String: Any]
            let emissionsVal = snapshotDictionary?["emissions"] as? String ?? ""
            let emissionsDouble = Double(emissionsVal) ?? 0.0

            self.emissionsArray.append(emissionsDouble)
            myGroup.leave()
          }) { (error) in
            print("Failed with error")
            myGroup.leave()
        }

        myGroup.enter()
        self.ref.child("0/Users/\(user.uid)/HouseholdVehicles").queryOrdered(byChild: "timestamp").queryLimited(toLast:1).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            // Get user value
            let snapshotDictionary = snapshot.value as? [String: Any]
            let emissionsVal = snapshotDictionary?["emissions"] as? String ?? ""
            let emissionsDouble = Double(emissionsVal) ?? 0.0

            self.emissionsArray.append(emissionsDouble)
            myGroup.leave()
          }) { (error) in
            print("Failed with error")
            myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
            self.customizeChart(dataPoints: self.labels, values: self.emissionsArray)
        }
    }
}
