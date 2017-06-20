//
//  TweetMentionsTableViewController.swift
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
import Twitter
import SafariServices

///Shows in a table view with opportune sections the mentions that appears in a Tweet.

class TweetMentionsTableViewController: UITableViewController {
    
    // MARK: - Model
    
    var tweet: Twitter.Tweet? {
        //whenever a new tweet is set the mentions struct is filled with the info extracted from the tweet
        didSet {
            title = tweet?.user.screenName ?? ""
            mentions.removeAll()
            fillMentions()
        }
    }
    
    // MARK: - Data Structure (Mentions and MentionItem)
    
    //There is one Mentions struct for each "category" and each has a reference to an array of MentionItem
    //The items have different data attached based on their type (i.e. Keyword or Image)
    struct Mentions: CustomStringConvertible {
        var title: String
        var data: [MentionItem]
        var description: String { return "\(title) - \(data)" }
    }
    
    enum MentionItem: CustomStringConvertible {
        case keyword(String)
        case image(URL, Double)
        var description: String {
            switch self {
            case .keyword(let mention): return mention
            case .image(let url, _): return url.path 
            }
        }
    }
    
    // MARK: - Properties
    
    fileprivate var mentions: [Mentions] = []
    
    // MARK: - Utility
    
    private func fillMentions() {
        fillMediaItems()
        fillUrls()
        fillHashtags()
        fillUsers()
    }
    
    private func fillMediaItems() {
        guard let tweet = tweet, tweet.media.count > 0 else {
            return
        }
        
        //fill media items
        var imagesData = [MentionItem]()
        tweet.media.forEach { imagesData.append(MentionItem.image($0.url, $0.aspectRatio)) }
        mentions.append(Mentions(title: MentionsCategoryNames.MediaMentions, data: imagesData))
    }
    
    private func fillUrls() {
        guard let tweet = tweet, tweet.urls.count > 0 else {
            return
        }
        
        //fill urls
        var urlsData = [MentionItem]()
        tweet.urls.forEach { urlsData.append(MentionItem.keyword($0.keyword)) }
        mentions.append(Mentions(title: MentionsCategoryNames.URLMentions, data: urlsData))
    }
    
    private func fillHashtags() {
        guard let tweet = tweet, tweet.hashtags.count > 0 else {
            return
        }
        
        //fill hashtags
        var hashtagsData = [MentionItem]()
        tweet.hashtags.forEach { hashtagsData.append(MentionItem.keyword($0.keyword)) }
        mentions.append(Mentions(title: MentionsCategoryNames.HashtagMentions, data: hashtagsData))
    }
    
    private func fillUsers() {
        guard let tweet = tweet else {
            return
        }
        
        //fill users (including the user who posted as first)
        var userMentionsData = [MentionItem]()
        userMentionsData.append(MentionItem.keyword(TwitterConstants.UserPrefix + tweet.user.screenName))
        tweet.userMentions.forEach { userMentionsData.append(MentionItem.keyword($0.keyword)) }
        mentions.append(Mentions(title: MentionsCategoryNames.UserMention, data: userMentionsData))
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.ShowTweetsSegue {
                if let ttvc = segue.destination as? TweetTableViewController {
                    if let cell = sender as? UITableViewCell {
                        ttvc.searchText = cell.textLabel?.text //this will trigger a new search
                    }
                }
            } else if identifier == Storyboard.ShowTweetImageIdentifier {
                if let tivc = segue.destination as? TweetImageViewController {
                    if let cell = sender as? TweetTableViewMediaCell {
                        tivc.imageURL = cell.imageUrl //set the url
                        tivc.image = cell.tweetImage?.image //but also give the already downladed image
                        tivc.title = title
                    }
                }
            }
        }
    }
    
    //if the cell is a valid url, we open it in a SafariViewController,
    //otherwise we perform the segue to another view controller.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == Storyboard.ShowTweetsSegue {
            if let cell = sender as? UITableViewCell {
                if let url = cell.textLabel?.text, url.hasPrefix(Constants.HttpPrefix) {
                    if let nsurl = URL(string: url) {
                        let svc = SFSafariViewController(url: nsurl, entersReaderIfAvailable: true)
                        present(svc, animated: true, completion: nil)
                        return false
                    }
                }
            }
        }
        return true
    }
    
}

extension TweetMentionsTableViewController {
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentions.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .keyword(let keyword):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MentionCellIdentifier, for: indexPath)
            cell.textLabel?.text = keyword
            return cell
        case .image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MediaCellIdentifier, for: indexPath) as! TweetTableViewMediaCell
            cell.imageUrl = url
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .image(_, let ratio):
            //preserve aspect ratio and use all of the tableView width
            return tableView.bounds.size.width / CGFloat(ratio)
        case .keyword(_):
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
    }
    
}
