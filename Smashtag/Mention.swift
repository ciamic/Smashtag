//
//  Mention.swift
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

class Mention: NSManagedObject {
    
    /// Finds or creates Mentions for the Twitter.Tweet passed as parameter, throwing an error if any of the creations fails.
    /// - parameter tweetInfo: the Twitter.Tweet for which UserMentions and Hashtags we create Mentions.
    /// - parameter searchTerm: the searchTerm used for searching
    /// - parameter tweet: the Tweet to relate the mentions with
    /// - parameter context: the context where to search for the mention
    class func insertMentions(of tweetInfo: Twitter.Tweet,
                              for searchTerm: String,
                              for tweet: Tweet,
                              in context: NSManagedObjectContext) throws {
        do {
            // insert mentions for both user mentions and hashtags
            try insertMentions(with: tweetInfo.userMentions, for: searchTerm, for: tweet, in: context, with: .UserMention)
            try insertMentions(with: tweetInfo.hashtags, for: searchTerm, for: tweet, in: context, with: .Hashtag)
        } catch {
            throw error //rethrows
        }
    }

    /// Deletes all the Mentions matching the searchTerm from the database.
    /// - parameter searchTerm: the searchTerm of the Mentions to be deleted
    /// - parameter completion: the closure to be called at the end of deletion
    class func deleteMentions(with searchTerm: String,
                              in context: NSManagedObjectContext,
                              completion: () -> ()) throws {
        let request: NSFetchRequest<Mention> = Mention.fetchRequest()
        request.predicate = NSPredicate(format: "searchTerm = [c] %@", searchTerm)
        debugPrint("Deleting \(searchTerm)")
        do {
            let mentionsToDelete = try context.fetch(request)
            mentionsToDelete.forEach { context.delete($0) }
            try context.save()
            completion()
        } catch let error {
            //we catch both the error on the execution of the fetch request and the one on the save
            throw error //rethrows
        }
    }
    
    private class func insertMentions(with mentions: [Twitter.Mention],
                                      for searchTerm: String,
                                      for tweet: Tweet,
                                      in context: NSManagedObjectContext,
                                      with mentionType: CoreDataMentionType) throws {
        var insertedMentions = [Mention]()
        do {
            //for each mention, try to create a new Mention, which in turn updates the count on number of mentions,
            //don't count multiple times same mentions for the same Tweet.
            var mentionsKeywords = Set<String>()
            for mention in mentions {
                if !mentionsKeywords.contains(mention.keyword) {
                    mentionsKeywords.insert(mention.keyword)
                    insertedMentions.append(try Mention.findOrCreateMention(matching: mention, for: searchTerm, for: tweet, with: mentionType, in: context))
                }
            }
        } catch {
            // delete all inserted mentions so far
            insertedMentions.forEach { context.delete($0) }
            throw error //rethrows
        }
    }

    /// Finds or creates a new Mention, throwing an error if the creation fails.
    /// - parameter mentionInfo: the mention information to lookup in the db for existence
    /// - parameter searchTerm: the searchTerm to lookup in the db for existence
    /// - parameter tweet: the tweet to relate to the mention
    /// - parameter type: the type of the mention
    /// - parameter context: the context where to search for the mention
    private class func findOrCreateMention(matching mentionInfo: Twitter.Mention,
                                           for searchTerm: String,
                                           for tweet: Tweet,
                                           with type: CoreDataMentionType,
                                           in context: NSManagedObjectContext) throws -> Mention {
        let request: NSFetchRequest<Mention> = Mention.fetchRequest()
        request.predicate = NSPredicate(format: "searchTerm = %@ and keyword = [c] %@ and type = %@",
                                        searchTerm,
                                        mentionInfo.keyword,
                                        type.rawValue)
        do {
            //try to get a Mention who matches the info given in the parameters
            let matches = try context.fetch(request)
            //if found, check if the tweet passed as parameters was already counted into the mentionedInTweet relationship.
            //if not, increment such counter and store the tweet into the relationship.
            if !matches.isEmpty {
                assert(matches.count == 1, "Mention.findOrCreateMention --- database inconsistency!")
                let mention = matches.first!
                if mention.mentionedInTweets != nil, !mention.mentionedInTweets!.contains(tweet) {
                    mention.numberOfMentions = NSNumber(value: mention.numberOfMentions!.intValue + 1)
                    mention.addToMentionedInTweets(tweet)
                }
                return mention
            }
        } catch {
            throw error //rethrows
        }
        
        //If not found, create a new Mention with the info passed as parameters and set the number of mentions count to 1.
        let mention = Mention(context: context)
        mention.keyword = mentionInfo.keyword
        mention.numberOfMentions = 1
        mention.searchTerm = searchTerm
        mention.type = type.rawValue
        mention.addToMentionedInTweets(tweet)
        return mention
    }

}
