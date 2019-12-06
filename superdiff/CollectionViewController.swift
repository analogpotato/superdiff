//
//  CollectionViewController.swift
//  superdiff
//
//  Created by Frank Foster on 12/5/19.
//  Copyright © 2019 Frank Foster. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    let alertService = AlertService()
    
    var users: [Test] = []
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Test>!
    var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Test> ()
    
    var container = NSPersistentContainer (name: "superdiff")
    var fetchedResultsController: NSFetchedResultsController<Test>!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        setupCoreData()
        setupFetchedResultsController()
    }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Test> (collectionView: collectionView) { (collectionView, indexPath, user) -> UICollectionViewCell in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else {
                fatalError ("Cannot create cell")
            }
            
            cell.userText.text = user.name
            cell.subtitleText.text = user.subtitle
            
            
            return cell
        }
        setupSnapshot()
    }
    
    
    func addNewUser(with name: String, with subtitle: String) {
        let user = Test(context: container.viewContext)
        
        user.name = name
        user.subtitle = subtitle
        
        users.append(user)
        print(users)
        print([Test]())
        setupSnapshot()
    }
    
    
    func setupSnapshot() {
        diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Test>()
        diffableDataSourceSnapshot.appendSections([.main])
        diffableDataSourceSnapshot.appendItems(users)
        dataSource?.apply(self.diffableDataSourceSnapshot)
    }
    
//    func createSnapshot (from users: [User]) {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Test>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(users)
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
    
    func setupCoreData() {
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print ("Failed to load database: \(error)")
            }
        }
    }
    
    
    func setupFetchedResultsController() {
        let request = Test.createfetchRequest()
        request.fetchBatchSize = 30
        
        let sort = NSSortDescriptor (key: "name", ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            setupSnapshot()
        } catch {
            print ("Fetch failed")
        }
        
        
    }
    
    func saveChangesToDisk () {
        guard container.viewContext.hasChanges else { return }
        
        do {
            try container.viewContext.save()
        } catch {
            print ("Failed to save changes to disk: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupSnapshot()
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
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddView", let navigationController = segue.destination as? UINavigationController, let viewController = navigationController.children.first as? ViewController {
            viewController.vc = self
            
        }
    }
    
    
}
extension CollectionViewController {
    enum Section {
        case main
    }
}
