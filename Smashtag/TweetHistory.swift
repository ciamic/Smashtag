//
//  TweetHistory.swift
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

/// TweetHistory keeps track of a certain amount of recent searches using NSUserDefaults as store mechanism.

class TweetHistory {
    
    var count: Int {
        get {
            return history.count
        }
    }
    
    private var defaults = UserDefaults.standard
    private var history: [String] {
        get {
            return defaults.object(forKey: History.HistoryKey) as? [String] ?? []
        }
        set {
            defaults.set(newValue, forKey: History.HistoryKey)
        }
    }
    
    func add(_ searchTerm: String) {
        var recents = history.filter { //remove if already in search history
            return !($0.caseInsensitiveCompare(searchTerm) == .orderedSame)
        }
        
        //exceeding max capacity?
        if !recents.isEmpty && recents.count >= History.MaxNoOfSearches {
            let removed = recents.remove(at: recents.count - 1)
            NotificationCenter.default.post(name: Notification.Name(History.HistoryRemovedNotification),
                                            object: nil,
                                            userInfo: [History.HistoryRemovedNotificationValue:removed])
        }
        
        //eventually add at the top
        recents.insert(searchTerm, at: 0)
        NotificationCenter.default.post(name: Notification.Name(History.HistoryAddedNotification),
                                        object: nil,
                                        userInfo: [History.HistoryAddedNotificationValue:searchTerm])
        history = recents
    }
    
    func remove(at index: Int) -> String {
        //we need to copy and re-assign to history to cause the save in the user defaults
        var newHistory = history
        let removed = newHistory.remove(at: index)
        NotificationCenter.default.post(name: Notification.Name(History.HistoryRemovedNotification),
                                        object: nil,
                                        userInfo: [History.HistoryRemovedNotificationValue:removed])
        history = newHistory
        return removed
    }
    
    func get(at index: Int) -> String {
        return history[index]
    }
    
    func contains(searchTerm: String) -> Bool {
        return history.contains { $0.caseInsensitiveCompare(searchTerm) == .orderedSame }
    }
    
}
