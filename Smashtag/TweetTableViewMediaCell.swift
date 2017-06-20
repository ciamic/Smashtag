//
//  TweetTableViewMediaCell.swift
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

class TweetTableViewMediaCell: UITableViewCell {
    
    // MARK: - Model
    
    var imageUrl: URL? {
        didSet { updateUI() }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Utils
    
    //fetches an image at the specified url and set the image of the imageView when done.
    fileprivate func updateUI() {
        tweetImage?.image = nil
        if let url = imageUrl {
            spinner?.startAnimating()
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if url == self?.imageUrl {
                        if imageData != nil {
                            self?.tweetImage.image = UIImage(data: imageData!)
                        } else {
                            self?.tweetImage.image = nil
                        }
                        self?.spinner.stopAnimating()
                    }
                }
            }
        }
    }

}
