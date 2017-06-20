//
//  TwitterMentionsPopularityViewController.swift
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

///Uses CoreData to count

class TwitterMentionsPopularityViewController: CoreDataTableViewController<Mention> {
    
    // MARK: - Model
    
    var searchTerm: String? { didSet { updateUI() } }
    var container: NSPersistentContainer? { didSet { updateUI() } }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.ShowTweetFromMentions {
                if let tvc = segue.destination as? TweetTableViewController,
                    let cell = sender as? UITableViewCell {
                    tvc.searchText = cell.textLabel?.text
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TwitterMentionCellIdentifier, for: indexPath)
        
        if let mention = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = mention.keyword
            if let mentionsCount = mention.numberOfMentions?.intValue {
                cell.detailTextLabel?.text = "\(mentionsCount) mentions"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        
        return cell
    }
    
    // MARK: - Utility
    
    fileprivate func updateUI() {
        
        guard let context = container?.viewContext, let searchTerm = searchTerm, !searchTerm.characters.isEmpty else {
            fetchedResultsController = nil //clears the table amongs other things
            return
        }
        let request: NSFetchRequest<Mention> = Mention.fetchRequest()
        //below the "right" predicate as required in the assignment.
        request.predicate = NSPredicate(format: "any searchTerm = %@ AND numberOfMentions > 1", searchTerm)
        //while the assignment required to retreive only mentions with > 1 citations, for debug purpose we get them all
        //request.predicate = NSPredicate(format: "any searchTerm = %@", searchTerm)
        let mentionTypeSortDescriptor = NSSortDescriptor(key: "type", ascending: false)
        let popularitySortDescriptior = NSSortDescriptor(key: "numberOfMentions", ascending: false)
        let alphabeticalCaseInsensitiveSortDescriptor = NSSortDescriptor(key: "keyword",
                                                                         ascending: true,
                                                                         selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        request.sortDescriptors = [
            mentionTypeSortDescriptor, //order by type (for sections)
            popularitySortDescriptior, //then by popularity
            alphabeticalCaseInsensitiveSortDescriptor //then alphabetically (case insensitively)
        ]
        fetchedResultsController = NSFetchedResultsController<Mention> (
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "type", //we have different sections given by the type attribute
            cacheName: nil)
    }

}
