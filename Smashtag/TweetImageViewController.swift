//
//  TweetImageViewController.swift
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
import UIKit

///This ViewController is mostly reused from the Cassini project.

class TweetImageViewController: UIViewController {
    
    // MARK: - Model
    
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { //postpone image fetching if we are not on screen yet
                fetchImage()
            }
        }
    }
    
    // we set this with "internal" accessibility level (was private in Cassini project)
    // so that if we already have the downloaded image we can set it during prepare for segue
    // to avoid to re-download it.
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
            scrollViewHasBeenScrolledOrZoomed = false
            scale()
            centerImageInScrollView()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.5
            scrollView.maximumZoomScale = 1.5
            scrollView.addSubview(imageView)
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    // MARK: - Properties
    
    fileprivate var imageView = UIImageView()
    
    fileprivate var scrollViewHasBeenScrolledOrZoomed = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        imageView.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil { // we are going on screen so if necessary
            fetchImage()  // fetch the image
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scale()
        centerImageInScrollView()
    }
    
    fileprivate func fetchImage() {
        if let url = imageURL {
            // fire up the spinner we're about to execute something on another thread
            spinner?.startAnimating()
            // put a closure on the "user initiated" system queue
            // this closure calls NSData(contentsOfURL:) which blocks
            // waiting for network response
            // it's fine for it to block the "user initiated" queue
            // because that's a concurrent queue
            // (so other closures on that queue can run concurrently even as this one's blocked)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url) // blocks! can't be on main queue!
                // now that we got the data from the network
                // we want to put it up in the UI
                // but we can only do that on the main queue
                // so we queue up a closure here to do that
                DispatchQueue.main.async { [weak self] in
                    // since it could take a long time to fetch the image data
                    // we make sure here that the image we fetched
                    // is still the one this ViewController wants to display
                    // and the controller (i.e. self) is still "alive"!
                    if url == self?.imageURL {
                        if let imageData = contentsOfURL {
                            self?.image = UIImage(data: imageData)
                            // setting the image will stop the spinner animating
                        } else {
                            self?.spinner?.stopAnimating()
                        }
                    } else {
                        // just to see in the console when this happens
                        debugPrint("ignored data returned from url \(url)")
                    }
                }
            }
        }
    }
    
    // MARK: - Utility
    
    fileprivate func scale() {
        guard scrollView != nil, !scrollViewHasBeenScrolledOrZoomed,
            imageView.bounds.size.width > 0, imageView.bounds.size.height > 0 else {
            return
        }
        
        let widthScale = scrollView.bounds.size.width / imageView.bounds.size.width
        let heightScale = scrollView.bounds.size.height / imageView.bounds.size.height
        let minZoomScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minZoomScale
        scrollView.zoomScale = minZoomScale
        scrollView.maximumZoomScale = minZoomScale > 1 ? minZoomScale * 2 : 2
    }
    
    fileprivate func centerImageInScrollView() {
        guard scrollView != nil else {
            return
        }
        
        var imageViewContentsFrame = imageView.frame
        
        //UIView.animate(withDuration: 0.25) {
            if imageViewContentsFrame.size.width < self.scrollView.bounds.size.width {
                imageViewContentsFrame.origin.x = (self.scrollView.bounds.size.width - imageViewContentsFrame.size.width) / 2.0
            } else {
                imageViewContentsFrame.origin.x = 0.0
            }
            
            if imageViewContentsFrame.size.height < self.scrollView.bounds.size.height {
                imageViewContentsFrame.origin.y = (self.scrollView.bounds.size.height - imageViewContentsFrame.size.height) / 2.0
            } else {
                imageViewContentsFrame.origin.y = 0.0
            }
            
            self.imageView.frame = imageViewContentsFrame
        //}
    }
    
}

extension TweetImageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewHasBeenScrolledOrZoomed = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewHasBeenScrolledOrZoomed = true
        centerImageInScrollView()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
