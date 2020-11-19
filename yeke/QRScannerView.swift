//
//  QRScannerView.swift
//  uthere
//
//  Created by Mihri Minaz on 22.10.20.
//

import SwiftUI

struct QRScannerView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var session: Session
  @State var isPresentingScanner = false
  
  var body: some View {
    NavigationView {
      VStack(spacing: 10) {
        Button("Scan Code") { self.isPresentingScanner = true }
          .sheet(isPresented: $isPresentingScanner) { self.scannerSheet }
        Text("Scan a QR code to begin")
      }
    }
  }

  var scannerSheet : some View {
    CodeScannerView(
      codeTypes: [.qr],
      completion: { result in
        if case let .success(code) = result {
          DispatchQueue.main.async {
            self.isPresentingScanner = false
            session.scannedCode = code
          }
        }
    })
  }
}

//struct QRScannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        QRScannerView(sharedScannedCode: )
//    }
//}



