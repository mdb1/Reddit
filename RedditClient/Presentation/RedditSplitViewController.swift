//
//  RedditSplitViewController.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

class RedditSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RedditDetailViewController") as! RedditDetailViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = self.vc.view
    }

}

extension RedditSplitViewController: RedditTableVCDelegate {
    
    func startLoading() {
        vc.startLoading()
    }
    
    func endLoading(_ post: RedditPost) {
        vc.endLoading()
        vc.view.backgroundColor = UIColor.white
        vc.setUp(post)
        
        self.showDetailViewController(vc, sender: self)
    }
    
    func cellSelected(post: RedditPost) {
        vc.view.backgroundColor = UIColor.white
        vc.setUp(post)
        
        self.showDetailViewController(vc, sender: self)
    }
}
