import UIKit
import EuroCurrencies

Task {
  do {
    let converter = EuroCurrencies(currency: "TRY")
    let currencies = try await converter.fetchConversionRate()
    print(currencies)
    print(converter.lastUpdateDate as Date? ?? "No date")
  } catch {
    print("Error: \(error)")
  }
}
