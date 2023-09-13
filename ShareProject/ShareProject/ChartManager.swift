////
////  ChartManager.swift
////  ShareProject
////
////  Created by Ilia Ilia on 11.09.2023.
////
//
//import Foundation
//import LightweightCharts
//
//class ChartManager: WebSocketManagerDelegate {
//    private var chart: LightweightCharts!
//    private var series: CandlestickSeries!
//
//    var webSocketManager = WebSocketManager()
//    var detailVC = DetailViewController()
//
//    var openPrice: Double?
//    var highPrice: Double?
//    var lowPrice: Double?
//    var closePrice: Double?
//        
//    func startManager() {
//        let delegate = WebSocketManager()
//        delegate.delegate = self
//    }
//
//
//
//    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
//        closePrice = Double(candleModel.closePrice)
//        openPrice = Double(candleModel.openPrice)
//        highPrice = Double(candleModel.highPrice)
//        lowPrice = Double(candleModel.lowPrice)
//        print(closePrice)
//        setupData()
//    }
//
//    func setupChart() {
//
//        let options = ChartOptions(
//            layout: LayoutOptions(background: .solid(color: "#000000"), textColor: "rgba(255, 255, 255, 0.9)"),
//            rightPriceScale: VisiblePriceScaleOptions(borderColor: "rgba(197, 203, 206, 0.8)"),
//            timeScale: TimeScaleOptions(borderColor: "rgba(197, 203, 206, 0.8)"),
//            crosshair: CrosshairOptions(mode: .normal),
//            grid: GridOptions(
//                verticalLines: GridLineOptions(color: "rgba(197, 203, 206, 0.5)"),
//                horizontalLines: GridLineOptions(color: "rgba(197, 203, 206, 0.5)")
//            )
//        )
//        let chart = LightweightCharts(options: options)
//
//
////        view.addSubview(chart)
////        chart.translatesAutoresizingMaskIntoConstraints = false
////        NSLayoutConstraint.activate([
////            chart.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
////            chart.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
////            chart.topAnchor.constraint(equalTo: recieveVolumeText.bottomAnchor),
////            chart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
////        ])
//
//        self.chart = chart
//    }
//
//    func setupData() {
//        DispatchQueue.main.async { [self] in
//            let options = CandlestickSeriesOptions(
//                upColor: "rgba(255, 144, 0, 1)",
//                downColor: "#000",
//                borderUpColor: "rgba(255, 144, 0, 1)",
//                borderDownColor: "rgba(255, 144, 0, 1)",
//                wickUpColor: "rgba(255, 144, 0, 1)",
//                wickDownColor: "rgba(255, 144, 0, 1)"
//            )
//
//            let series = chart.addCandlestickSeries(options: options)
//
//            let data = [
//
//                //                CandlestickData(time: .string("2019-05-09"), open: 193.31, high: 195.08, low: 191.59, close: 194.58),
//                //                CandlestickData(time: .string("2019-05-10"), open: 193.21, high: 195.49, low: 190.01, close: 194.58),
//                //                CandlestickData(time: .string("2019-05-13"), open: 191.00, high: 191.66, low: 189.14, close: 190.34),
//                //                CandlestickData(time: .string("2019-05-14"), open: 190.50, high: 192.76, low: 190.01, close: 191.62),
//                //                CandlestickData(time: .string("2019-05-15"), open: 190.81, high: 192.81, low: 190.27, close: 191.76),
//                //                CandlestickData(time: .string("2019-05-16"), open: 192.47, high: 194.96, low: 192.20, close: 192.38),
//                //                CandlestickData(time: .string("2019-05-17"), open: 190.86, high: 194.50, low: 190.75, close: 192.58),
//                CandlestickData(time: .string("2019-05-20"), open: 191.13, high: 192.86, low: 190.61, close: 190.95),
//                CandlestickData(time: .string("2019-05-21"), open: 187.13, high: 192.52, low: 186.34, close: 191.45),
//                CandlestickData(time: .string("2019-05-22"), open: 190.49, high: 192.22, low: 188.05, close: 188.91),
//                CandlestickData(time: .string("2019-05-23"), open: 188.45, high: 192.54, low: 186.27, close: 192.00),
//                CandlestickData(time: .string("2019-05-24"), open: openPrice, high: highPrice, low: lowPrice, close: closePrice)
//            ]
//            series.setData(data: data)
//            self.series = series
//        }
//    }
//}
