//
//  HapticManager.swift
//  Stocks
//
//  Created by Raden Dimas on 10/05/22.
//

import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        
        generator.prepare()
        generator.selectionChanged()
        
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    
}
