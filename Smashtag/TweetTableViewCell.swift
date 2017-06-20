//
//  TweetTableViewCell.swift
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

///A custom UITableViewCell that shows the text of the tweet highliting its #hashtags, @userMentions and urls.

class TweetTableViewCell: UITableViewCell {
    
    // MARK - Model
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var hashtagColor = UIColor.blue
    var urlColor = UIColor.brown
    var userScreenNameColor = UIColor.orange
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // show profile images with rounded corners
        tweetProfileImageView.layer.cornerRadius = tweetProfileImageView.frame.height / 2
        tweetProfileImageView.clipsToBounds = true
    }
    
    // didMoveToSuperview has been overriden in order to call layoutIfNeeded
    // otherwise for some reason the first cells loaded in the tableview would
    // use their estimated row height rather than their automatic dimension 
    // (this problem happens very often as confirmed by searching for it on the web).
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutIfNeeded()
    }
    
    // MARK: - Utility
    
    /// updates the outlets of the cell providing them the informations contained in the model (i.e. the Tweet)
    private func updateUI() {
        // reset any existing tweet information
        resetTweetInformations()
        // load new informations for the tweet
        loadTweetInformations()
    }
    
    /// loads (and shows) tweet informations (if any). In particular:
    /// 1. tweet text
    /// 2. tweet user name
    /// 3. tweet profile image
    /// 4. tweet posted date
    private func loadTweetInformations() {
        loadAttributedText()
        loadScreenName()
        loadProfileImage()
        loadPostedDate()
    }
    
    /// resets (i.e. sets to nil) every outlet referencing tweet informations
    private func resetTweetInformations() {
        tweetProfileImageView?.image = nil
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetCreatedLabel?.text = nil
    }
    
    private func loadAttributedText() {
        guard let tweet = tweet else {
            return
        }
        
        // show a "photo" img for each media in the tweet at the end of its text
        var text = tweet.text
        tweet.media.forEach { _ in
            text +=  " 📷"
        }
        
        //change colors to mentions with an attributed string
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.changeTweetMentionsColors(tweet.hashtags, withColor: hashtagColor)
        attributedText.changeTweetMentionsColors(tweet.urls, withColor: urlColor)
        attributedText.changeTweetMentionsColors(tweet.userMentions, withColor: userScreenNameColor)
        tweetTextLabel?.attributedText = attributedText
    }
    
    private func loadScreenName() {
        guard let tweet = tweet else {
            return
        }
        
        tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
    }
    
    private func loadProfileImage() {
        guard let tweet = tweet else {
            return
        }
        
        //set profile image for posted tweet
        //do not block main thread
        //do not create a memory cycle
        //and be sure that when the closure gets called back we still want its result
        spinner.startAnimating()
        if let profileImageURL = tweet.user.profileImageURL {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    DispatchQueue.main.async { [weak self] in
                        //NOTE: we call self?.tweet?.user.profileImageURL and not tweet.user.profileImageURL
                        //because tweet is a "local" variable (see guard statement above) and hence the
                        //test with profileImageURL would always return true otherwise!
                        if profileImageURL == self?.tweet?.user.profileImageURL {
                            self?.spinner.stopAnimating()
                            self?.tweetProfileImageView?.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    
    private func loadPostedDate() {
        guard let tweet = tweet else {
            return
        }
        
        //show time if post time is < 24 hours, date otherwise
        let formatter = DateFormatter()
        if Date().timeIntervalSince(tweet.created) > 24*60*60 {
            formatter.dateStyle = DateFormatter.Style.short
        } else {
            formatter.timeStyle = DateFormatter.Style.short
        }
        
        tweetCreatedLabel?.text = formatter.string(from: tweet.created)
    }
    
}

private extension NSMutableAttributedString {
    
    // MARK: - NSMutableAttributedString Extension
    
    func changeTweetMentionsColors(_ mentions: [Twitter.Mention], withColor color: UIColor) {
        mentions.forEach{ addAttribute(NSForegroundColorAttributeName, value: color, range: $0.nsrange) }
    }
    
}
