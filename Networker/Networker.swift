//
//  Networker.swift
//  Networker
//
//  Created by Александр Алгашев on 14.05.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import Foundation

let module = NSStringFromClass(Networker.self).components(separatedBy:".")[0]

public typealias NetworkerResult<T: Decodable> = (Result<T, Error>) -> Void

public final class Networker {
    public static func dataTask<T: Decodable>(with url: URL, _ type: T.Type, completion: @escaping NetworkerResult<T>) {
        let request = URLRequest(url: url)
        Networker.dataTask(with: request, T.self) { (result) in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public static func dataTask<T: Decodable>(with request: URLRequest, _ type: T.Type, completion: @escaping NetworkerResult<T>) {
        DispatchQueue(label: "algashev.Networker.dataTask", qos: .userInitiated).async {
            Networker.dataTaskInQueue(with: request, T.self) { (result) in
                switch result {
                case .success(let result):
                    DispatchQueue.main.async { completion(.success(result)) }
                case .failure(let error):
                    Networker.log(request, message: error.localizedDescription)
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
        }
    }
}

//MARK: - Private Methods

extension Networker {
    private static func dataTaskInQueue<T: Decodable>(with request: URLRequest, _ type: T.Type, completion: @escaping NetworkerResult<T>) {
        HTTPClient(URLSession.shared).getData(with: request) { (result) in
            switch result {
            case .success(let result):
                Networker.log(request, message: result.statusCode)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let parser = JSONParser(decoder)
                let result = parser.decode(T.self, result.data)
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func log(_ request: URLRequest, message: String) {
        let url = request.url?.absoluteString ?? "(пустое значение ulr)"
        print("\(module)\n\(url)\n\(message)")
    }
}
