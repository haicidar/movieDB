//
//  MovieDetail.swift
//  MovieDB
//
//  Created by Muhammad Haidar Rais on 25/04/24.
//

import Foundation

//struct MovieDetail: Codable {
//    let id: Int
//    let title: String
//    let releaseDate: Date
//    let genreIds: [Int]
//    let posterPath: String
//}

struct MovieListViewModel {
    let movieID: Int
    let movieTitle: String
    let releaseDate: String
    let posterURL: URL?
    let genres: [String]
}

struct MovieDetailsViewModel {
    let movieID: Int
    let movieTitle: String
    let runtime: String
    let posterURL: URL?
    let genres: [String]
    let overview: String
//    let cast: (name: String, profileURL: URL?)?
}
