//
//  ContentView.swift
//  VoiceNote
//
//  Created by JIAN LYU on 12/6/2023.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var speechRecognizer = SpeechRecognizer()
  
  var body: some View {
    VStack {
      Text(speechRecognizer.text)
        .font(.largeTitle)
        .padding()
      
      Button(speechRecognizer.isRecording ? "Stop" : "Record") {
        speechRecognizer.isRecording ? speechRecognizer.stopRecording() : speechRecognizer.startRecording()
      }
      .font(.title)
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .clipShape(Capsule())
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
