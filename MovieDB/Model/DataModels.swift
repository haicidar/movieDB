//
//  Movie.swift
//  MovieDB
//
//  Created by Muhammad Haidar Rais on 25/04/24.
//

import Foundation

struct MoviesList: Codable {
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let releaseDate: String
    let posterPath: String
    let genreIds: [Int]?
    var runtime: Int?
    var genres: [Genre]?
    var overview: String?
    var casts: [Cast]?
}

struct Genre: Codable{
    let id: Int
    let name: String
}

struct Cast: Codable {
    let id: Int
    let name: String
    let profilePath: String
    
    
}

fileprivate let genreDict: [Int: String] = [
    28: "Action",
    12: "Adventure",
    16: "Animation",
    35: "Comedy",
    80: "Crime",
    99: "Documentary",
    18: "Drama",
    10751: "Family",
    14: "Fantasy",
    36: "History",
    27: "Horror",
    10402: "Music",
    9648: "Mystery",
    10749: "Romance",
    878: "Science Fiction",
    10770: "TV Movie",
    53: "Thriller",
    10752: "War",
    37: "Western"
]

extension MoviesList {
    
    func movieListViewModelDataSource() -> [MovieListViewModel]{
        return movies.map {
            return MovieListViewModel(
                movieID: $0.id,
                movieTitle: $0.title,
                releaseDate: $0.releaseDate.components(separatedBy: "-").first ?? "0000",
                posterURL: URL(string: "https://image.tmdb.org/t/p/w500\($0.posterPath)"),
                genres: $0.genreIds!.compactMap{ genreDict[$0] }
            )
        }
    }
    
    func movieDetailsViewModelDataSource(for movieID: Int) -> MovieDetailsViewModel? {
        let movie = movies.filter{ $0.id == movieID}.first
        guard let movie = movie else {
            print("Error: Could not find the repository with id \(movieID) in cache ")
            return nil
        }
        
        return MovieDetailsViewModel(
            movieID: movie.id,
            movieTitle: movie.title,
            runtime: "\((movie.runtime ?? 0) / 60)h \((movie.runtime ?? 0) % 60)m",
            posterURL: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)"),
            genres: movie.genreIds!.compactMap{ genreDict[$0] },
            overview: movie.overview ?? ""
        )
    }
}

extension Movie {
    func movieDetailsViewModelDataSource() -> MovieDetailsViewModel{
        return MovieDetailsViewModel(
            movieID: id,
            movieTitle: title,
            runtime: "\((runtime ?? 0) / 60)h \((runtime ?? 0) % 60)m",
            posterURL: URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"),
            genres: genres?.map{ $0.name } ?? [],
            overview: overview ?? ""
        )
    }
}
