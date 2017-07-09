//
//  Constants.swift
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

//Constants, types and identifiers utilized throughout the whole Smashtag project.

struct Storyboard {
    static let TweetCellIdentifier = "Tweet"
    static let ShowMentionsSegue = "ShowMentions"
    static let MentionCellIdentifier = "Mention"
    static let MediaCellIdentifier = "Media"
    static let ShowTweetsSegue = "ShowTweets"
    static let ShowTweetImageIdentifier = "ShowTweetImage"
    static let TweetHistoryCellIdentifier = "TweetHistory"
    static let ShowTweetsCollectionView = "ShowTweetsCollectionView"
    static let TweetCollectionViewCellIdentifier = "TweetCollectionViewCell"
    static let ShowTweetSegue = "ShowTweet"
    static let ShowTweetersTableView = "ShowTweetersMentioningSearchTerm"
    static let TwitterUserCellIdentifier = "TwitterUserCell"
    static let ShowMentionsPopularitySegue = "ShowMentionsPopularity"
    static let TwitterMentionCellIdentifier = "TwitterMentionCell"
    static let ShowImagesBarButtonTag = 0
    static let ShowTweetersBarButtonTag = 1
    static let TweetersTableViewControllerIdentifier = "TweetersTableViewControllerIdentifier"
    static let ShowTweetFromMentions = "ShowTweetFromMentions"
}

struct TwitterConstants {
    static let NoRetweetsFilter = " -filter:retweets"
    static let NoOfTweetsPerRequest = 100
    static let UserPrefix = "@"
    static let OrFromSearchKeyword = "OR from:"
}

struct MentionsCategoryNames {
    static let MediaMentions = "Images"
    static let URLMentions = "URLs"
    static let HashtagMentions = "Hashtags"
    static let UserMention = "Users"
}

struct Constants {
    static let HttpPrefix = "http"
}

struct History {
    static let HistoryKey = "TweetHistory.History"
    static let MaxNoOfSearches = 3
    static let HistoryRemovedNotification = "TweetHistory.RemovedNotification"
    static let HistoryAddedNotification = "TweetHistory.AddedNotification"
    static let HistoryRemovedNotificationValue = "TweetHistory.RemovedNotificationValue"
    static let HistoryAddedNotificationValue = "TweetHistory.AddedNotificationValue"
}

struct CoreData {
    static let TweetEntity = "Tweet"
    static let TwitterUserEntity = "TwitterUser"
    static let MentionEntity = "Mention"
    static let MentionedInTweetRelationship = "mentionedInTweet"
}

enum CoreDataMentionType: String {
    case UserMention = "User Mention"
    case Hashtag = "Hashtag Mention"
}

struct ManagedDocument {
    static let DefaultDatabaseName = "Default Tweet Database"
}

struct AlertControllerMessages {
    static let Error = "Error"
    static let Cancel = "Cancel"
    static let Settings = "Settings"
    static let UrlToTwitterSettings = "App-Prefs:root=TWITTER"
    static let NoAccountsAvailableOrNoPermissionGranted = "No Twitter accounts available or no permission granted to access accounts informations. Please consider associating a new account or granting permissions for the existing ones."
}
