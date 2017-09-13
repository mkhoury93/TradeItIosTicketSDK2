import UIKit

class TradeItOrdersTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {

    private var noResultsBackgroundView: UIView
    private var _table: UITableView?
    private var refreshControl: UIRefreshControl?
    
    private static let ORDER_CELL_HEIGHT = 50
    
    
    var ordersTable: UITableView? {
        get {
            return _table
        }
        
        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
            }
        }

    }
    
    private var orderSectionPresenters: [OrderSectionPresenter] = []
    
    weak var delegate: TradeItOrdersTableDelegate?
    
    init(noResultsBackgroundView: UIView) {
        self.noResultsBackgroundView = noResultsBackgroundView
    }
    
    func initiateRefresh() {
        self.refreshControl?.beginRefreshing()
        self.delegate?.refreshRequested(
            onRefreshComplete: {
                self.refreshControl?.endRefreshing()
            }
        )
    }
    
    func updateOrders(_ orders: [TradeItOrderStatusDetails]) {
        self.orderSectionPresenters = []
        
        let openOrders = orders.filter { $0.containsOpenStatus()}
        if openOrders.count > 0 {
            self.orderSectionPresenters.append(OrderSectionPresenter(orders: [], title: "Open Orders (Past 60 Days)"))
            let splitedOpenOrdersArray = getSplittedOrdersArray(orders: openOrders)
            buildOrderSectionPresentersFrom(splitedOrdersArray: splitedOpenOrdersArray)
        }
        
        let filledOrders = orders.filter { $0.containsFilledStatus() }
        if filledOrders.count > 0 {
            self.orderSectionPresenters.append(OrderSectionPresenter(orders: [], title: "Filled Orders (Today)"))
            let splitedFilledOrdersArray = getSplittedOrdersArray(orders: filledOrders)
            buildOrderSectionPresentersFrom(splitedOrdersArray: splitedFilledOrdersArray)
        }
        let otherOrders = orders.filter { $0.containsOtherOrderStatus() }
        if otherOrders.count > 0 {
            self.orderSectionPresenters.append(OrderSectionPresenter(orders: [], title: "Other Orders (Today)"))
            let splitedOtherOrdersArray = getSplittedOrdersArray(orders: otherOrders)
            buildOrderSectionPresentersFrom(splitedOrdersArray: splitedOtherOrdersArray)
        }
        
        self.ordersTable?.reloadData()
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.orderSectionPresenters[section].title
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.orderSectionPresenters[indexPath.section].cell(forTableView: tableView, andRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let orderSectionPresenter = self.orderSectionPresenters[safe: section] else { return 0 }
        return orderSectionPresenter.numberOfRows()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.orderSectionPresenters.isEmpty {
            self.ordersTable?.backgroundView = noResultsBackgroundView
        } else {
            self.ordersTable?.backgroundView = nil
        }
        return self.orderSectionPresenters.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(TradeItOrdersTableViewManager.ORDER_CELL_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(TradeItOrdersTableViewManager.ORDER_CELL_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.orderSectionPresenters[section].header(forTableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.orderSectionPresenters[section].heightForHeaderInSection()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    // MARK: Private
    
    private func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(
            self,
            action: #selector(initiateRefresh),
            for: UIControlEvents.valueChanged
        )
        TradeItThemeConfigurator.configure(view: refreshControl)
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }
    
    /**
     * This is to split orders in order to have a specific section for group orders
    **/
    private func getSplittedOrdersArray(orders: [TradeItOrderStatusDetails]) -> [[TradeItOrderStatusDetails]]{
        return orders.reduce([[]], { splittedArrays, order in
            var splittedArraysTmp = splittedArrays
            let lastResult: [TradeItOrderStatusDetails] = splittedArrays[(splittedArrays.endIndex - 1)]
            
            let groupOrderType = order.groupOrderType ?? ""
            
            if groupOrderType.isEmpty && !lastResult.contains(order) { // this is not a group order, we can append the order
                splittedArraysTmp[(splittedArraysTmp.endIndex - 1)].append(order)
                return splittedArraysTmp
            } else { // This is a group order or the begining of a new array
                splittedArraysTmp.append([order])
                return splittedArraysTmp
            }
        })
    }
    
    private func buildOrderSectionPresentersFrom(splitedOrdersArray: [[TradeItOrderStatusDetails]]) {
        splitedOrdersArray.forEach { splittedOrders in
            var orders = splittedOrders
            var title = ""
            var isGroupOrder = false
            if let groupOrder = (splittedOrders.filter { $0.isGroupOrder()}).first
                , let groupOrderType = groupOrder.groupOrderType {
                title = groupOrderType.lowercased().replacingOccurrences(of: "_", with: " ").capitalizingFirstLetter()
                orders = splittedOrders.flatMap { $0.groupOrders ?? [] }
                isGroupOrder = true
            }
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    orders: orders,
                    title: title,
                    isGroupOrder: isGroupOrder
                )
            )
        }
    }
    
    private func isOpenOrder() {
        
    }

}

fileprivate class OrderSectionPresenter {
    
    private static let SECTION_HEADER_HEIGHT = 30
    private static let SECTION_GROUP_HEADER_HEIGHT = 20
    
    let orders: [TradeItOrderStatusDetails]
    var title: String
    var isGroupOrder: Bool
    
    init(orders: [TradeItOrderStatusDetails], title: String, isGroupOrder: Bool = false) {
        self.orders = orders
        self.title = title
        self.isGroupOrder = isGroupOrder
    }
    
    func numberOfRows() -> Int {
        return self.orders.flatMap { $0.orderLegs ?? [] }.count
    }
    
    func cell(forTableView tableView: UITableView, andRow row: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_ORDER_CELL_ID") as? TradeItOrderTableViewCell
            , let orderLeg = (self.orders.flatMap { $0.orderLegs ?? [] }) [safe: row]
            , let order = (self.orders.filter { $0.orderLegs?.contains(orderLeg) ?? false }).first
        else {
            return UITableViewCell()
        }
        
        cell.populate(withOrder: order, andOrderLeg: orderLeg, isGroupOrder: self.isGroupOrder)
        return cell
    }
    
    func header(forTableView tableView: UITableView) -> UITableViewCell? {
        if self.title == "" {
            return nil
        } else {
            let header = UITableViewCell()
            header.textLabel?.text = self.title
            if self.isGroupOrder {
                TradeItThemeConfigurator.configureTableHeader(header: header, groupedStyle: false)
            } else {
                TradeItThemeConfigurator.configureTableHeader(header: header)
            }
            return header
        }
    }
    
    func heightForHeaderInSection() -> CGFloat {
        if self.title == "" {
            return CGFloat.leastNormalMagnitude
        } else if self.isGroupOrder{
            return CGFloat(OrderSectionPresenter.SECTION_GROUP_HEADER_HEIGHT)
        } else {
            return CGFloat(OrderSectionPresenter.SECTION_HEADER_HEIGHT)
        }
    }

}


protocol TradeItOrdersTableDelegate: class {
    func refreshRequested(onRefreshComplete: @escaping () -> Void)
}
