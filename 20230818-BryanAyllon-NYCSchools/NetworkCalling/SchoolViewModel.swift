//
//  SchoolViewModel.swift
//  20230818-BryanAyllon-NYCSchools
//
//  Created by Bryan Ayllon on 8/18/23.
//

import Foundation

/// View model responsible for managing school data and interactions.
class SchoolViewModel {
    private var schools: [School] = []          // Stores the fetched schools data.
    private var schoolsSAT: [SATScores] = []    // Stores the fetched SAT scores data.
    
    /// Fetches school data from the API.
    func fetchData(completion: @escaping (Error?) -> Void) {
        let networkManager = NetworkManager()
        networkManager.fetchData(urlString: APIURLConstants.fetchSchools) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    // Decode and sort the fetched schools data.
                    let decodedSchools = try JSONDecoder().decode([School].self, from: data)
                    self?.schools = decodedSchools.sorted { $0.school_name ?? "" < $1.school_name ?? "" }
                    
                    // Create a lookup for efficient assignment of SAT scores.
                    let schoolsSATLookup = self?.schoolsSAT.reduce(into: [String: SATScores]()) { result, satScore in
                        if let schoolName = satScore.school_name {
                            result[schoolName] = satScore
                        }
                    }
                    
                    // Assign SAT scores to corresponding schools.
                    for (index, var school) in decodedSchools.enumerated() {
                        if let matchingSATScore = schoolsSATLookup?[school.school_name ?? ""] {
                            school.satScores = matchingSATScore
                            self?.schools[index] = school
                        }
                    }
                    
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /// Updates the schools data with the provided array.
    func updateSchools(_ schools: [School]) {
        self.schools = schools
    }
    
    /// Returns the number of fetched schools.
    func numberOfSchools() -> Int {
        return schools.count
    }
    
    /// Returns the school at the specified index.
    func school(at index: Int) -> School? {
        guard index >= 0, index < schools.count else {
            return nil
        }
        return schools[index]
    }
    ///Fetch SAT Scores
    func fetchSATScores(completion: @escaping (Error?) -> Void) {
        let networkManager = NetworkManager()
        networkManager.fetchData(urlString: APIURLConstants.fetchSATScores) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decodedSchools = try JSONDecoder().decode([SATScores].self, from: data)
                    self?.schoolsSAT = decodedSchools.sorted { $0.school_name ?? "" < $1.school_name ?? "" }
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    func numberOfSchoolsWithSat() -> Int {
        return schoolsSAT.count
    }
    
    func schoolSAT(at index: Int) -> SATScores? {
        guard index >= 0, index < schoolsSAT.count else {
            return nil
        }
        return schoolsSAT[index]
    }
    
    
    //Search Filtering
    private var filteredSchools: [School] = []
    
    var isFiltering: Bool {
        return !filteredSchools.isEmpty
    }
    
    func filterSchoolsBySearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredSchools = []
        } else {
            filteredSchools = schools.filter { school in
                return school.school_name?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    func numberOfFilteredSchools() -> Int {
        return filteredSchools.count
    }
    
    func filteredSchool(at index: Int) -> School? {
        guard index >= 0, index < filteredSchools.count else {
            return nil
        }
        return filteredSchools[index]
    }
}
