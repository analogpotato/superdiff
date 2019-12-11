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

class CollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    let alertService = AlertService()
    
    var users: [Test] = []
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Test>!
    var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Test> ()
    
    var container = NSPersistentContainer (name: "superdiff")
    var fetchedResultsController: NSFetchedResultsController<Test>!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var currentSearchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        setupCoreData()
        setupFetchedResultsController()
        
        setupSearchController()
        
        navigationItem.leftBarButtonItem = editButtonItem
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
        let managedContext = container.viewContext
        let fetchRequest = NSFetchRequest<Test>(entityName: "Test")
        
        do {
            users = try managedContext.fetch(fetchRequest)
//            saveChangesToDisk()
            setupSnapshot()
        } catch {
            print("fetch failed")
        }
        
        print(users)
    }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Test> (collectionView: collectionView) { (collectionView, indexPath, user) -> UICollectionViewCell in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else {
                fatalError ("Cannot create cell")
            }
            
            cell.userText.text = user.name
            cell.subtitleText.text = user.subtitle
            
            cell.isInEditingMode = self.isEditing
            
            return cell
        }
        setupSnapshot()
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
    }


    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView.allowsMultipleSelection = editing
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.isInEditingMode = editing
            
            if !isEditing {
                deleteButton.isEnabled = false
            } else {
                deleteButton.isEnabled = true
            }
        }
        
    }
    
    //MARK: Add New User function
    
    func addNewUser(with name: String, with subtitle: String) {
        let user = Test(context: container.viewContext)
        
        user.name = name
        user.subtitle = subtitle
        
        users.append(user)
//        print(user)

        setupSnapshot()
        saveChangesToDisk()
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
        
        if !currentSearchText.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", currentSearchText)
        }
        
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
//            print("saved \(users)")
        } catch {
            print ("Failed to save changes to disk: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupSnapshot()
    }
    
    //MARK: Delete section (needs work - move to button)
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing != true {

            
            
            if let deleteItems = dataSource.itemIdentifier(for: indexPath) {
                
                let commit = users[indexPath.row]
                container.viewContext.delete(commit)
                users.remove(at: indexPath.row)
                
                saveChangesToDisk()
                
                var currentSnapshot = dataSource.snapshot()
                currentSnapshot.deleteItems([deleteItems])
                dataSource.apply(currentSnapshot)
                print("this is the deleted array of objects \(deleteItems)")


            }
            
            
        } else {
            return
        }
    }
    
    
    //MARK: Search options (doesn't filter results)
    
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
    }
    

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        currentSearchText = text
        setupFetchedResultsController()
        
    }
    

    //MARK: Segues
    
    
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
    func remove(_ item: [Test], animate: Bool = true) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(users)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
}




