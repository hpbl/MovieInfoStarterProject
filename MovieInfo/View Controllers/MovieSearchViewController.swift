//
//  MovieSearchViewController.swift
//  MovieInfo
//
//  Created by Alfian Losari on 10/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit

class MovieSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var service: MovieService = MovieStore.shared
    var movies = [Movie]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.definesPresentationContext = true
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController?.searchBar.sizeToFit()
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
    
    private func searchMovie(query: String?) {
        guard let query = query, !query.isEmpty else {
            return
        }
        
        self.movies = []
        activityIndicatorView.startAnimating()
        infoLabel.isHidden = true
        service.searchMovie(query: query, params: nil, successHandler: {[unowned self] (response) in
            
            self.activityIndicatorView.stopAnimating()
            if response.totalResults == 0 {
                self.infoLabel.text = "No results for \(query)"
                self.infoLabel.isHidden = false
            }
            self.movies = Array(response.results.prefix(5))
        }) { [unowned self] (error) in
            self.activityIndicatorView.stopAnimating()
            self.infoLabel.isHidden = false
            self.infoLabel.text = error.localizedDescription
        }
        
    }
    
}

extension MovieSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
            as! MovieCell
        
        let movie = movies[indexPath.row]
        let viewModel = MovieViewViewModel(movie: movie)
        cell.configure(viewModel: viewModel)
        
        return cell
    }
        
}

extension MovieSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        searchMovie(query: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.movies = []
        self.infoLabel.text = "Start searching your favourite movies"
        self.infoLabel.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.movies = []
        if searchText.isEmpty {
            self.infoLabel.text = "Start searching your favourite movies"
            self.infoLabel.isHidden = false
        }
    }
    
}


