# Crypto Pulse App

Crypto Pulse is a SWIFT pet project designed to track real-time cryptocurrency data. The project utilizes the Binance cryptocurrency exchange API to access information on prices, volumes, and other parameters of various trading pairs. It also includes a backend server built on Django, a PostgreSQL database, and the capability to send notifications via Telegram.

# Functionality
- Cryptocurrency Tracking: Users can select a specific cryptocurrency and receive information on the current price, daily volume, and other metrics, with the option to customize lists of tracked assets.
- Setting Alarms: The ability to set notifications in Telegram when a specified cryptocurrency price is reached. The alarm triggering logic is located on the Django server. When the current price reaches the specified value, the user receives a notification on Telegram.
- Interactive Charts: The project features a function to display data as interactive price charts using the LightweightCharts third-party library, which enables the visualization of candlestick charts and interactive analysis of price trends and trading volumes.

# Technologies and Tools
- Programming Language: Swift for iOS app development, Django for the server-side, Python for backend logic, PostgreSQL for database operations.
- iOS App: UIKit, URLSession, JSONSerialization.
- Network Interaction: WebSocket for real-time data retrieval in the iOS app.
- Third-Party Library: LightweightCharts via CocoaPods for interactive display of candlestick charts in the iOS app.
- Server-Side: Django for web app development, PostgreSQL for data storage, Python for backend logic, Telegram API for notifications.
