//
//  TutorialView.swift
//  yeke
//
//  Created by Mihri Minaz on 31.01.21.
//

import SwiftUI

struct TutorialView: View {
  @Binding var showActionView: Bool

  var body: some View {
    ZStack {
      VStack {
      Text("How does it work?")
        .font(.largeTitle)
      Text("\n- generate a chat code & share it with your friend\n\n - you can also chat with random people.\n\n")
        .font(.body)
        Button(action: { showActionView = true }) { Text("START NOW") }
          .padding()
          .foregroundColor(.white)
          .background("#c397f0".uicolor.color)
      }
      .multilineTextAlignment(.center)
      .padding()
    }
  }
}


struct TutorialView_Previews: PreviewProvider {
  static var previews: some View {
    return TutorialView(showActionView: .constant(false))
  }
}
