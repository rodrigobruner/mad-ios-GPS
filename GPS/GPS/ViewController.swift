//
//  ViewController.swift
//  GPS
//
//  Created by user228347 on 7/12/24.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let locationManager = CLLocationManager()
    
    
    @IBOutlet weak var labelCurrentSpeed: UILabel!
    
    @IBOutlet weak var labelMaxSpeed: UILabel!
    
    @IBOutlet weak var labelAverageSpeed: UILabel!
    
    @IBOutlet weak var labelDistance: UILabel!
    
    @IBOutlet weak var labelMaxAceleration: UILabel!
    
    @IBOutlet weak var buttonStartTrip: UIButton!
    
    @IBOutlet weak var buttonStopTrip: UIButton!
    
    @IBOutlet weak var labelSpeedHasExceeded: UILabel!
    
    @IBOutlet weak var labelInTrip: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var traveling:Bool = false
    
    let speedLimit:Double = 115
    
    let textStopped = "You haven't started the trip."
    
    let textTraveling = "Traveling for"
    
    var lastLocation: CLLocation? = nil
    var traveledDistance: Double = 0
    var startDate:Date? = nil
    
    var maxSpeed : CLLocationSpeed = 0
    var maxAcceleration:Double = 0
    var lastTenSpeed: [CLLocationSpeed] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        resetFields()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        buttonStopTrip.layer.cornerRadius = 10
        buttonStartTrip.layer.cornerRadius = 10
        
    }
    
    func resetFields(){
        

        lastLocation = nil
        traveledDistance = 0
        startDate = nil
        maxSpeed = 0
        maxAcceleration = 0
        lastTenSpeed = []
        
        labelInTrip.text = textStopped
        labelInTrip.backgroundColor = .gray
        labelInTrip.textColor = .white
        
        labelSpeedHasExceeded.text = ""
        labelSpeedHasExceeded.backgroundColor = .gray
        labelSpeedHasExceeded.textColor = .white
        
        labelCurrentSpeed.text = "0 km/h"
        labelMaxSpeed.text = "0 km/h"
        labelAverageSpeed.text = "0 km/h"
        labelDistance.text = "0 km"
        labelMaxAceleration.text = "0 m/s^2"
        
        buttonStopTrip.backgroundColor = .red
        buttonStopTrip.isEnabled = false
        buttonStartTrip.backgroundColor = .systemGreen
    }
    
    
    @IBAction func startTrip(_ sender: Any) {
        if traveling == false {
            traveling = true
            
            locationManager.startUpdatingLocation()
            
            labelInTrip.backgroundColor = .systemGreen
            labelInTrip.text = textTraveling
            
            buttonStartTrip.isEnabled = false
            buttonStopTrip.isEnabled = true
        }
    }
    
    
    @IBAction func stopTrip(_ sender: Any) {
        if(traveling == true) {
            traveling = false
            
            locationManager.stopUpdatingLocation()
            
            buttonStartTrip.isEnabled = true
            buttonStopTrip.isEnabled = false
            
            resetFields()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            render(location)
        }
    }
    
    func render(_ location:CLLocation){
        
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        //        let pin = MKPointAnnotation()
        //        pin.coordinate = coordinate
        //        mapView.addAnnotation(pin)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        //        locationLabel.text = "Lat \(location.coordinate.latitude) Lon:\(location.coordinate.longitude)"
        //        mapView.userTrackingMode = .follow
        
        //Distance
        if lastLocation == nil {
            lastLocation = location
        } else {
            traveledDistance += lastLocation!.distance(from: location)

            labelDistance.text = "\(String(format:"%.02f", (traveledDistance/1000))) km"
            
            let timeInterval = location.timestamp.timeIntervalSince(lastLocation!.timestamp)
            let speedDifference = location.speed - lastLocation!.speed
            let acceleration = speedDifference / timeInterval
            
            if (maxAcceleration < acceleration){
                maxAcceleration = acceleration
            }
            
            labelMaxAceleration.text = "\(String(format:"%.02f", maxAcceleration)) m/s^2"
            
            lastLocation = location
        }
        
        //Time
        if startDate == nil {
            startDate = Date()
        } else {
            let timeInTravel = String(format: "%.0fs", Date().timeIntervalSince(startDate!))
            labelInTrip.text = "\(textTraveling) \(timeInTravel)"
        }
        
        //AVG Speed
        lastTenSpeed.append(location.speed)
        if lastTenSpeed.count >= 10 {
            let total = lastTenSpeed.reduce(0, +)
            let avg = (total/10)*(18/5)
            labelAverageSpeed.text = "\(String(format:"%.02f", avg)) km/h"
            lastTenSpeed.removeFirst()
        }
        
        //Max Speed
        let speed = location.speed
        if(maxSpeed < speed) {
            maxSpeed = speed
        }
        
        let speedInKm = speed*(18/5)
        let maxSpeedInKm = maxSpeed*(18/5)
        
        labelCurrentSpeed.text = "\(String(format:"%.02f", speedInKm)) km/h"
        labelMaxSpeed.text = "\(String(format:"%.02f", maxSpeedInKm)) km/h"
        
        if( speedInKm > speedLimit ) {
            labelSpeedHasExceeded.text = "You exceeded the speed limit."
            labelSpeedHasExceeded.backgroundColor = .systemRed
        } else {
            labelSpeedHasExceeded.text = ""
            labelSpeedHasExceeded.backgroundColor =  .gray
        }
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
