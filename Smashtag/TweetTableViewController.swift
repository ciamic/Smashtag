//
//  TweetTableViewController.swift
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

///Displays the results of tweet searches in a table and store into the database newly fetched tweets

class TweetTableViewController: UITableViewController {
    
    // MARK: - Model
    
    //an array of array of tweets
    var tweets = [Array<Twitter.Tweet>]()
    
    //the search term
    var searchText: String? {
        didSet {
            searchBar?.text = searchText
            searchBar?.resignFirstResponder()
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }

    // results view and labels
    @IBOutlet var resultsView: UIView!
    @IBOutlet weak var resultsNoSearchLabel: UILabel!
    @IBOutlet weak var resultsNoResultsLabel: UILabel!
    @IBOutlet weak var resultsErrorOccurredLabel: UILabel!
    
    // MARK: - Private Properties
    
    fileprivate var twitterRequest: Twitter.Request? {
        if var query = searchText, !query.isEmpty { //not nil and not empty
            if query.hasPrefix(TwitterConstants.UserPrefix) { //search for tweets that mentions the user or are posted by the user
                query = "\(query) \(TwitterConstants.OrFromSearchKeyword) \(query)"
            } else { //search for the hashtag but no retweets
                query = query + TwitterConstants.NoRetweetsFilter
            }
            return Twitter.Request(search: query, count: TwitterConstants.NoOfTweetsPerRequest)
        }
        return nil
    }
    
    fileprivate weak var showImagesBarButtonItem: UIBarButtonItem?
    fileprivate weak var showTweetersBarButtonItem: UIBarButtonItem?
    fileprivate let loadingSpinner = UIActivityIndicatorView()
    
    // MARK: - Properties
    
    //keeps track of the last request in order to avoid to make some requests that take
    //very long time to complete and show up after a while when the user searched for something else
    fileprivate var lastTwitterRequest: Twitter.Request?
    
    // MARK: - Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRightBarButtonItems()
        setupLoadingSpinner()
        updateVisibilityForBarButtonItems()
        if isFirstNavigationController() {
            //removes unwind button for the first nav controller
            navigationItem.rightBarButtonItems?.removeFirst()
        }
    }
    
    private func setupLoadingSpinner() {
        loadingSpinner.activityIndicatorViewStyle = .whiteLarge
        loadingSpinner.color = UIColor.darkGray
        loadingSpinner.hidesWhenStopped = true
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        if tweets.isEmpty {
            updateTableViewResultsView(with: .EmptySearch)
        }
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //gets and stores references to ShowImages and ShowTweeters bar button items
    fileprivate func setupRightBarButtonItems() {
        if let rightBarButtonItems = navigationItem.rightBarButtonItems {
            for button in rightBarButtonItems {
                switch button.tag {
                case Storyboard.ShowImagesBarButtonTag:
                    showImagesBarButtonItem = button
                case Storyboard.ShowTweetersBarButtonTag:
                    showTweetersBarButtonItem = button
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func isFirstNavigationController() -> Bool {
        return self == navigationController?.viewControllers.first
    }
    
    // MARK: - Actions
    
    @IBAction func refreshControlValueChanged(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    @IBAction func unwindToRoot(_ sender: UIStoryboardSegue) {
        //unwind destination
    }
    
    @IBAction func tweetMediaItemsButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Storyboard.ShowTweetsCollectionView, sender: sender)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == Storyboard.ShowMentionsSegue {
            if let tweetCell = sender as? TweetTableViewCell {
                if let tweet = tweetCell.tweet {
                    if !tweetHasMentions(tweet) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowMentionsSegue:
                if let tmtvc = segue.destination as? TweetMentionsTableViewController {
                    if let tweetCell = sender as? TweetTableViewCell {
                        tmtvc.tweet = tweetCell.tweet
                    }
                }
            case Storyboard.ShowTweetsCollectionView:
                if let tcvc = segue.destination as? TweetCollectionViewController {
                    tcvc.tweets = tweets
                }
            default:
                break
            }
        }
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        //skip all the controllers and stops at the root one
        if isFirstNavigationController() {
            return true
        }
        return false
    }
    
    // MARK: - Utils
    
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        tweets.insert(newTweets, at: 0)
        tableView.insertSections([0], with: .fade)
    }
    
    /// called before searching for tweets in order to fire up activity indicators
    private func startRefreshing() {
        tableView.separatorStyle = .none
        tableView.backgroundView = loadingSpinner
        loadingSpinner.startAnimating()
        // NOTE: no need to call refreshControl.beginRefreshing
        // but need to stop it when the refreshing ends.
    }
    
    /// called after seaching for tweets in order to stop activity indicators
    private func endRefreshing(errorHasOccurred: Bool) {
        loadingSpinner.stopAnimating()
        refreshControl?.endRefreshing()
        if searchText == nil || (searchText != nil && searchText!.isEmpty) {
            updateTableViewResultsView(with: .EmptySearch)
        } else if errorHasOccurred {
            updateTableViewResultsView(with: .SearchWithError)
        } else {
            updateTableViewResultsView(with: .SuccessfulSearch)
        }
    }
    
    // Reasons for updating the table view
    fileprivate enum TableViewUpdateReason {
        case EmptySearch
        case SearchWithError
        case SuccessfulSearch
    }
    
    private func updateTableViewResultsView(with reason: TableViewUpdateReason) {
        resultsNoSearchLabel.isHidden = true
        resultsNoResultsLabel.isHidden = true
        resultsErrorOccurredLabel.isHidden = true
        tableView.backgroundView = resultsView
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        switch reason {
        case .EmptySearch:
            resultsNoSearchLabel.isHidden = false
        case .SearchWithError:
            resultsErrorOccurredLabel.isHidden = false
        case .SuccessfulSearch:
            if tweets.isEmpty {
                resultsNoResultsLabel.isHidden = false
            } else {
                tableView.separatorStyle = .singleLine
                tableView.isScrollEnabled = true
                tableView.backgroundView = nil
            }
        }
    }
    
    private func requestForTweets() -> Request? {
        if searchText != nil && !TweetHistory().contains(searchTerm: searchText!) {
            return twitterRequest
        } else {
            return lastTwitterRequest?.newer ?? twitterRequest
        }
    }
    
    //note that this function resolves two of the most common problems with asynchronous requests:
    //1) memory cycle: we use weak self in order to not have a strong reference to self that keeps it in the heap.
    //When this can happen? For example if the network request goes off to the internet and the closure never gets
    //executed for some reason (i.e. failure), and the user moves on onto a new controller and this needs to leave the
    //heap. This will not happen if there is a strong pointer to the controller! Weak self resolves this memory cycle.
    //2) the "world" can be changed when the callback closure comes back so we have to make sure that the content
    //is still "fresh". In this case, that the last request is still the request that caused this closure to get
    //called. See also the lastTwitterRequest property.
    fileprivate func searchForTweets() {
        if let request = requestForTweets() {
            lastTwitterRequest = request
            startRefreshing()
            request.fetchTweets { [weak self] newTweets, error in
                DispatchQueue.main.async {
                    if let error = error {
                        switch error {
                        case TwitterAccountError.noAccountsAvailable,
                             TwitterAccountError.noPermissionGranted:
                            let alertController = UIAlertController(title: AlertControllerMessages.Error,
                                                                    message: AlertControllerMessages.NoAccountsAvailableOrNoPermissionGranted,
                                                                    preferredStyle: .alert)
                            let goToSettings = UIAlertAction(title: AlertControllerMessages.Settings, style: .default) { alertAction in
                                UIApplication.shared.open(URL(string: AlertControllerMessages.UrlToTwitterSettings)!)
                            }
                            let cancel = UIAlertAction(title: AlertControllerMessages.Cancel, style: .cancel, handler: nil)
                            alertController.addAction(goToSettings)
                            alertController.addAction(cancel)
                            
                            self?.present(alertController, animated: true, completion: nil)
                        default:
                            debugPrint(error.localizedDescription)
                        }
                    } else {
                        if request == self?.lastTwitterRequest {
                            if let searchText = self?.searchText, searchText.characters.count > 0 {
                                TweetHistory().add(searchText)
                            }
                            if !newTweets.isEmpty {
                                self?.insertTweets(newTweets)
                            }
                        }
                    }
                    self?.endRefreshing(errorHasOccurred: error != nil)
                    self?.updateVisibilityForBarButtonItems()
                }
            }
        } else {
            endRefreshing(errorHasOccurred: true)
        }
    }
    
    ///Returns true iff the tweet has at least one mention item
    fileprivate func tweetHasMentions(_ tweet: Twitter.Tweet) -> Bool {
        return tweet.hashtags.count + tweet.urls.count + tweet.userMentions.count + tweet.media.count > 0
    }
    
    ///Returns true iff the tweet has at least one media item
    fileprivate func tweetHasMedias(_ tweet: Twitter.Tweet) -> Bool {
        return tweet.media.count > 0
    }
    
    fileprivate func updateVisibilityForBarButtonItems() {
        showImagesBarButtonItem?.isEnabled = false
        showTweetersBarButtonItem?.isEnabled = false
        if tweets.count > 0 {
            showTweetersBarButtonItem?.isEnabled = true
            tweets.forEach {
                $0.forEach {
                    if tweetHasMedias($0) {
                        showImagesBarButtonItem?.isEnabled = true
                        return
                    }
                }
            }
        }
    }
    
}

extension TweetTableViewController {
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier, for: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
            cell.accessoryType = tweetHasMentions(tweet) ? .disclosureIndicator : .none
        }
     
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return tweetHasMentions(tweets[indexPath.section][indexPath.row])
    }
    
}

extension TweetTableViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBarDelegate
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text
    }
    
}
