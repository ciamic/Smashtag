//
//  TweetersTableViewController.swift
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

/// Uses CoreData to show the name of tweeters who twitted tweets which contains a particular mention.
/// Counts up how many tweets with this mention each particular tweeter has posted.

class TweetersTableViewController: CoreDataTableViewController<TwitterUser> {
    
    // MARK: - Model
    
    var mention: String? { didSet { updateUI() } }
    var container: NSPersistentContainer? = AppDelegate.persistentContainer { didSet { updateUI() } }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TwitterUserCellIdentifier, for: indexPath)
        
        if let twitterUser = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = twitterUser.screenName
            let tweetCount = tweetCountWithMention(by: twitterUser)
            cell.detailTextLabel?.text = (tweetCount == 1) ? "1 tweet" : "\(tweetCount) tweets"
        }
        
        return cell
    }
    
    // MARK: - Utility
    
    fileprivate func updateUI() {
        guard let context = container?.viewContext, let mention = mention, !mention.isEmpty else {
            fetchedResultsController = nil //clears the table amongs other things
            return
        }
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention)
        request.sortDescriptors = [NSSortDescriptor(
            key: "screenName",
            ascending: true,
            selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )]
        fetchedResultsController = NSFetchedResultsController<TwitterUser>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }
    
    fileprivate func tweetCountWithMention(by user: TwitterUser) -> Int {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
        return (try? user.managedObjectContext!.count(for: request)) ?? 0
    }
    
} 
