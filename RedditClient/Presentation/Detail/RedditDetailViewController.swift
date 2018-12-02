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
    
    private var service = RedditService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func setUp(_ post: RedditPost) {
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
                        }
                    }
                }
            }
        }
    }

}
