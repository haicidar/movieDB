//
//  NetworkManager.swift
//  MovieDB
//
//  Created by Muhammad Haidar Rais on 25/04/24.
//

import Foundation

class NetworkManager {
    
    private struct Constants {
        static let memoryCacheByteLimit: Int = 4 * 1024 * 1024 // 20 MB
        static let diskCacheByteLimit: Int = 20 * 1024 * 1024          // 4 MB
        static let cacheName: String = "MovieDB.cache"
        static let apiKey = "8967810624aca673ecb20904b7d8a5fa"
        static let allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4OTY3ODEwNjI0YWNhNjczZWNiMjA5MDRiN2Q4YTVmYSIsInN1YiI6IjY2MjkyNzQ3YmJlMWRkMDE3ZWE5YmEwYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.8s_7oUijq1QDY48jNrNcoEUIHPQumkznlUlnmMMYBlo"
          ]
    }
    
    static func setupURLCache() {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.cacheName) else {
            assertionFailure("Failed to setup URL Cache: Can not get cache file path.")
            return
        }
        let cache = URLCache(memoryCapacity: Constants.memoryCacheByteLimit, diskCapacity: Constants.diskCacheByteLimit, diskPath: cacheURL.path)
        URLCache.shared = cache
    }
    
}

extension NetworkManager {
    func fetchPoster(from posterURL: URL, _ completion: @escaping ((Data?) -> Void)) {
        let dataTask = URLSession.shared.dataTask(with: posterURL) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: Failed to load image:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            completion(data)
        }
        dataTask.resume()
    }
}


//    MARK: - Movie List
extension NetworkManager {
    
    private var popularMoviesURL: URL? {
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        components.queryItems = {
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "language", value: "en-US"))
            queryItems.append(URLQueryItem(name: "page", value: "1"))
            queryItems.append(URLQueryItem(name: "api_key", value: Constants.apiKey))
            return queryItems
        }()
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = Constants.allHTTPHeaderFields
        return request.url
    }
    
    func fetchPopularMovies(_ completion: @escaping ((MoviesList?) -> Void)){
        assert(popularMoviesURL != nil, "popularMoviesURL should never be nil")
        guard let url = popularMoviesURL else { completion(nil); return }
        
        let dataTask = URLSession.shared.dataTask(with: url){ (data, response, error) in
            guard let jsonData = data else {
                print("Error: Failed to get json data, error: \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let datasource = try decoder.decode(MoviesList.self, from: jsonData)
                completion(datasource)
            }
            catch let error {
                print("Error: Failed to decode json data, error: \(String(describing: error))")
                completion(nil)
                return
            }
        }
        dataTask.resume()
    }
}

//    MARK: - Movie Details
extension NetworkManager {
    
    private func movieDetailsURL(movieID: Int) -> URL? {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        components.queryItems = {
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "language", value: "en-US"))
            queryItems.append(URLQueryItem(name: "api_key", value: Constants.apiKey))
            components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

            return queryItems
        }()
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = Constants.allHTTPHeaderFields
        return request.url
    }
    
    func fetchMovieDetails(movieID: Int,_ completion: @escaping ((Movie?) -> Void)){
        guard let url = movieDetailsURL(movieID: movieID) else { completion(nil); return }
        
        let dataTask = URLSession.shared.dataTask(with: url){ (data, response, error) in
            guard let jsonData = data else {
                print("Error: Failed to get json data, error: \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let datasource = try decoder.decode(Movie.self, from: jsonData)
                completion(datasource)
            }
            catch let error {
                print("Error: Failed to decode json data, error: \(String(describing: error))")
                completion(nil)
                return
            }
        }
        dataTask.resume()
    }
}

//    MARK: - Genres
extension NetworkManager {
    
    private var genresURL: URL? {
        let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        components.queryItems = {
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "language", value: "en"))
            queryItems.append(URLQueryItem(name: "api_key", value: Constants.apiKey))
            components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
            return queryItems
        }()
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = Constants.allHTTPHeaderFields
        return request.url
    }
    
    func fetchGenres(_ completion: @escaping (([Genre]?) -> Void)){
        assert(genresURL != nil, "genresURL should never be nil")
        guard let url = genresURL else { completion(nil); return }
        
        let dataTask = URLSession.shared.dataTask(with: url){ (data, response, error) in
            guard let jsonData = data else {
                print("Error: Failed to get json data, error: \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let datasource = try decoder.decode([Genre].self, from: jsonData)
                completion(datasource)
            }
            catch let error {
                print("Error: Failed to decode json data, error: \(String(describing: error))")
                completion(nil)
                return
            }
        }
        dataTask.resume()
    }
}


