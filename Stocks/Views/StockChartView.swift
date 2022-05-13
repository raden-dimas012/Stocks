//
//  StockChartView.swift
//  Stocks
//
//  Created by Raden Dimas on 11/05/22.
//

import UIKit

class StockChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func reset() {
        
    }
    
    public func configure(with viewModel: ViewModel) {
        
    }

}
