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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var currentSearchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()


        setupCoreData()
        setupFetchedResultsController()
        setupSearchController()
        
        configureDataSource()
        saveChangesToDisk()

       
        
        navigationItem.leftBarButtonItem = editButtonItem
        deleteButton.isEnabled = false
        deleteButton.tintColor = .clear
        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        let managedContext = container.viewContext
//        let fetchRequest = NSFetchRequest<Test>(entityName: "Test")
//
//        do {
//            users = try managedContext.fetch(fetchRequest)
//
//            setupSnapshot()
//
//
//        } catch {
//            print("fetch failed")
//        }
//
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
            
            print ("cell dequeued")
            return cell
        }
        setupSnapshot()
        print("configure data source")
    }
    
    //MARK: Delete button
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
 
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return  }
        for indexPath in indexPaths {
             let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            if cell.isSelected == true {
                
                            guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
                            var snapshot = dataSource.snapshot()
                
                            container.viewContext.delete(item)
                            saveChangesToDisk()
                            snapshot.deleteItems([item])
                
                            dataSource.apply(snapshot, animatingDifferences: true)
                
            } else {
                return
            }
            
        }
   
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
                deleteButton.tintColor = .clear
            } else {
                deleteButton.isEnabled = true
                deleteButton.tintColor = .systemRed
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
        diffableDataSourceSnapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        dataSource?.apply(self.diffableDataSourceSnapshot)
        print("snapshot setup")
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
            print("core data setup")
            if let error = error {
                print ("Failed to load database: \(error)")
            }
        }
    }
    
    //MARK: Fetched Results Controller setup
    
    func setupFetchedResultsController() {
        let request = Test.createfetchRequest()
        request.fetchBatchSize = 30
        
        if !currentSearchText.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@ OR subtitle CONTAINS[c] %@",currentSearchText, currentSearchText)
        }
        
        let sort = NSSortDescriptor (key: "name", ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        print("fetched results setup")
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
          print("save changed")
        } catch {
            print ("Failed to save changes to disk: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupSnapshot()
    }
    
    //MARK: Delete section (needs work - move to button)
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
//        if !isEditing != true {
//
//            guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return }
//            var snapshot = dataSource.snapshot()
//
//            container.viewContext.delete(item)
//            saveChangesToDisk()
//            snapshot.deleteItems([item])
//
//            dataSource.apply(snapshot, animatingDifferences: true)
//
//        } else {
//            return
//        }
        

     
    }
    
    
    //MARK: Search options (doesn't filter results)
    
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        print("search configured")
    }
    

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        currentSearchText = text
        setupFetchedResultsController()
        print(text)
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




