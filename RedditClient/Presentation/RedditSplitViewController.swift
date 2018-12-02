//
//  RedditSplitViewController.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

class RedditSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension RedditSplitViewController: RedditTableVCDelegate {
    func cellSelected(post: RedditPost) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RedditDetailViewController") as! RedditDetailViewController
        vc.view.backgroundColor = UIColor.white
        vc.setUp(post)
        
        // Determines that the post has been read
        UserDefaults.standard.set(true, forKey: post.data.id)
        
        self.showDetailViewController(vc, sender: self)
    }
}
