//
//  MovieListViewViewModel.swift
//  MovieInfo
//
//  Created by Hilton Pintor Bezerra Leite on 02/09/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MovieListViewViewModel {
    private let movieService: MovieStore
    private let disposeBag = DisposeBag()
    
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _error = BehaviorRelay<String?>(value: nil)
    
    var isFetching: Driver<Bool> {
        return self._isFetching.asDriver()
    }
    
    var movies: Driver<[Movie]> {
        return self._movies.asDriver()
    }
    
    var error: Driver<String?> {
        return self._error.asDriver()
    }
    
    var hasError: Bool {
        return self._error.value != nil
    }
    
    var numberOfMovies: Int {
        return self._movies.value.count
    }
    
    init(endpoint: Driver<Endpoint>, movieService: MovieStore) {
        self.movieService = movieService
        
        endpoint.drive(onNext: { [weak self] (endpoint) in
            self?.fetchMovies(endpoint: endpoint)
        }).disposed(by: self.disposeBag)
    }
    
    func fetchMovies(endpoint: Endpoint) {
        self._movies.accept([])
        self._isFetching.accept(true)
        self._error.accept(nil)
        
        self.movieService.fetchMovies(
            from: endpoint,
            successHandler: { [weak self] (response) in
                self?._isFetching.accept(false)
                self?._movies.accept(response.results)
            },
            errorHandler: { [weak self] (error) in
                self?._isFetching.accept(false)
                self?._error.accept(error.localizedDescription)
        })
    }

    func viewModelForMovie(at index: Int) -> MovieViewViewModel? {
        guard index < self._movies.value.count else {
            return nil
        }
        
        let movie = self._movies.value[index]
        return MovieViewViewModel(movie: movie)
    }
}
