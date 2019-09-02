//
//  MovieViewViewModel.swift
//  MovieInfo
//
//  Created by Hilton Pintor Bezerra Leite on 02/09/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation

struct MovieViewViewModel {
    let title: String
    let overView: String
    let posterURL: URL
    let formattedReleaseDate: String
    let formattedRating: String
    
    private let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
        
        self.title = movie.title
        self.overView = movie.overview
        self.posterURL = movie.posterURL

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.formattedReleaseDate = dateFormatter
            .string(from: movie.releaseDate)
        
        let rating = Int(movie.voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "⭐️"
        }
        self.formattedRating = ratingText
    }
}
