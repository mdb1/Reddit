//
//  RedditDetailViewController.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

class RedditDetailViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var downloadImageButton: UIButton!
    @IBOutlet private weak var loadingView: UIView!
    
    private var service = RedditService()
    private var post: RedditPost?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    @objc private func imageTapped(gesture: UITapGestureRecognizer) {
        if let data = post?.data.preview, let images = data.images, let mainSource = images[0].resolutions {
            
            let maxResolutionIndex = mainSource.count - 1
            let maxResolutionURL = mainSource[maxResolutionIndex]
            
            let finalString = maxResolutionURL.url.replacingOccurrences(of: "amp;", with: "")
            if let url = URL(string: finalString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func setUp(_ post: RedditPost) {
        self.post = post
        
        // Determines that the post has been read
        UserDefaults.standard.set(true, forKey: post.data.id)

        titleLabel.text = post.data.title
        usernameLabel.text = post.data.author_fullname
        
        if let data = post.data.preview, let images = data.images, let mainSource = images[0].source {
            let finalString = mainSource.url.replacingOccurrences(of: "amp;", with: "")
            if let url = URL(string: finalString) {
                service.downloadImage(from: url) { (i) in
                    DispatchQueue.main.async {
                        if let i = i {
                            self.imageView.image = i
                        } else {
                            self.imageView.image = UIImage(named: "noImage")
                            self.downloadImageButton.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    func startLoading() {
        loadingView.isHidden = false
    }
    
    func endLoading() {
        loadingView.isHidden = true
    }

    @IBAction private func downloadImageTapped(_ sender: UIButton) {
        sender.setTitle("Downloading...", for: .normal)
        
        if let data = post?.data.preview, let images = data.images, let mainSource = images[0].resolutions {
            
            let maxResolutionIndex = mainSource.count - 1
            let maxResolutionURL = mainSource[maxResolutionIndex]
            
            let finalString = maxResolutionURL.url.replacingOccurrences(of: "amp;", with: "")
            if let url = URL(string: finalString) {
                service.downloadImage(from: url) { (i) in
                    DispatchQueue.main.async {
                        if let i = i {
                            self.download(i)
                        }
                    }
                }
            }
        }
    }
    
    func download(_ i: UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            i,
            self,
            #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    // MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let feedbackMessage = (error != nil)
            ? "Error downloading the photo"
            : "Saved to the library"
        downloadImageButton.setTitle(feedbackMessage, for: .normal)
        downloadImageButton.isEnabled = false
    }
}
