//
//  MovieSearchViewViewModel.swift
//  MovieInfo
//
//  Created by Hilton Pintor Bezerra Leite on 02/09/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieSearchViewViewModel {
    private let movieService: MovieStore
    private let disposeBag = DisposeBag()
    
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _info = BehaviorRelay<String?>(value: nil)
    
    var movies: Driver<[Movie]> {
        return self._movies.asDriver()
    }
    
    var isFetching: Driver<Bool> {
        return self._isFetching.asDriver()
    }
    
    var info: Driver<String?> {
        return self._info.asDriver()
    }
    
    var hasInfo: Bool {
        return self._info.value != nil
    }
    
    var numberMovies: Int {
        return self._movies.value.count
    }
    
    init(query: Driver<String>, movieService: MovieStore) {
        self.movieService = movieService
        
        query
            .throttle(1.0)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (queryString) in
                self?.searchMovie(queryString: queryString)
                if queryString.isEmpty {
                    self?._movies.accept([])
                    self?._info.accept("Start searching your favorite movies")
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func searchMovie(queryString: String?) {
        guard let query = queryString, !query.isEmpty else {
            return
        }
        
        self._isFetching.accept(true)
        self._info.accept(nil)
        self._movies.accept([])
        
        self.movieService.searchMovie(
            query: query,
            params: nil,
            successHandler: { [weak self] (response) in
                self?._isFetching.accept(false)
                if response.totalResults == 0 {
                    self?._info.accept("No result for \(query)")
                }
                self?._movies.accept(Array(response.results.prefix(5)))
            }, errorHandler: { [weak self] (error) in
                self?._isFetching.accept(false)
                self?._info.accept(error.localizedDescription)
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
