//
//  MovieDetailsVC.swift
//  MovieDB
//
//  Created by Muhammad Haidar Rais on 25/04/24.
//

import UIKit

class MovieDetailsVC: UIViewController {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    var movieDetails: MovieDetailsViewModel?{
        didSet{
            debugPrint(movieDetails)
            //            configureView()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        configureView()
        populateDatasource()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func configureView() {
        if let details = movieDetails{
            movieTitleLabel.text = details.movieTitle
            genresLabel.text = details.genres.joined(separator: ", ")
            runtimeLabel.text = details.runtime
            overviewLabel.text = details.overview
            
            CacheManager.shared.posterImage(for: details.movieID, posterSourceURL: (details.posterURL)!){ image in
                DispatchQueue.main.async { [weak self] in
                    self?.posterImageView.image = image
                    self?.posterImageView.contentMode = .scaleAspectFill
                    self?.posterImageView.clipsToBounds = true
                }
            }
        }
    }
}

extension MovieDetailsVC {
    private func populateDatasource() {
        CacheManager.shared.movieDetailsViewModel(for: movieDetails!.movieID) { datasource in
            DispatchQueue.main.async { [weak self] in
                
                self?.activityIndicator.stopAnimating()
                // Setup dataSource
                self?.movieDetails = datasource
                self?.configureView()
            }
        }
    }
}

