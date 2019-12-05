//
//  CollectionViewController.swift
//  superdiff
//
//  Created by Frank Foster on 12/5/19.
//  Copyright © 2019 Frank Foster. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {
    
    let alertService = AlertService()
    
    var users = [User]()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, User>!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
    }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, User> (collectionView: collectionView) { (collectionView, indexPath, user) -> UICollectionViewCell in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else {
                fatalError ("Cannot create cell")
            }
            
            cell.userText.text = user.name
            
            
            return cell
        }
    }
    
    
    func addNewUser(with name: String) {
        let user = User(name: name)
        users.append(user)
        print(users)
        
        createSnapshot(from: users)
    }
    
    func createSnapshot (from users: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    @IBAction func addButton(_ sender: Any) {
//        let alert = alertService.createUserAlert { [weak self] name in
//
//                self?.addNewUser(with: name)
//               }
//               present(alert, animated: true)
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = dataSource.itemIdentifier(for: indexPath) else {return}
        print(user)
        
        
    }
    
    
    
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AddView", let addView = segue.destination as? ViewController {
//          
//        }
//    }
    
    
}
extension CollectionViewController {
    enum Section {
        case main
    }
}
