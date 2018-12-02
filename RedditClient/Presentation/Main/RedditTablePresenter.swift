//
//  RedditTablePresenter.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

protocol RedditTablePresenterDelegate {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = posts[indexPath.row].data.title
        return cell
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows() -> Int {
        return posts.count
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
    
}
