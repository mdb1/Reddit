//
//  RedditPostTableViewCell.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

protocol RedditPostCellDelegate {
    func dismissPost(indexPath: IndexPath)
}

class RedditPostTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var readStatusView: UIView!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var hoursAgoLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var postTitleLabel: UILabel!
    @IBOutlet private weak var commentsLabel: UILabel!
    
    private var post: RedditPost?
    private var indexPath: IndexPath!
    private var delegate: RedditPostCellDelegate!
    private var service = RedditService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func dismissTouched(_ sender: Any) {
        delegate.dismissPost(indexPath: indexPath)
    }
    
    func setUp(_ post: RedditPost, indexPath: IndexPath, delegate: RedditPostCellDelegate) {
        self.post = post
        self.indexPath = indexPath
        self.delegate = delegate
        
        updateStatus()
        
        authorLabel.text = post.data.author_fullname
        //hoursAgoLabel.text = post.data. TODO
        
        postTitleLabel.text = post.data.title
        commentsLabel.text = "\(post.data.num_comments) comments"
    }
    
    private func updateStatus() {
        if let p = self.post {
            let postRead: Bool = UserDefaults.standard.value(forKey: p.data.id) as? Bool ?? false
            readStatusView.isHidden = postRead
        }
    }
    
    func updateImage(_ image: UIImage?) {
        if let i = image {
            postImageView.image = i
        } else {
            postImageView.image = UIImage(named: "noImage")
        }
    }
    
}
