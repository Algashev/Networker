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
    public var decoder = JSONDecoder()
    
    public init() { }
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    public func dataTask<T: Decodable>(with url: URL, _ type: T.Type, completion: @escaping NetworkerResult<T>) {
        let request = URLRequest(url: url)
        self.dataTask(with: request, T.self) { (result) in
            completion(result)
        }
    }
    
    public func dataTask<T: Decodable>(with request: URLRequest, _ type: T.Type, completion: @escaping NetworkerResult<T>) {
        self.dataTaskCore(with: request, T.self) { (result) in
            if case .failure(let error) = result {
                Networker.log(request, message: error.localizedDescription)
            }
            DispatchQueue.main.async { completion(result) }
        }
    }
}

//MARK: - Private Methods

extension Networker {
    private func dataTaskCore<T: Decodable>(with request: URLRequest, _ type: T.Type, completion: @escaping NetworkerResult<T>) {
        HTTPClient(URLSession.shared).dataTask(with: request) { (result) in
            switch result {
            case .success(let result):
                Networker.log(request, message: result.statusCode)
                let parser = JSONParser(self.decoder)
                let result = parser.decode(T.self, result.data)
                completion(result)
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
