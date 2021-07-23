//
//  ListTableViewController.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 23/07/21.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // MARK: Initiate outlets and Properties
    
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var students = [StudentInformation]()
    var myIndicator: UIActivityIndicatorView!
    let cellReusableId: String = "StudentTableViewCell"
    
    // MARK: UI VC

    override func viewDidLoad() {
        myIndicator = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.medium)
        self.view.addSubview(myIndicator)
        myIndicator.bringSubviewToFront(self.view)
        myIndicator.center = self.view.center
        setVisibilityActivityIndicator(isAnimating: true)
        refreshButton.tag = Constants.BarButtonTags.refreshButton.rawValue
        logoutButton.tag = Constants.BarButtonTags.logoutButton.rawValue
        addButton.tag = Constants.BarButtonTags.addPinDataButton.rawValue
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getStudentsList()
    }
    
    // MARK: IBAction
    
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        switch Constants.BarButtonTags(rawValue: sender.tag) {
        case .refreshButton:
            getStudentsList()
        case .logoutButton:
            setVisibilityActivityIndicator(isAnimating: true)
            AppClient.logout {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.setVisibilityActivityIndicator(isAnimating: false)
                }
            }
        case .addPinDataButton:
            presentAddPinDataView(from: self)
        case .none:
            showAlert(message: "Undefined Bar Button Tag", title: "Sorry, there is an Error!")
        }
    }

    // MARK: Table view delegate protocol and data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReusableId, for: indexPath)
        let student = students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL ?? "")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[indexPath.row]
        openLink(student.mediaURL ?? "")
    }
    
    // MARK: Function helper
    
    func setVisibilityActivityIndicator(isAnimating: Bool) {
        myIndicator.isHidden = !isAnimating
        isAnimating == true ? myIndicator.startAnimating() : myIndicator.stopAnimating()
    }
    
    func getStudentsList() {
        setVisibilityActivityIndicator(isAnimating: true)
        AppClient.getStudentLocations() {students, error in
            self.students = students ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.setVisibilityActivityIndicator(isAnimating: false)
            }
        }
    }
}
