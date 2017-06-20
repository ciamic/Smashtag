//
//  TweetCoreDataViewController.swift
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
import Twitter

/// TweetCoreDataViewController enhances TweetTableViewController with CoreData capabilities.

class TweetCoreDataViewController: TweetTableViewController {
    
    // MARK: - Model
    
    //The persistent container where to get the db to update (if any).
    //For demo purpose it has a default value.
    //This could be set from the object that uses this controller in order to save in a different db.
    var container: NSPersistentContainer? = AppDelegate.persistentContainer
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TweetCoreDataViewController.tweetHistoryRemoved(notification:)),
                                               name: Notification.Name(History.HistoryRemovedNotification),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(History.HistoryRemovedNotification),
                                                  object: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == Storyboard.ShowTweetersTableView {
            if let ttvc = segue.destination as? TweetersTableViewController {
                ttvc.mention = searchText
                ttvc.container = container
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Utility
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(newTweets)
    }
    
    fileprivate func updateDatabase(_ newTweets: [Twitter.Tweet]) {
        //we update the database using a background task
        container?.performBackgroundTask { [weak self] context in
            /*
            newTweets.forEach {
                //create a new but unique Tweet
                _ = try? Tweet.findOrCreateTweet(matching: $0,
                                                 forSearchTerm: self?.searchText != nil ? self!.searchText! : "",
                                                 in: context)
            }
            */
            _ = try? Tweet.findOrCreateTweets(matching: newTweets,
                                              forSearchTerm: self?.searchText != nil ? self!.searchText! : "",
                                              in: context)
            do {
                try context.save()
            } catch let error {
                debugPrint("Core Data Error: \(error)")
            }
            
            self?.printDatabaseStatistics(with: context)
        }
        
        //the line of code below would print before the statistics. This is because perform in printDatabaseStatistics
        //returns immediatly putting the block in the queue of the context and then the line below is executed. Later in time
        //the block will execute and print the statistics. This could also be true even if the block is performed in
        //the main thread and this code is executing on the main thread because we also have a queue for the main thread.
        
        //print("Done printing database statistics")
    }
    
    @objc private func tweetHistoryRemoved(notification: Notification) {
        if let removedSearchTerm = notification.userInfo?[History.HistoryRemovedNotificationValue] as? String {
            container?.performBackgroundTask { [weak self] context in
                try? Mention.deleteMentions(with: removedSearchTerm, in: context) {
                    self?.printDatabaseStatistics(with: context)
                }
            }
        }
    }
    
    /// Prints out database statistics
    func printDatabaseStatistics(with context: NSManagedObjectContext) {
        debugPrint("--- Printing DB Statistics ---")
        //a slow way to count (even if we know that with faulting is not that bad)
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        if let results = try? context.fetch(request) {
            debugPrint("\(results.count) TwitterUsers")
        }
                
        //a more efficient way to count is this...
        if let tweetCount = try? context.count(for: Tweet.fetchRequest()) {
            debugPrint("\(tweetCount) Tweets")
        }
                
        if let mentionsCount = try? context.count(for: Mention.fetchRequest()) {
            debugPrint("\(mentionsCount) Mentions")
        }
    }
    
}
