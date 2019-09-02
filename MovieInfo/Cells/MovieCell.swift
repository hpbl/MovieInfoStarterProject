//
//  MovieCell.swift
//  MovieInfo
//
//  Created by Alfian Losari on 10/03/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    func configure(viewModel: MovieViewViewModel) {
        self.titleLabel.text = viewModel.title
        self.overviewLabel.text = viewModel.overView
        self.releaseDateLabel.text = viewModel.formattedReleaseDate
        self.ratingLabel.text = viewModel.formattedRating
        self.posterImageView.kf.setImage(with: viewModel.posterURL)
    }
}
