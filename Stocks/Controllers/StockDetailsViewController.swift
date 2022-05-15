//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Raden Dimas on 09/05/22.
//

import UIKit
import SafariServices


///

final class StockDetailsViewController: UIViewController {
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
    private var stories: [NewsStory] = []
    
    private var metrics: Metrics?
    
    private let tableView: UITableView = {
      let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        
        
        
      return table
    }()
    
    init(
        symbol: String,
        companyName: String,
        candleStickData: [CandleStick] = []
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        setUpCloseButton()
        setUpTable()
        fetchFinancialData()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        
    }
    
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose))
    }
    
    private func fetchNews() {
        ApiCallerManager.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    
    private func setUpTable() {
        view.addSubviews(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame:
                                            CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
    }
    
    private func fetchFinancialData() {
        
        let group = DispatchGroup()
        
        if candleStickData.isEmpty {
            group.enter()
            
            
            ApiCallerManager.shared.marketData(for: symbol) { [weak self] result in
                
                defer {
                    group.leave()
                }
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleStick
                case .failure(let error):
                    debugPrint(error)
                }
            }
            
        }
        
        group.enter()
        ApiCallerManager.shared.financialMetric(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                debugPrint(error)
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
        
    }
    
    private func renderChart() {
        let headerView = StockDetailHeaderView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: (view.width * 0.7) + 100 ))
        
       
        
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.annualWeekHigh)"))
            viewModels.append(.init(name: "52L High", value: "\(metrics.annualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.annualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.tenDayAverageTradingVolume)"))
          
        }
       
        let change = candleStickData.getPercentage()
        
        headerView.configure(
            chartViewModel: .init(
                data: candleStickData.reversed().map({ $0.close }),
                showLegend: true,
                showAxis: true,
                filledColor: change < 0 ? .systemRed : .systemGreen
            ),
            metricViewModels: viewModels)
        
        tableView.tableHeaderView = headerView
        
        
    }
    
//    private func getChangePercentage(data: [CandleStick]) -> Double {
//        let laterDate = data[0].date
//
//
//        guard let latestClose = data.first?.close,
//            let priorClose = data.first(where: {
//                !Calendar.current.isDate($0.date,inSameDayAs: laterDate)
//            })?.close
//        else { return 0.0 }
//
//        debugPrint("\(symbol)  Current \(laterDate): \(latestClose) | Prior \(priorDate): \(priorClose)")
//
//        let diff = 1 - (priorClose/latestClose)
//
//        debugPrint("\(symbol) : \(diff)%")
//
//        return diff
//    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
}


extension StockDetailsViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        
        cell.configure(with: .init(model: stories[indexPath.row]))
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferedHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier)
                as? NewsHeaderView else {
                    fatalError()
                }
        
        header.delegate = self
        header.configure(with: .init(
            title: symbol.uppercased(),
            shoudlShowAddButton: !PersistenceManager.shared.watchlistContains(symbol: symbol)))
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        
        HapticManager.shared.vibrateForSelection()
        
        let viewController = SFSafariViewController(url: url)
        
        present(viewController, animated: true)
    }
        
}

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headView: NewsHeaderView) {
        headView.button.isHidden = true
        PersistenceManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)
        
        HapticManager.shared.vibrate(for: .success)
        
        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We have added \(companyName) to your watchlist.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

