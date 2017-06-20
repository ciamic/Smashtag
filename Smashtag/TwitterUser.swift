//
//  TwitterUser.swift
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

class TwitterUser: NSManagedObject {
    
    override func willSave() {
        super.willSave()
        if !self.isDeleted {
            if tweets == nil || tweets?.count == 0 {
                managedObjectContext?.delete(self)
            }
        }
    }
    
    /// Finds or creates a new TweeterUser, throwing an error if the creation fails.
    /// - parameter userInfo: the twitter user information to lookup in the db for existence
    /// - parameter context: the context where to search for the twitter user
    class func findOrCreateTwitterUser(matching userInfo: Twitter.User, in context: NSManagedObjectContext) throws -> TwitterUser {
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        request.predicate = NSPredicate(format: "screenName = %@", userInfo.screenName)
        do {
            let matches = try context.fetch(request)
            if !matches.isEmpty {
                assert(matches.count == 1, "TwitterUser.findOrCreateTwitterUser --- database inconsistency!")
                return matches.first!
            }
        } catch {
            throw error //rethrows
        }
        
        let twitterUser = TwitterUser(context: context)
        twitterUser.screenName = userInfo.screenName
        twitterUser.name = userInfo.name
        return twitterUser
    }

}
