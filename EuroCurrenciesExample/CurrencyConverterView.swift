//
//  CurrencyConverterView.swift
//  EuroCurrencies
//
//  Created by Holger Haenisch on 17.04.25.
//


import SwiftUI
import EuroCurrencies

struct CurrencyConverterView: View {
    @State private var amount = ""
    @State private var selectedCurrency = "GBP"
    @State private var euroAmount: Double?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let currencies = ["USD", "GBP", "JPY", "CHF", "AUD", "CAD"]
    let converter: EuroCurrencies
    
    init() {
        converter = EuroCurrencies(currency: selectedCurrency)
    }
    
    var body: some View {
        Form {
            Section("Währung wählen") {
                Picker("Währung", selection: $selectedCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Betrag eingeben") {
                TextField("Betrag", text: $amount)
                    .keyboardType(.decimalPad)
            }
            
            if isLoading {
                ProgressView()
            } else if let euroAmount {
                Section("Ergebnis") {
                    VStack(alignment: .leading) {
                        Text("In Euro:")
                            .font(.subheadline)
                        Text("€ \(euroAmount, specifier: "%.2f")")
                            .font(.title)
                            .bold()
                    }
                }
            }
            
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button("Konvertieren") {
                    convertCurrency()
                }
            }
        }
    }
    
    private func convertCurrency() {
        guard let inputAmount = Double(amount) else {
            errorMessage = "Bitte geben Sie einen gültigen Betrag ein"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let rate = try await converter.fetchConversionRate()
                await MainActor.run {
                    euroAmount = converter.convertToEuro(inputAmount)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Fehler bei der Konvertierung: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}


#Preview {
  CurrencyConverterView()
}
