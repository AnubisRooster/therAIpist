import Foundation
import AVFoundation
import SwiftData

class VoiceService: NSObject {
    static let shared = VoiceService()

    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    func startRecording() throws -> URL {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDir.appendingPathComponent("\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.record()
        recordingURL = fileURL
        return fileURL
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        let url = recordingURL
        recordingURL = nil
        audioRecorder = nil
        return url
    }

    func recordAndTranscribe(session: SessionModel, provider: String, model: String, context: ModelContext) async throws -> VoiceRecordingModel? {
        let fileURL = try startRecording()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.stopRecording()
        }

        let recording = VoiceRecordingModel(session: session, fileURL: fileURL.path)
        context.insert(recording)

        recording.transcription = "(Voice recording completed - transcription requires API key)"

        return recording
    }
}
