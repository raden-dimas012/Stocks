//
//  NewsHeaderView.swift
//  Stocks
//
//  Created by Raden Dimas on 10/05/22.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headView: NewsHeaderView)
}

final class NewsHeaderView: UITableViewHeaderFooterView {

   static let identifier = "NewsHeaderView"
   static let preferedHeight: CGFloat = 70
   weak var delegate: NewsHeaderViewDelegate?
    
    struct ViewModel {
        let title: String
        let shoudlShowAddButton: Bool
    }
    
    private let label: UILabel = {
       let label = UILabel()
        
        label.font = .boldSystemFont(ofSize: 32)
        
        return label
    }()
    
    let button: UIButton = {
       let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(label,button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: 14, y: 0, width: contentView.width-28, height: contentView.height)
        button.sizeToFit()
        
        button.frame = CGRect(x: contentView.width - button.width - 16, y: (contentView.height - button.height)/2, width: button.width + 10, height: button.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shoudlShowAddButton
    }
    
    @objc private func didTapButton() {
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
}
