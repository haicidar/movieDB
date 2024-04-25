//
//  ViewController.swift
//  MovieDB
//
//  Created by Muhammad Haidar Rais on 25/04/24.
//

import UIKit

class MoviesListVC: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var movieListTable: UITableView!
    private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    private var datasource = [MovieListViewModel](){
        didSet {
            movieListTable.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        movieListTable.dataSource = self
        movieListTable.delegate = self
        
        configureViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MoviesListVC {
    private func configureViewController() {
        
        // Configure table view
        configureTableView()
        
        // Setup activity indicator
        configureActivityIndicator()
        
        // Fetch datasource
        populateDatasource()
    }
    
    private func configureTableView() {
        movieListTable.register(MovieCell.nib, forCellReuseIdentifier: MovieCell.identifier)
        movieListTable.rowHeight = 110;
//        movieListTable.estimatedRowHeight = MovieCell.estimatedHeight;
    }
    
    private func configureActivityIndicator() {
        movieListTable.backgroundView = activityIndicator
        activityIndicator.startAnimating()
    }
    
    private func populateDatasource() {
        CacheManager.shared.moviesListViewModelDatasource { (datasource: [MovieListViewModel]) in
            DispatchQueue.main.async { [weak self] in
                
                self?.activityIndicator.stopAnimating()
                
                guard !datasource.isEmpty else {
                    let alert = UIAlertController(title: "Fetch Error", message: "Could not fetch movie list as of now, please try later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
                
                // Setup dataSource
                self?.datasource = datasource
            }
        }
    }
}

extension MoviesListVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell

        let movie = datasource[indexPath.row]
        cell.movieTitleLabel.text = movie.movieTitle
        cell.yearLabel.text = movie.releaseDate
        cell.genresLabel.text = movie.genres.joined(separator: ", ")
        
        CacheManager.shared.posterImage(for: movie.movieID, posterSourceURL: movie.posterURL!){ image in
            DispatchQueue.main.async {
                cell.posterImage.image = image
                cell.posterImage.contentMode = .scaleAspectFill
                cell.posterImage.clipsToBounds = true
                cell.posterImage.layer.cornerRadius = 10
                cell.posterImage.layer.masksToBounds = true
            }
        }

        return cell
    }
    
    
}

// MARK: -Segues

extension MoviesListVC{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = movieListTable.indexPathForSelectedRow {
                let movie = datasource[indexPath.row]
                let controller = segue.destination as! MovieDetailsVC
                controller.movieDetails = CacheManager.shared.movieDetailsViewModel(for: movie.movieID)
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

extension MoviesListVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: tableView.cellForRow(at: indexPath))
    }
}
