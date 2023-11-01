//
//  ChartManagerUI.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 26.10.2023.
//

import Foundation
import UIKit
import LightweightCharts


final class ChartManagerUI {
    weak var delegate: DetailViewController!
    
    let accentColor = UIColor(red: 0, green: 150/255.0, blue: 136/255.0, alpha: 1)
    
    let tooltipView: TooltipView
    let percentChange: PercentChange
    let rightClickMenu: RightClickMenu
    let alarmIndicator: AlarmIndicator
    
    // For rightClickMenu
    var leadingConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    // For percent
    var bottomConstraintForPercent: NSLayoutConstraint?
    

    
    init(delegate: DetailViewController!) {
        self.delegate = delegate
        
        tooltipView = TooltipView(accentColor: self.accentColor)
        percentChange = PercentChange(color: self.accentColor)
        rightClickMenu = RightClickMenu(color: self.accentColor)
        alarmIndicator = AlarmIndicator(color: self.accentColor)
    }
    
    func setupUI(chart: LightweightCharts) {
        setupChart(chart: chart)
        setupTooltipView()
        setupRightClickMenu()
        setupPercentChange()
        setupConstraints(chart: chart)
    }
    
    private func setupChart(chart: LightweightCharts) {
        delegate.lightWeightChartView.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTooltipView() {
        delegate.lightWeightChartView.addSubview(tooltipView)
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        tooltipView.isHidden = true
    }
    
    private func setupRightClickMenu() {
        delegate.lightWeightChartView.addSubview(rightClickMenu)
        rightClickMenu.translatesAutoresizingMaskIntoConstraints = false
        rightClickMenu.isHidden = true
    }
    
    private func setupPercentChange() {
        delegate.lightWeightChartView.addSubview(percentChange)
        percentChange.translatesAutoresizingMaskIntoConstraints = false
        percentChange.isHidden = true
    }
    
    func setupConstraints(chart: LightweightCharts) {
        // Add NSLayoutConstraint for the chart.
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: delegate.lightWeightChartView.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: delegate.lightWeightChartView.trailingAnchor),
            chart.topAnchor.constraint(equalTo: delegate.lightWeightChartView.topAnchor),
            chart.bottomAnchor.constraint(equalTo: delegate.lightWeightChartView.bottomAnchor)
        ])
        
        // Constraints for tooltipView.
        NSLayoutConstraint.activate([
            tooltipView.leadingAnchor.constraint(equalTo: chart.leadingAnchor),
            tooltipView.trailingAnchor.constraint(equalTo: chart.trailingAnchor),
            tooltipView.topAnchor.constraint(equalTo: chart.topAnchor),
            tooltipView.bottomAnchor.constraint(equalTo: chart.bottomAnchor)
        ])
        
        leadingConstraint = rightClickMenu.leadingAnchor.constraint(equalTo: chart.leadingAnchor)
        bottomConstraint = rightClickMenu.bottomAnchor.constraint(equalTo: chart.topAnchor)
        leadingConstraint?.isActive = true
        bottomConstraint?.isActive = true
        rightClickMenu.widthAnchor.constraint(equalToConstant: 63).isActive = true
        rightClickMenu.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bottomConstraintForPercent = percentChange.bottomAnchor.constraint(equalTo: chart.topAnchor)
        bottomConstraintForPercent?.isActive = true

        delegate.lightWeightChartView.bringSubviewToFront(tooltipView)
        delegate.lightWeightChartView.bringSubviewToFront(rightClickMenu)
    }
}
