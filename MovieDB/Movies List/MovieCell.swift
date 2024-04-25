//
//  MovieCell.swift
//  MovieDB
//
//  Created by Muhammad Haidar Rais on 25/04/24.
//

import Foundation
import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    
    static let identifier = "MovieCell"
    static let estimatedHeight: CGFloat = 110.0
    static let nib = UINib(nibName: "MovieCell", bundle: Bundle.main)
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
