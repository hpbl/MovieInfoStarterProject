//
//  MovieSearchViewController.swift
//  MovieInfo
//
//  Created by Alfian Losari on 10/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MovieSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    var movieSearchViewViewModel: MovieSearchViewViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        let searchBar = self.navigationItem.searchController!.searchBar
        
        self.movieSearchViewViewModel = MovieSearchViewViewModel(
            query: searchBar.rx.text.orEmpty.asDriver(),
            movieService: MovieStore.shared
        )
        
        self.movieSearchViewViewModel
            .movies
            .drive(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
        
        self.movieSearchViewViewModel
            .isFetching
            .drive(self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        self.movieSearchViewViewModel
            .info
            .drive(onNext: { [unowned self] info in
                self.infoLabel.text = info
                self.infoLabel.isHidden = self.movieSearchViewViewModel.hasInfo
            })
            .disposed(by: self.disposeBag)
        
        searchBar.rx.searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned searchBar] _ in
                searchBar.resignFirstResponder()
            })
            .disposed(by: self.disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned searchBar] _ in
                searchBar.resignFirstResponder()
            })
            .disposed(by: self.disposeBag)
        
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.definesPresentationContext = true
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController?.searchBar.sizeToFit()
//        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
}

extension MovieSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieSearchViewViewModel.numberMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
            as! MovieCell
        
        if let viewModel = self.movieSearchViewViewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: viewModel)
        }
        
        return cell
    }
}
