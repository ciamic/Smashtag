//
//  TweetCollectionViewController.swift
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

/// A CollectionView controller that shows all of the media items in the given tweets.
/// It also uses a (local, only for this controller) cache to store and avoid re-download of the same images.

class TweetCollectionViewController: UICollectionViewController {
    
    // MARK: - Model
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            //we use the same "trick" as TweetMentionsTableViewController:
            //the model is an array of array of tweets but as soon as this is set
            //we store all the info in a more convenient structure for this controller.
            tweets.forEach { tweetArray in //for each outer array
                tweetArray.forEach { tweet in //for each tweet in inner array
                    tweet.media.forEach { media in //for each media item in the tweet
                        let tweetImage = TweetImage(tweet: tweet, media: media)
                        tweetsImages.append(tweetImage)
                    }
                }
            }
        }
    }
    
    // MARK: - Properties
    
    //the cache for the images does not survive outside of this controller
    fileprivate let cache = NSCache<AnyObject, AnyObject>()
    
    private var _scale: CGFloat = 1.0
    fileprivate var scale: CGFloat {
        get {
            return _scale
        }
        set {
            if newValue >= ScaleValues.MinScale, newValue <= ScaleValues.MaxScale {
                _scale = newValue
            }
        }
    }
    
    private var lastIndexPath: IndexPath? = nil
    
    // MARK: - Private Structure
    
    fileprivate var tweetsImages = [TweetImage]()
    
    // we store each media and the tweet that contains the media itself
    struct TweetImage {
        let tweet: Twitter.Tweet
        let media: Twitter.MediaItem
    }
    
    fileprivate struct ScaleValues {
        static let MinScale: CGFloat = 0.5
        static let MaxScale: CGFloat = 2.0
    }
    
    // MARK: - Outlets
    
    @IBOutlet var tweetCollectionView: UICollectionView!
    fileprivate let pinchGestureRecognizer = UIPinchGestureRecognizer()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinchGestureRecognizer.addTarget(self, action: #selector(pinchRecognized(_:)))
        collectionView?.addGestureRecognizer(pinchGestureRecognizer)
        collectionView?.backgroundView?.backgroundColor = UIColor.clear
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let collectionView = collectionView {
            lastIndexPath = collectionView.indexPathsForVisibleItems.first
            collectionView.indexPathsForVisibleItems.forEach {
                if $0.row < lastIndexPath!.row {
                    lastIndexPath = $0
                }
            }
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if lastIndexPath != nil {
            collectionView?.scrollToItem(at: lastIndexPath!, at: .top, animated: false)
            lastIndexPath = nil
        }
    }
    
    // MARK: - Utility
    
    @objc private func pinchRecognized(_ pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            pinch.scale = scale
        case .changed:
            scale = pinch.scale
            collectionView?.collectionViewLayout.invalidateLayout()
        default:
            break
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.ShowTweetSegue {
                if let ttvc = segue.destination as? TweetTableViewController {
                    if let cell = sender as? TweetCollectionViewCell {
                        if let indexPath = collectionView?.indexPath(for: cell) {
                            ttvc.tweets = [[tweetsImages[indexPath.row].tweet]]
                            ttvc.title = tweetsImages[indexPath.row].tweet.user.screenName
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource and UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.TweetCollectionViewCellIdentifier, for: indexPath) as! TweetCollectionViewCell
        cell.cache = cache
        cell.imageUrl = tweetsImages[indexPath.row].media.url
        
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweetsImages.count
    }
    
}

extension TweetCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width * scale / ScaleValues.MaxScale
        let ratio = tweetsImages[indexPath.row].media.aspectRatio
        let height = width / CGFloat(ratio)
        return CGSize(width: width, height: height)
    }
    
}
