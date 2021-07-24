//
//  MapViewController.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 21/07/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Initiate outlets and properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var locations = [StudentInformation]()
    var annotations = [MKPointAnnotation]()
    let reuseIdPinAnnotation = "pin"
    
    // MARK: UI VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshButton.tag = Constants.BarButtonTags.refreshButton.rawValue
        logoutButton.tag = Constants.BarButtonTags.logoutButton.rawValue
        addButton.tag = Constants.BarButtonTags.addPinDataButton.rawValue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getStudentsPins()
    }
    
    // MARK: IBAction
    
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        switch Constants.BarButtonTags(rawValue: sender.tag) {
        case .refreshButton:
            getStudentsPins()
        case .logoutButton:
            self.activityIndicator.startAnimating()
            AppClient.logout {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                }
            }
        case .addPinDataButton:
            presentAddPinDataView(from: self)
        case .none:
            showAlert(message: "Undefined Button Tag", title: "Sorry, there is an Error!")
        }
    }
    
    // MARK: Add map annotations
    
    func getStudentsPins() {
        activityIndicator.startAnimating()
        AppClient.getStudentLocations() { locations, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription, title: "Get Student's Locations Failed.")
                return
            }
            self.mapView.removeAnnotations(self.annotations)
            self.annotations.removeAll()
            self.locations = locations ?? []
            for dictionary in locations ?? [] {
                let lat = CLLocationDegrees(dictionary.latitude ?? 0.0)
                let long = CLLocationDegrees(dictionary.longitude ?? 0.0)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let first = dictionary.firstName
                let last = dictionary.lastName
                let mediaURL = dictionary.mediaURL
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                self.annotations.append(annotation)
            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.annotations)
                self.mapView.showAnnotations(self.annotations, animated: true)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: Map view delegate protocol and data source
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdPinAnnotation) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdPinAnnotation)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                openLink(toOpen ?? "")
            }
        }
    }
    
}

