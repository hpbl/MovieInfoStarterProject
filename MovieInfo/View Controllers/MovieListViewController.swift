//
//  MovieListViewController.swift
//  MovieInfo
//
//  Created by Alfian Losari on 10/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var movieListViewViewModel: MovieListViewViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.movieListViewViewModel = MovieListViewViewModel(
            endpoint: self.segmentedControl.rx.selectedSegmentIndex
                .map { Endpoint(index: $0) ?? .nowPlaying }
                .asDriver(onErrorJustReturn: .nowPlaying),
            movieService: MovieStore.shared
        )
        
        self.movieListViewViewModel.movies.drive(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: self.disposeBag)
        
        self.movieListViewViewModel
            .isFetching
            .drive(self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        self.movieListViewViewModel
            .error
            .drive(onNext: { [unowned self] errorMessage in
                self.infoLabel.isHidden = !self.movieListViewViewModel.hasError
                self.infoLabel.text = errorMessage
            })
            .disposed(by: self.disposeBag)
        
        self.setupTableView()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
}

extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieListViewViewModel.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
            as! MovieCell
        
        if let viewModel = self.movieListViewViewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: viewModel)
        }
        
        return cell
    }
}
