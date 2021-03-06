import UIKit

@objc public class TradeItTheme: NSObject {
    public var textColor: UIColor = UIColor.darkText
    public var warningTextColor: UIColor = UIColor.tradeItSellRedColor

    public var backgroundColor: UIColor = UIColor.white

    public var tableHeaderBackgroundColor: UIColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
    public var tableHeaderTextColor: UIColor = UIColor(red: 0.49, green: 0.49, blue: 0.51, alpha: 1.0)
    public var tableBackgroundPrimaryColor: UIColor = UIColor.white
    public var tableBackgroundSecondaryColor: UIColor = UIColor.groupTableViewBackground

    public var interactivePrimaryColor: UIColor = UIButton().tintColor
    public var interactiveSecondaryColor: UIColor = UIColor.white

    public var warningPrimaryColor: UIColor = UIColor.tradeItDeepRoseColor
    public var warningSecondaryColor: UIColor = UIColor.white

    override public init() {
        super.init()
    }

    static public func light() -> TradeItTheme {
        return TradeItTheme()
    }

    static public func dark() -> TradeItTheme {
        let theme = TradeItTheme()

        theme.textColor = UIColor.white
        theme.warningTextColor = UIColor.tradeItDeepRoseColor

        theme.backgroundColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)

        theme.tableHeaderBackgroundColor = UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1.0)
        theme.tableHeaderTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        theme.tableBackgroundPrimaryColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)
        theme.tableBackgroundSecondaryColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0)

        theme.interactivePrimaryColor = UIColor(red: 1.00, green: 0.57, blue: 0.00, alpha: 1.0)
        theme.interactiveSecondaryColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)

        theme.warningPrimaryColor = UIColor.tradeItDeepRoseColor
        theme.warningSecondaryColor = UIColor.white

        return theme
    }

    static public func bb() -> TradeItTheme {
        let theme = TradeItTheme()

        theme.interactivePrimaryColor = UIColor(red: 0.156862745, green: 0.0, blue: 0.843137255, alpha: 1.0)

        return theme
    }
}
