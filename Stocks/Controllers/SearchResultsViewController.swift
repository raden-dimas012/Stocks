//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by Raden Dimas on 09/05/22.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    
    func searchResultsViewControllerDidSelect(searchResult: SearchResult)
    
}

class SearchResultsViewController: UIViewController {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var results: [SearchResult] = []
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        table.isHidden = true
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [SearchResult]) {
        
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }

}

extension SearchResultsViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        let data = results[indexPath.row]
        
        content.text = data.displaySymbol
        content.secondaryText = data.description
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = results[indexPath.row]
        delegate?.searchResultsViewControllerDidSelect(searchResult: data)
    }
    
    
}
