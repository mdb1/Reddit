//
//  RedditTableViewController.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

protocol RedditTableVCDelegate {
    func cellSelected(post: RedditPost)
}

class RedditTableViewController: UITableViewController {
    
    lazy private var presenter = RedditTablePresenter(delegate: self)
    var delegate: RedditTableVCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.fetchPosts()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        return presenter.tableView(tableView, cellForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = presenter.postAt(indexPath) {
            delegate.cellSelected(post: post)
        }
    }
}

extension RedditTableViewController: RedditTablePresenterDelegate {
    
    func onFetchingStart() {
        
    }
    
    func onFetchingEnd() {
        tableView.reloadData()
    }
    
    func displayError(type: Error, showCancel: Bool = false, retryBlock: @escaping () -> Void) {
        print("Error: \(type.localizedDescription)")
    }
    
}
