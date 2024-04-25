//
//  CacheManager.swift
//  MovieDB
//
//  Created by Muhammad Haidar Rais on 25/04/24.
//

import UIKit

class CacheManager {
    
    struct Constants {
        // Cache Names
        static let kMoviesCacheName = "MoviesCache"
        static let kPosterCacheName = "PosterCache"
        
        // Cache Keys
        static let kMoviesDataSourceKey = "MoviesDataSource"
    }
    
    static let shared = CacheManager()
    
    private let moviesCache = Cache<String, MoviesList>(withName: Constants.kMoviesCacheName)
    private let posterCache = Cache<Int, Data>(withName: Constants.kPosterCacheName)
    
    func moviesListViewModelDatasource(_ completion: @escaping (([MovieListViewModel]) -> Void)) {
        
        guard let moviesDatasource = moviesCache.object(forKey: Constants.kMoviesDataSourceKey) else {
            
            NetworkManager().fetchPopularMovies({ [weak self] (datasource: MoviesList?) in
                
                if let datasource = datasource {
                    self?.moviesCache.setObject(datasource, forKey: Constants.kMoviesDataSourceKey)
                }
                completion(datasource?.movieListViewModelDataSource() ?? [])
            })
            
            return
        }
        
        completion(moviesDatasource.movieListViewModelDataSource())
    }
    
    func posterImage(for movieID: Int, posterSourceURL: URL, _ completion: @escaping ((UIImage?) -> Void)) {
        
        guard let posterImageData = posterCache.object(forKey: movieID) else {
            
            NetworkManager().fetchPoster(from: posterSourceURL, { [weak self] (data: Data?) in
                
                if let imageData = data {
                    self?.posterCache.setObject(imageData, forKey: movieID)
                    completion(UIImage(data: imageData))
                }
                else {
                    completion(nil)
                }
            })
            
            return
        }
        
        completion(UIImage(data: posterImageData))
    }
    
    func movieDetailsViewModel(for movieID: Int) -> MovieDetailsViewModel? {
        guard let datasource = moviesCache.object(forKey: Constants.kMoviesDataSourceKey) else {
            return nil
        }
        
        return datasource.movieDetailsViewModelDataSource(for: movieID)
    }
    
    func movieDetailsViewModel(for movieID: Int, _ completion: @escaping ((MovieDetailsViewModel) -> Void)){
        NetworkManager().fetchMovieDetails(movieID: movieID, { (datasource: Movie?) in
            if let datasource = datasource{
                completion(datasource.movieDetailsViewModelDataSource())
            }
        })
        return
    }
    
}
