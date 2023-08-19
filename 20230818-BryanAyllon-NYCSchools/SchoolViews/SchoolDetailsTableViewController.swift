//
//  SchoolDetailsTableViewController.swift
//  20230818-BryanAyllon-NYCSchools
//
//  Created by Bryan Ayllon on 8/18/23.
//

import UIKit
import CoreLocation
import MapKit

class SchoolDetailsTableViewController: UITableViewController {
    // Outlets for school information UI elements
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var schoolBio: UITextView!
    @IBOutlet weak var schoolPrimaryAddress: UITextView!
    @IBOutlet weak var schoolPhoneNumber: UITextView!
    @IBOutlet weak var schoolEmailAddress: UITextView!
    @IBOutlet weak var schoolWebsite: UITextView!
    // Outlets for SAT scores UI elements
    @IBOutlet weak var mathScoreLabel: UILabel!
    @IBOutlet weak var readingScoreLabel: UILabel!
    @IBOutlet weak var writingScoreLabel: UILabel!
    
    // Outlets for the school map
    @IBOutlet weak var schoolMap: MKMapView!
    let region_radius = 10000
    var school: School?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load school data and configure map view
        loadData()
        loadMapView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    /// Load and populate school data into UI elements.
    func loadData() {
        // Configure map view zoom range
        schoolMap.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 250,
                                                              maxCenterCoordinateDistance: 800)
        
        guard let school = school else {
            return
        }
        
        // Populate school information
        schoolName.text = school.school_name
        schoolBio.text = school.overview_paragraph
        schoolPrimaryAddress.text = "\(school.primary_address_line_1 ?? ""), \(school.city ?? ""), \(school.state_code ?? "") \(school.zip ?? "")"
        schoolPhoneNumber.text = school.phone_number
        schoolEmailAddress.text = school.school_email
        schoolWebsite.text = school.website
        
        // Populate SAT scores
        if let satScores = school.satScores {
            mathScoreLabel.text = "SAT Math Avg: \(satScores.sat_math_avg_score ?? "N/A")"
            readingScoreLabel.text = "SAT Reading Avg: \(satScores.sat_critical_reading_avg_score ?? "N/A")"
            writingScoreLabel.text = "SAT Writing Avg: \(satScores.sat_writing_avg_score ?? "N/A")"
        } else {
            mathScoreLabel.text = "SAT Math Avg: N/A"
            readingScoreLabel.text = "SAT Reading Avg: N/A"
            writingScoreLabel.text = "SAT Writing Avg: N/A"
        }
    }
    
    /// Center the map on a given location.
    func centreMap(location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: CLLocationDistance(region_radius),
                                        longitudinalMeters: CLLocationDistance(region_radius))
        schoolMap.setRegion(region, animated: true)
    }
    /// Load and configure the map view.
    func loadMapView() {
        guard let school = school else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("\(school.primary_address_line_1 ?? ""), \(school.city ?? ""), \(school.state_code ?? "") \(school.zip ?? "")") {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            let eventCenter = CLLocationCoordinate2D(latitude: lat ?? 40.7580, longitude: lon ?? 73.9855)
            let cameraBoundary = MKCoordinateRegion(center: eventCenter,
                                                    latitudinalMeters: 200, longitudinalMeters: 200)
            
            self.schoolMap.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: cameraBoundary)
            let location = CLLocation(latitude: lat ?? 40.7580, longitude: lon ?? 73.9855)
            self.schoolMap.layer.borderColor = UIColor.gray.cgColor
            self.schoolMap.layer.borderWidth = 0.50
            self.centreMap(location: location)
        }
    }
}
