//
//  ViewController.swift
//  superdiff
//
//  Created by Frank Foster on 12/5/19.
//  Copyright © 2019 Frank Foster. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var addTextField: UITextField!
    @IBOutlet weak var subtitleText: UITextField!
    
    weak var vc: CollectionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentationController?.delegate = self
        
    }

    @IBAction func saveButtonPress(_ sender: Any) {
        vc.addNewUser(with: addTextField.text!, with: subtitleText.text!)
        vc.setupSnapshot()
             dismiss(animated: true, completion: nil)
        
    }

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
//    func updateDataSource(with name: String) {
//        var snapshot = NSDiffableDataSourceSnapshot<CollectionViewController.Section, User>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(vc.users)
//        vc.dataSource.apply(snapshot, animatingDifferences: true)
//    
//        
//    }
    

}

