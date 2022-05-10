//
//  ViewController.swift
//  Stocks
//
//  Created by Raden Dimas on 03/04/22.
//

import UIKit





class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTitleView()
        
    }
    
    // Child Controller Implementation
//    private func setUpChild() {
//        let panelViewController = PanelViewController()
//
//        addChild(panelViewController)
//
//        view.addSubview(panelViewController.view)
//
//        panelViewController.view.frame = CGRect(x: 0, y: view.height / 2, width: view.width, height: view.height)
//
//
//
//        panelViewController.didMove(toParent: self)
//    }
    
    private func setUpTitleView() {
        let titleView = UIView(
            frame:CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: navigationController?.navigationBar.height ?? 100))
    
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width-20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    
    private func setUpSearchController() {
        let resultViewController = SearchResultsViewController()
        resultViewController.delegate = self
        let searchViewController = UISearchController(searchResultsController: resultViewController)
        searchViewController.searchResultsUpdater = self
        navigationItem.searchController = searchViewController
    }
}

extension WatchListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsViewController = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
//        debugPrint(query)
        
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            ApiCallerManager.shared.search(query: query) { result in
                switch result {
                case .success(let response):
    //                debugPrint(response.result)
                    DispatchQueue.main.async {
                        resultsViewController.update(with: response.result)
                    }
                case .failure(let error):
                    debugPrint(error)
                    DispatchQueue.main.async {
                        resultsViewController.update(with: [])
                    }
                }
            }
        })
        
        
                
    }
}

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
//        debugPrint("Did select: \(searchResult.displaySymbol)")
        
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        let detailViewController = StockDetailsViewController()
        let navViewController = UINavigationController(rootViewController: detailViewController)
        
        detailViewController.title = searchResult.description
        
        present(navViewController, animated: true, completion: nil)
    }
    
}

