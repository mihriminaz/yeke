//
//  QRGenerator.swift
//  uthere
//
//  Created by Mihri Minaz on 29.10.20.
//

import Foundation
import CoreImage.CIFilterBuiltins
import SwiftUI
  
let context = CIContext()
let filter = CIFilter.qrCodeGenerator()

struct QRGeneratorView: View {
  @ObservedObject var chat: ChatModel
  @Binding var code: String
  @Binding var showQRGeneratorView: Bool
  @Binding var showChatView: Bool
  
  var body: some View {
    VStack{
      HStack {
        Spacer()
        Button(action: {
          self.showQRGeneratorView = false
        }) { Text("Done") }
        .padding()
      }
      Spacer()
      Image(uiImage: (code.qrCode ?? UIImage(systemName: "xmark.circle"))!)
      Button(action: {
        UIPasteboard.general.string = "yeke://chat?\(code)"
      }) { Text("Copy Link") }
      .padding(20)
      Spacer()
    }.onReceive(chat.$lastReceivedChatItem) { lastReceivedChatItem in
      print("last lastReceivedMessage \(String(describing: lastReceivedChatItem))")
      if let chatItem = lastReceivedChatItem, chatItem.code == code {
        print("last lastReceivedMessage is this one")
        chat.setCurrentChatItem(chatItem)
        showQRGeneratorView = false
        showChatView = true
      }
    }
  }
}

extension StringProtocol {
  var qrCode: UIImage? {
    guard let data = data(using: .isoLatin1),
      let outputImage = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])?.outputImage
    else { return nil }
    
    let size = outputImage.extent.integral
    let output = CGSize(width: 300, height: 300)
    let format = UIGraphicsImageRendererFormat()
    format.scale = UIScreen.main.scale
    return UIGraphicsImageRenderer(size: output, format: format).image { _ in outputImage
        .transformed(by: .init(scaleX: output.width/size.width, y: output.height/size.height))
        .image
        .draw(in: .init(origin: .zero, size: output))
    }
  }
}

extension CIImage {
  var image: UIImage { .init(ciImage: self) }
}

struct QRGenerator_Previews: PreviewProvider {
  static var previews: some View {
    Group {
//      QRGeneratorView(code: .constant("desdfkjgh"), showQRGeneratorView: .constant(false), showChatView: .constant(false)).environmentObject(ChatModel(token: "dsdsds"))
//      QRGeneratorView(code: .constant("desdfkjgh"), showQRGeneratorView: .constant(false), showChatView: .constant(false)).environmentObject(ChatModel(token: "dsdsds"))
//        .previewDevice("iPhone SE (2nd generation)")
//      QRGeneratorView(code: .constant("desdfkjgh"), showQRGeneratorView: .constant(false), showChatView: .constant(false)).environmentObject(ChatModel(token: "dsdsds"))
//        .preferredColorScheme(.dark)
    }
  }
}
