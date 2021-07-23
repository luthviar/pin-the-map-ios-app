//
//  FinishAddPinDataViewController.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 23/07/21.
//

import UIKit
import MapKit

class FinishAddPinDataViewController: UIViewController {
    
    // MARK: Outlets and properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var finishAddButton: UIButton!
    
    var studentInformation: StudentInformation?
    
    // MARK: UI VC
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let studentInformation = studentInformation {
            let studentLocation = Location(
                objectId: studentInformation.objectId ?? "",
                uniqueKey: studentInformation.uniqueKey,
                firstName: studentInformation.firstName,
                lastName: studentInformation.lastName,
                mapString: studentInformation.mapString,
                mediaURL: studentInformation.mediaURL,
                latitude: studentInformation.latitude,
                longitude: studentInformation.longitude,
                createdAt: studentInformation.createdAt ?? "",
                updatedAt: studentInformation.updatedAt ?? ""
            )
            showLocations(location: studentLocation)
        }
    }
    
    // MARK: Add or Update location
    
    @IBAction func finishAddLocation(_ sender: UIButton) {
        self.setLoading(true)
        if let studentLocation = studentInformation {
            if AppClient.Auth.objectId == "" {
                AppClient.addStudentLocation(information: studentLocation) { (success, error) in
                    self.setLoading(success)
                    DispatchQueue.main.async {
                        success == true ? self.dismiss(animated: true, completion: nil) : self.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                    }
                }
            } else {
                let alertVC = UIAlertController(title: "", message: "This student has already posted a location. Would you like to overwrite this location?", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action: UIAlertAction) in
                    AppClient.updateStudentLocation(information: studentLocation) { (success, error) in
                        self.setLoading(success)
                        DispatchQueue.main.async {
                            success == true ? self.dismiss(animated: true, completion: nil) : self.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                        }
                    }
                }))
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
                    DispatchQueue.main.async {
                        self.setLoading(false)
                        alertVC.dismiss(animated: true, completion: nil)
                    }
                }))
                self.present(alertVC, animated: true)
            }
        }
    }
    
    // MARK: New location in map
    
    private func showLocations(location: Location) {
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = extractCoordinate(location: location) {
            let annotation = MKPointAnnotation()
            annotation.title = location.locationLabel
            annotation.subtitle = location.mediaURL ?? ""
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    private func extractCoordinate(location: Location) -> CLLocationCoordinate2D? {
        if let lat = location.latitude, let lon = location.longitude {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return nil
    }
    
    // MARK: Loading state
    
    func setLoading(_ loading: Bool) {
        if loading {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.buttonEnabled(false, button: self.finishAddButton)
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.buttonEnabled(true, button: self.finishAddButton)
            }
        }
        DispatchQueue.main.async {
            self.finishAddButton.isEnabled = !loading
        }
    }
    
}
