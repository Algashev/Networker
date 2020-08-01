//
//  Networker.swift
//  Networker
//
//  Created by Александр Алгашев on 14.05.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import UIKit

let module = NSStringFromClass(Networker.self).components(separatedBy:".")[0]

public typealias DecodableResult = Result<Decodable, Error>
public typealias NWDecodableCompetion = (DecodableResult) -> Void
public typealias ImageResult = Result<UIImage, Error>
public typealias NWImageCompletion = (ImageResult) -> Void

public final class Networker {
    public enum Error: Swift.Error {
        case invalidImageData
    }
    
    private static var isVerboseEnabled = false
    public var decoder = JSONDecoder()
    
    public init() { }
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    public func verbose() {
        Networker.isVerboseEnabled = true
    }
    
    public func requestJSON<T: Decodable>(with url: URL, _ type: T.Type, completion: @escaping NWDecodableCompetion) {
        let request = URLRequest(url: url)
        self.requestJSON(with: request, T.self) { (result) in
            completion(result)
        }
    }
    
    public func requestJSON<T: Decodable>(with request: URLRequest, _ type: T.Type, completion: @escaping NWDecodableCompetion) {
        self.dataTaskJSONCore(with: request, T.self) { (result) in
            DispatchQueue.main.async { completion(result) }
        }
    }
    
    public func requestImage(with url: URL, completion: @escaping NWImageCompletion) {
        let request = URLRequest(url: url)
        self.requestImage(with: request) { (result) in
            completion(result)
        }
    }
    
    public func requestImage(with request: URLRequest, completion: @escaping NWImageCompletion) {
        self.imageDataTask(with: request) { (result) in
            DispatchQueue.main.async { completion(result) }
        }
    }
}

extension Networker.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidImageData:
            let key = "Не удалось создать изображение из полученных данных"
            let comment = "Неверный формат данных изображения"
            return NSLocalizedString(key, comment: comment)
        }
    }
}

//MARK: - Private Methods

extension Networker {
    private func dataTaskJSONCore<T: Decodable>(with request: URLRequest, _ type: T.Type, completion: @escaping NWDecodableCompetion) {
        HTTPClient(URLSession.shared).dataTask(with: request) { (result) in
            switch result {
            case .success(let result):
                Networker.log(request, message: result.statusCode)
                do {
                    let result = try T(decoding: result.data, decoder: self.decoder)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                Networker.log(request, message: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    private func imageDataTask(with request: URLRequest, completion: @escaping NWImageCompletion) {
        HTTPClient(URLSession.shared).dataTask(with: request) { (result) in
            switch result {
            case .success(let result):
                Networker.log(request, message: result.statusCode)
                if let image = UIImage(data: result.data) {
                    completion(.success(image))
                } else {
                    let error = Networker.Error.invalidImageData
                    Networker.log(request, message: error.localizedDescription)
                    completion(.failure(error))
                }
            case .failure(let error):
                Networker.log(request, message: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    private static func log(_ request: URLRequest, message: String) {
        guard Networker.isVerboseEnabled else { return }
        let url = request.url?.absoluteString ?? "(пустое значение ulr)"
        print("\(module)\n\(url)\n\(message)")
    }
}
