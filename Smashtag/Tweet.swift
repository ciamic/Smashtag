//
//  Tweet.swift
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

import Foundation
import CoreData
import Twitter


class Tweet: NSManagedObject {
    
    override func willSave() {
        super.willSave()
        if !self.isDeleted {
            if mentions == nil || mentions?.count == 0 {
                managedObjectContext?.delete(self)
            }
        }
    }
    
    /// Finds or creates Tweets, throwing an error if any of the creation fails
    /// - parameter tweetsInfo: the tweet informations to lookup in the db for existence
    /// - parameter context: the context where to search for the tweet
    class func findOrCreateTweets(matching tweetsInfo: [Twitter.Tweet],
                                  forSearchTerm searchTerm: String,
                                  in context: NSManagedObjectContext) throws -> [Tweet] {
        let newTweetIdentifiers = tweetsInfo.flatMap { $0.identifier }
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        var insertedTweets = [Tweet]()
        request.predicate = NSPredicate(format: "unique IN %@", newTweetIdentifiers)
        do {
            let alreadyContainedTweetsIdentifiers = try context.fetch(request).flatMap { $0.unique }
            for tweetInfo in tweetsInfo {
                if alreadyContainedTweetsIdentifiers.contains(tweetInfo.identifier),
                    let tweet = try findTweet(matching: tweetInfo, forSearchTerm: searchTerm, in: context) {
                    insertedTweets.append(tweet)
                } else {
                    insertedTweets.append(try createTweet(matching: tweetInfo, forSearchTerm: searchTerm, in: context))
                }
            }
            
            return insertedTweets
        } catch {
            // remove inserted tweets so far
            insertedTweets.forEach { context.delete($0) }
            throw error //rethrows
        }
    }
    
    /// Finds or creates a new Tweet, throwing an error if the creation fails.
    /// - parameter tweetInfo: the tweet information to lookup in the db for existence
    /// - parameter context: the context where to search for the tweet
    class func findOrCreateTweet(matching tweetInfo: Twitter.Tweet,
                                 forSearchTerm searchTerm: String,
                                 in context: NSManagedObjectContext) throws -> Tweet {
        do {
            return try findTweet(matching: tweetInfo, forSearchTerm: searchTerm, in: context) ??
                createTweet(matching: tweetInfo, forSearchTerm: searchTerm, in: context)
        } catch {
            throw error //rethrows
        }
    }
    
    // MARK: - Utility

    private class func findTweet(matching tweetInfo: Twitter.Tweet,
                                 forSearchTerm searchTerm: String,
                                 in context: NSManagedObjectContext) throws -> Tweet? {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", tweetInfo.identifier)
        do {
            let matches = try context.fetch(request)
            if !matches.isEmpty {
                assert(matches.count == 1, "Tweet.findOrCreateTweet --- database inconsistency!")
                try _ = Mention.insertMentions(of: tweetInfo, for: searchTerm, for: matches.first!, in: context)
                return matches.first!
            } else {
                return nil
            }
        } catch {
            throw error //rethrows
        }
    }
    
    private class func createTweet(matching tweetInfo: Twitter.Tweet,
                                   forSearchTerm searchTerm: String,
                                   in context: NSManagedObjectContext) throws -> Tweet {
        let tweet = Tweet(context: context)
        tweet.unique = tweetInfo.identifier
        tweet.text = tweetInfo.text
        tweet.posted = tweetInfo.created as NSDate
        tweet.tweeter = try? TwitterUser.findOrCreateTwitterUser(matching: tweetInfo.user, in: context)
        do {
            try Mention.insertMentions(of: tweetInfo, for: searchTerm, for: tweet, in: context)
        } catch {
            context.delete(tweet)
            throw error //rethrows
        }
        
        return tweet
    }
    
}
