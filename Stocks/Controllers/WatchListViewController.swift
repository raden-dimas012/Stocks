//
//  ViewController.swift
//  Stocks
//
//  Created by Raden Dimas on 03/04/22.
//

import UIKit
import FloatingPanel

final class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    
    private var panel: FloatingPanelController?
    
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    static var maxChangedWidth: CGFloat = 0
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return table
    }()
    
    private var observer: NSObjectProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        fetchWatchListData()
        setUpTitleView()
        setUpFloatingPanel()
        setUpObserver()
        
    }
    
    override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
    }
    
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main,
            using: { [weak self]_ in
                self?.viewModels.removeAll()
                self?.fetchWatchListData()
            })
    }
    
    private func fetchWatchListData() {
        let symbols = PersistenceManager.shared.watchlist
        
        let group = DispatchGroup()
        
    
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            ApiCallerManager.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleStick = data.candleStick
                    self?.watchlistMap[symbol] = candleStick
                case .failure(let error):
                    debugPrint(error)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    private func createViewModels() {
        
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(symbol: symbol,data: candleSticks)
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: .percentage(from: changePercentage),
                    chartViewModel: .init(data: candleSticks.reversed().map({ $0.close }), showLegend: false, showAxis: false))
            )
        }
        
//        debugPrint("\(viewModels)")
        
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(symbol: String,data: [CandleStick]) -> Double {
        let laterDate = data[0].date
        
        
        guard let latestClose = data.first?.close,
            let priorClose = data.first(where: {
                !Calendar.current.isDate($0.date,inSameDayAs: laterDate)
            })?.close
        else { return 0.0 }
        
//        debugPrint("\(symbol)  Current \(laterDate): \(latestClose) | Prior \(priorDate): \(priorClose)")
        
        let diff = 1 - (priorClose/latestClose)
        
//        debugPrint("\(symbol) : \(diff)%")
        
        return diff
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        
        return .formatted(number: closingPrice)
      
    }
    
    private func setUpTableView() {
        view.addSubviews(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    
    private func setUpFloatingPanel() {
        let panelViewController = FloatingPanelController()
        let contentViewController = NewsViewController(type: .topStories)
        panelViewController.surfaceView.backgroundColor = .secondarySystemBackground
        panelViewController.set(contentViewController: contentViewController)
        panelViewController.addPanel(toParent: self)
        panelViewController.delegate = self
        panelViewController.track(scrollView: contentViewController.tableView)
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
        
        let detailViewController = StockDetailsViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description)
            
        let navViewController = UINavigationController(rootViewController: detailViewController)
        
        detailViewController.title = searchResult.description
        
        present(navViewController, animated: true, completion: nil)
    }
    
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
    
}

extension WatchListViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WatchListTableViewCell.identifier,
            for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferedHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            PersistenceManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            
            viewModels.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = viewModels[indexPath.row]
        
        let viewController = StockDetailsViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchlistMap[viewModel.symbol] ?? [])
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        
        present(navigationViewController, animated: true, completion: nil)
        
    }
    

}

extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdateMaxWidth() {
        tableView.reloadData()
    }
}

