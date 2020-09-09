//
//  ViewController.swift
//  NetworkerExamples
//
//  Created by Александр Алгашев on 14.05.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import UIKit
import Networker

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://yandex.ru/") else { return }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let networker = Networker(decoder: decoder)
        networker.verbose()
        networker.requestJSON(with: url, String.self) { (result) in
            print("Networker Completed")
        }
        
        guard let imageUrl = URL(string: "https://sun9-23.userapi.com/c637825/v637825363/4cb80/XI1ojczcn9U.jpg") else { return }
        networker.requestImage(with: imageUrl) { (result) in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print(error)
            }
        }
    }


}

