//
//  ViewController.swift
//  20230818-BryanAyllon-NYCSchools
//
//  Created by Bryan Ayllon on 8/18/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = SchoolViewModel()
    @IBOutlet weak var searchBar:UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view delegate and data source.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Fetch school data and SAT scores from the API.
        fetchDataAndSATScores()
    }
    
    // MARK: - Search Bar Delegate Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterSchoolsBySearchText(searchText)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        viewModel.filterSchoolsBySearchText("")
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Private Helper Methods
    
    private func fetchDataAndSATScores() {
        viewModel.fetchData { [weak self] error in
            if let error = error {
                print("Error fetching data: \(error)")
            } else {
                self?.fetchSATScores()
            }
        }
    }
    
    private func fetchSATScores() {
        viewModel.fetchSATScores { [weak self] error in
            if let error = error {
                print("Error fetching SAT scores: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.appendSATScoresToSchools()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func appendSATScoresToSchools() {
        var updatedSchools: [School] = []
        
        for schoolIndex in 0..<viewModel.numberOfSchools() {
            if let originalSchool = viewModel.school(at: schoolIndex),
               let satScore = viewModel.schoolSAT(at: schoolIndex) {
                
                var updatedSchool = originalSchool
                updatedSchool.satScores = satScore
                updatedSchools.append(updatedSchool)
            }
        }
        
        viewModel.updateSchools(updatedSchools)
    }
    ///Instead of Segue do a select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.isFiltering {
            let school = viewModel.filteredSchool(at: indexPath.row)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "SchoolDetailsTableViewController") as? SchoolDetailsTableViewController
            vc!.school = school
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            let school = viewModel.school(at: indexPath.row)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "SchoolDetailsTableViewController") as? SchoolDetailsTableViewController
            vc!.school = school
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isFiltering {
            return viewModel.numberOfFilteredSchools()
        } else {
            return viewModel.numberOfSchools()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath)
        
        if viewModel.isFiltering {
            if let school = viewModel.filteredSchool(at: indexPath.row) {
                cell.textLabel?.text = school.school_name
                cell.detailTextLabel?.text = "\(school.primary_address_line_1 ?? ""), \(school.city ?? ""), \(school.state_code ?? "") \(school.zip ?? "")"
            }
        } else {
            if let school = viewModel.school(at: indexPath.row) {
                cell.textLabel?.text = school.school_name
                cell.detailTextLabel?.text = "\(school.primary_address_line_1 ?? ""), \(school.city ?? ""), \(school.state_code ?? "") \(school.zip ?? "")"
            }
        }
        
        return cell
    }
}
