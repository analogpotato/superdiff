//
//  Alert Service.swift
//  superdiff
//
//  Created by Frank Foster on 12/5/19.
//  Copyright © 2019 Frank Foster. All rights reserved.
//

import UIKit

struct AlertService {
    func createUserAlert (completion: @escaping (String) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Create User", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Enter user's name:" }
        let action = UIAlertAction(title: "Save", style: .default) { _ in
            let usersName = alert.textFields?.first?.text ?? ""
            completion(usersName)
        }
        alert.addAction(action)
        return alert
    }
}



