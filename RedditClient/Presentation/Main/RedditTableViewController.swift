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

        clearsSelectionOnViewWillAppear = false

        presenter.registerCells(tableView)
        presenter.fetchPosts()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter.heightForRow()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return presenter.tableView(tableView, cellForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = presenter.postAt(indexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            delegate.cellSelected(post: post)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension RedditTableViewController: RedditTablePresenterDelegate {
    
    func dismissPost(indexPath: IndexPath) {
        presenter.removePost(indexPath)
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.reloadData()
    }
    
    func onFetchingStart() {
        
    }
    
    func onFetchingEnd() {
        tableView.reloadData()
    }
    
    func displayError(type: Error, showCancel: Bool = false, retryBlock: @escaping () -> Void) {
        print("Error: \(type.localizedDescription)")
    }
    
}
