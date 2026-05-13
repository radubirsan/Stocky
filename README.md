# Stocky
  
  Small iOS app for the interview. Lists stocks with live quotes from RapidAPI
  and a detail screen per ticker.

  ## Stack
  - SwiftUI, iOS 17.2+
  - Swift Concurrency (`async`/`await`), no Combine
  - MVVM in the presentation layer, Clean Architecture overall (Domain / Data /
  Presentation)
  - Router-style navigation: a single `NavigationStack(path:)` driven by an
  `AppRoute` enum, with one `navigationDestination` switch in `RootView`
  - XCTest, ~40 unit tests
  
  ## Notes for the reviewer

  **API endpoints.** The brief points at `market/v2/get-summary` and
  `stock/v2/get-summary` on the `apidojo/yh-finance` provider. Those returned
  `403 / not subscribed` on the free tier when I tried; I subscribed to a
  different provider on the same marketplace (`yahoo-finance-real-time1`) and
  used its equivalents — `/market/get-quotes` for the list, `/stock/get-summary`
   for the detail.

  **API key.** RapidAPI key is embedded in `APIConfig.swift` for ease of review.
   In a real codebase it would come from an xcconfig that's gitignored, with the
   same `RAPIDAPI_KEY` build setting populated from CI secrets in production.
  Same shape, different source. I referesh it so it will work for another 400 requests.

  ## Run
  1. Open `Stocky.xcodeproj`.
  2. Build & run on an iOS 17.2+ simulator or device. No SPM packages
