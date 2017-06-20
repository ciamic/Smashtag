//
//  FetchedResultsTableViewController.swift
//
//  Copyright (c) 2017 michelangelo
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import CoreData

/// The FetchedResultsTableViewController whose purpose is to implement the NSFetchedResultsControllerDelegate protocol.
/// This approach doesnt work due to limitations in current generic Swift system.
/// CoreDataTableViewController is used instead.

class FetchedResultsTableViewController: UITableViewController, FetchedResultsViewControllerDataSource {
    
    typealias T = NSManagedObject
    
    var fetchedResultsController: NSFetchedResultsController<T>? = NSFetchedResultsController<T>()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - FetchedResultsViewControllerDataSource

protocol FetchedResultsViewControllerDataSource {
    
    associatedtype T: NSManagedObject
    
    var fetchedResultsController: NSFetchedResultsController<T>? { get }
    
    func numberOfSections(in tableView: UITableView) -> Int
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]?
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    
}

extension FetchedResultsViewControllerDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, !sections.isEmpty {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, !sections.isEmpty {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int{
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension FetchedResultsTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections([sectionIndex], with: .fade)
        case .delete:
            tableView.deleteSections([sectionIndex], with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
