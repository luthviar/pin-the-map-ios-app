//
//  AddLocationViewController.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 23/07/21.
//

import UIKit
import MapKit

class AddPinDataViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Initiate outlets and properties
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var objectId: String?
    var locationTextFieldIsEmpty = true
    var websiteTextFieldIsEmpty = true
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        websiteTextField.delegate = self
        buttonEnabled(false, button: findLocationButton)
    }
    
    // MARK: Cancel out of adding location
    
    @IBAction func cancelAddLocation(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Find location action
    
    @IBAction func findLocation(sender: UIButton) {
        self.setLoading(true)
        let newLocation = locationTextField.text
        
        guard let url = URL(string: self.websiteTextField.text!), UIApplication.shared.canOpenURL(url) else {
            self.showAlert(message: "Please include 'http://' or 'https://' in your link.", title: "Invalid URL")
            setLoading(false)
            return
        }

        geocodePosition(newLocation: newLocation ?? "")
    }
    
    // MARK: Find geocode position
    
    private func geocodePosition(newLocation: String) {
        CLGeocoder().geocodeAddressString(newLocation) { (newMarker, error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription, title: "Location Not Found")
                self.setLoading(false)
                print("Location not found.")
            } else {
                var location: CLLocation?
                
                if let marker = newMarker, marker.count > 0 {
                    location = marker.first?.location
                }
                
                if let location = location {
                    self.loadNewLocation(location.coordinate)
                } else {
                    self.showAlert(message: "Please try again later.", title: "Error")
                    self.setLoading(false)
                    print("There was an error.")
                }
            }
        }
    }
    
    // MARK: Push to Finish Add Pin Data screen
    
    private func loadNewLocation(_ coordinate: CLLocationCoordinate2D) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "FinishAddPinDataViewController") as! FinishAddPinDataViewController
        controller.studentInformation = buildStudentInfo(coordinate)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Student info to display on Finish Add Pin Data screen
    
    private func buildStudentInfo(_ coordinate: CLLocationCoordinate2D) -> StudentInformation {
        
        var studentInfo = [
            "uniqueKey": AppClient.Auth.key,
            "firstName": AppClient.Auth.firstName,
            "lastName": AppClient.Auth.lastName,
            "mapString": locationTextField.text!,
            "mediaURL": websiteTextField.text!,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            ] as [String: AnyObject]
        
        if let objectId = objectId {
            studentInfo["objectId"] = objectId as AnyObject
            print(objectId)
        }

        return StudentInformation(studentInfo)

    }
    
    // MARK: Loading state
    
    func setLoading(_ loading: Bool) {
        if loading {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.buttonEnabled(false, button: self.findLocationButton)
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.buttonEnabled(true, button: self.findLocationButton)
            }
        }
        DispatchQueue.main.async {
            self.locationTextField.isEnabled = !loading
            self.websiteTextField.isEnabled = !loading
            self.findLocationButton.isEnabled = !loading
        }
    }
    
     // MARK: Enable and Disable Buttons and Text Fields
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == locationTextField {
            let currenText = locationTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                locationTextFieldIsEmpty = true
            } else {
                locationTextFieldIsEmpty = false
            }
        }
        
        if textField == websiteTextField {
            let currenText = websiteTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if !isValidURL(text: updatedText)  {
                websiteTextFieldIsEmpty = true
            } else {
                websiteTextFieldIsEmpty = false
            }
        }
        
        if !locationTextFieldIsEmpty && !websiteTextFieldIsEmpty {
            buttonEnabled(true, button: findLocationButton)
        } else {
            buttonEnabled(false, button: findLocationButton)
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        buttonEnabled(false, button: findLocationButton)
        if textField == locationTextField {
            locationTextFieldIsEmpty = true
        }
        if textField == websiteTextField {
            websiteTextFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            
            if !locationTextFieldIsEmpty && !websiteTextFieldIsEmpty {
                findLocation(sender: findLocationButton)
            }
        }
        return true
    }
   
}
