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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://yandex.ru/") else { return }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let networker = Networker(decoder: decoder)
        networker.dataTask(with: url, String.self) { (result) in
            print("Networker Completed")
        }
    }


}

