import SwiftUI
import Speech

class SpeechRecognizer: ObservableObject {
  private let speechRecognizer = SFSpeechRecognizer()
  private let audioEngine = AVAudioEngine()
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  
  @Published var isRecording = false
  @Published var text = ""
  
  func startRecording() {
    print("-- [\(String(describing: Thread.current.name))] start recording")
    isRecording = true
    text = ""
    
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      print("[\(String(describing: Thread.isMainThread))]Failed to setup audio session: \(error)")
    }
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    guard let recognitionRequest = recognitionRequest else {
      print("[\(String(describing: Thread.current.name))]Unable to created a SFSpeechAudioBufferRecognitionRequest object")
      return
    }
    
    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
      
      if let result = result {
        self.text = result.bestTranscription.formattedString
      }
      
      if let error = error {
        print("Recognition failed: \(error)")
        self.stopRecording()
      }
    }
    
    let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
    
    audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
    } catch {
      print("Failed to start audio engine: \(error)")
    }
  }
  
  func stopRecording() {
    print("-- [\(String(describing: Thread.current.name))] stop recording")
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
    recognitionRequest = nil
    recognitionTask?.cancel()
    recognitionTask?.finish()
    recognitionTask = nil
    isRecording = false
  }
}
