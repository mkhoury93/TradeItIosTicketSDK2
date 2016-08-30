import XCTest
import TradeItIosTicketSDK2

class TradeItIosTicketSdk2UITests: XCTestCase {
    var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        self.application = XCUIApplication()
        self.application.launchArguments.append("isUITesting")
        self.application.launch()
        sleep(1)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWelcomeFlow() {
        // Launch ticket
        let app = self.application

        seeWelcomeScreen(app)
        
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        
        selectAnAccountOnthePortfolioScreen(app)

        //Balances
        app.tables.staticTexts["Individual**cct1"].exists
        app.tables.staticTexts["$2408.12"].exists
        app.tables.staticTexts["$76489.23 (22.84%)"].exists

        //Positions
        app.tables.staticTexts["Individual**cct1 Holdings"].exists
        app.tables.staticTexts["AAPL"].exists
        app.tables.staticTexts["1 shares"].exists
        app.tables.staticTexts["$103.34"].exists
        app.tables.staticTexts["$112.34"].exists
    }
    
    func testFxWelcomeFlow() {
        // Launch ticket
        let app = self.application
        
        seeWelcomeScreen(app)
        
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Fx Broker")
        
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Fx Broker")
        
        selectAnAccountOnthePortfolioScreen(app)
        
        //Fx Balances
        app.tables.staticTexts["Account (F**cct1"].exists
        app.tables.staticTexts["$9,163"].exists
        app.tables.staticTexts["$1,900"].exists
        
        //Fx Summary
        app.tables.staticTexts["Account (F**cct1 Summary"].exists
        app.tables.staticTexts["$5.89"].exists
        app.tables.staticTexts["$2,500"].exists
        
        //Fx Positions
        app.tables.staticTexts["Account (F**cct1 Holdings"].exists
        //TODO to complete
    }
    
    private func seeWelcomeScreen(app: XCUIApplication) {
        // See Welcome screen
        let launchSdkText = app.tables.staticTexts["LaunchSdk"]
        waitForElementToBeHittable(launchSdkText)
        launchSdkText.tap()
        waitForElementToAppear(app.navigationBars["Welcome"])
        XCTAssert(app.otherElements.staticTexts["Link your broker account"].exists)
        app.buttons["Get Started Now"].tap()
    }
    
    private func selectBrokerFromTheBrokerSelectionScreen(app: XCUIApplication, longBrokerName: String) {
        // Select a broker from the Broker Selection screen
        XCTAssert(app.navigationBars["Select Your Broker"].exists)

        let ezLoadingActivity = app.staticTexts["Loading Brokers"]
        waitForElementToDisappear(ezLoadingActivity)

        XCTAssert(app.tables.cells.count > 0)
        
        let dummyBrokerStaticText = app.tables.staticTexts[longBrokerName]
        XCTAssert(dummyBrokerStaticText.exists)
        
        app.tables.staticTexts[longBrokerName].tap()
    }
    
    private func submitValidCredentialsOnTheLoginScreen(app: XCUIApplication, longBrokerName: String) {
        XCTAssert(app.navigationBars["Login"].exists)
        XCTAssert(app.staticTexts["Log in to \(longBrokerName)"].exists)
        
        let usernameTextField = app.textFields["\(longBrokerName) Username"]
        let passwordTextField = app.secureTextFields["\(longBrokerName) Password"]
        
        waitForElementToHaveKeyboardFocus(usernameTextField)
        waitForElementNotToHaveKeyboardFocus(passwordTextField)
        usernameTextField.typeText("dummy")
        app.buttons["Next"].tap()

        waitForElementToHaveKeyboardFocus(passwordTextField)
        passwordTextField.typeText("dummy")
        app.buttons["Done"].tap()
        
        let activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
    }
    
    private func selectAnAccountOnthePortfolioScreen(app: XCUIApplication) {
        waitForElementToAppear(app.navigationBars["Portfolio"])

        var ezLoadingActivity = app.staticTexts["Authenticating"]
        waitForElementToDisappear(ezLoadingActivity, withinSeconds: 10)

        ezLoadingActivity = app.staticTexts["Retreiving Account Summary"]
        waitForElementToDisappear(ezLoadingActivity)
        
        XCTAssert(app.tables.cells.count > 0)
    }

//    func testPortfolioUserHasAccountFlow() {
//        // Launch ticket
//        let app = self.application
//        
//        // See Portfolio screen
//        app.tables.staticTexts["LaunchPortfolio"].tap()
//        XCTAssert(app.navigationBars["Portfolio"].exists)
//        
//        var ezLoadingActivity = app.staticTexts["Authenticating"]
//        waitForAsyncElementToDisappear(ezLoadingActivity)
//        
//        ezLoadingActivity = app.staticTexts["Retreiving Account Summary"]
//        waitForAsyncElementToDisappear(ezLoadingActivity)
//        
//        XCTAssert(app.tables.cells.count > 0)
//        
//        //Balances
//        app.tables.staticTexts["Dummy *cct1"].exists
//        app.tables.staticTexts["$2408.12"].exists
//        app.tables.staticTexts["$76489.23 (22.84%)"].exists
//        
//        //Positions
//        app.tables.staticTexts["Dummy *cct1 Holdings"].exists
//        app.tables.staticTexts["AAPL (1)"].exists
//        app.tables.staticTexts["$103.34"].exists
//        app.tables.staticTexts["$112.34"].exists
//    }
}