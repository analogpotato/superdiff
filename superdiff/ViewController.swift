//
//  ViewController.swift
//  superdiff
//
//  Created by Frank Foster on 12/5/19.
//  Copyright © 2019 Frank Foster. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var addTextField: UITextField!

   let vc = CollectionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func saveButton(_ sender: Any) {
        updateDataSource(with: addTextField.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateDataSource(with name: String) {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionViewController.Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(vc.users)
        vc.dataSource.apply(snapshot, animatingDifferences: true)
    
        
    }
    

}

