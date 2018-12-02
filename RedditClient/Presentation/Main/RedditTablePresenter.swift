//
//  RedditTablePresenter.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

protocol RedditTablePresenterDelegate: RedditPostCellDelegate {
    func displayError(type: Error, showCancel: Bool, retryBlock: @escaping () -> Void)
    func onFetchingStart()
    func onFetchingEnd()
}

class RedditTablePresenter {
    
    private let service = RedditService()
    private var delegate: RedditTablePresenterDelegate!
    
    private var posts = [RedditPost]()
    
    convenience init(delegate: RedditTablePresenterDelegate) {
        self.init()
        
        self.delegate = delegate
    }
    
    func fetchPosts() {
        
        delegate.onFetchingStart()
        
        service.get(andReturn: RedditResponse.self) { (result) in
            switch result {
                
            case .error(let e):
                let retryBlock = {
                    self.fetchPosts()
                }
                self.handleError(e, retryBlock: retryBlock)
                
            case .success(let response):
                self.posts = response.data.children
            }
            
            DispatchQueue.main.async {
                self.delegate.onFetchingEnd()
            }
        }
    }
    
    func registerCells(_ tableView: UITableView) {
        tableView.register(UINib(nibName: "RedditPostTableViewCell", bundle: nil), forCellReuseIdentifier: "RedditPostTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RedditPostTableViewCell", for: indexPath) as? RedditPostTableViewCell else {
            return UITableViewCell()
        }
        cell.setUp(posts[indexPath.row], indexPath: indexPath, delegate: delegate)
        
        if let data = posts[indexPath.row].data.preview, let images = data.images, let mainSource = images[0].source {
            let finalString = mainSource.url.replacingOccurrences(of: "amp;", with: "")
            if let url = URL(string: finalString) {
                service.downloadImage(from: url) { (i) in
                    DispatchQueue.main.async {
                        cell.updateImage(i)
                    }
                }
            }
        }
        
        return cell
    }
    
    func heightForRow() -> CGFloat {
        return 140
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows() -> Int {
        return posts.count
    }
    
    func footer() -> UIView? {
        return UIView()
    }
    
    func postAt(_ indexPath: IndexPath) -> RedditPost? {
        if posts.count >= indexPath.row {
            return posts[indexPath.row]
        }
        
        return nil
    }
    
    private func handleError(_ e: Error, retryBlock: @escaping () -> Void) {
        if let error = e as? UserError {
            switch error {
            
            case .defaultError:
                self.delegate.displayError(type: UserError.defaultError, showCancel: false, retryBlock: retryBlock)
                
            case .codableError:
                self.delegate.displayError(type: UserError.codableError, showCancel: false, retryBlock: retryBlock)
            }
        }
    }
    
    func removePost(_ indexPath: IndexPath) {
        posts.remove(at: indexPath.row)
    }
    
    func deleteAll() -> Int {
        let cellsToDelete = posts.count
        posts.removeAll()
        return cellsToDelete
    }
    
    func firstPost() -> RedditPost? {
        if posts.count > 0 {
            return posts[0]
        }
        return nil
    }
}
