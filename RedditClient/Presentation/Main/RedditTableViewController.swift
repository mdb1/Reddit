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
    func startLoading()
    func endLoading()
}

class RedditTableViewController: UITableViewController {
    
    lazy private var presenter = RedditTablePresenter(delegate: self)
    var delegate: RedditTableVCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = false
        
        let item = UIBarButtonItem(title: "Delete all", style: .done, target: self, action: #selector(deleteAll))
        item.tintColor = .orange
        self.navigationItem.rightBarButtonItem = item

        presenter.registerCells(tableView)
        presenter.fetchPosts()
    }
    
    @objc private func deleteAll() {
        let cellsCount = presenter.deleteAll() - 1
        var indexPaths = [IndexPath]()
        if cellsCount >= 0 {
            for i in 0...cellsCount {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            tableView.deleteRows(at: indexPaths, with: .automatic)
            tableView.reloadData()
        }
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return presenter.footer()
    }
    
    @IBAction func refreshAction(_ sender: UIRefreshControl) {
        presenter.fetchPosts()
        sender.endRefreshing()
    }
}

extension RedditTableViewController: RedditTablePresenterDelegate {
    
    func dismissPost(indexPath: IndexPath) {
        presenter.removePost(indexPath)
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.reloadData()
    }
    
    func onFetchingStart() {
        delegate.startLoading()
    }
    
    func onFetchingEnd() {
        tableView.reloadData()
        if let _ = presenter.firstPost() {
            delegate.endLoading()
        } else {
            presenter.fetchPosts()
        }
    }
    
    func displayError(type: Error, showCancel: Bool = false, retryBlock: @escaping () -> Void) {
        print("Error: \(type.localizedDescription)")
    }
    
}
