//
//  VoiceRecorderView.swift
//  BD Assistant
//
//  Voice recording for notes and transcription
//

import SwiftUI
import AVFoundation

struct VoiceRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recorder = VoiceRecorder()

    @State private var transcription = ""
    @State private var isTranscribing = false
    @State private var selectedLead: Lead?
    @State private var showLeadPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Recording Visualization
                ZStack {
                    // Outer pulse
                    Circle()
                        .fill(recorder.isRecording ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .scaleEffect(recorder.isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: recorder.isRecording)

                    // Middle ring
                    Circle()
                        .fill(recorder.isRecording ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 150, height: 150)

                    // Inner button
                    Button(action: toggleRecording) {
                        ZStack {
                            Circle()
                                .fill(recorder.isRecording ? Color.red : Color.blue)
                                .frame(width: 100, height: 100)

                            Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                        }
                    }
                }

                // Recording Status
                VStack(spacing: 8) {
                    if recorder.isRecording {
                        Text("Recording...")
                            .font(.headline)
                            .foregroundStyle(.red)

                        Text(formatDuration(recorder.currentTime))
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    } else if recorder.hasRecording {
                        Text("Recording Complete")
                            .font(.headline)

                        Text(formatDuration(recorder.currentTime))
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    } else {
                        Text("Tap to Record")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text("Record voice notes for AI transcription")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                // Transcription Result
                if !transcription.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Transcription", systemImage: "text.bubble")
                            .font(.headline)

                        ScrollView {
                            Text(transcription)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 150)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                // Actions
                if recorder.hasRecording {
                    VStack(spacing: 12) {
                        // Lead Association
                        Button(action: { showLeadPicker = true }) {
                            HStack {
                                Image(systemName: "person.circle")
                                if let lead = selectedLead {
                                    Text(lead.companyName)
                                } else {
                                    Text("Associate with Lead (optional)")
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .foregroundStyle(.primary)

                        // Transcribe Button
                        Button(action: transcribe) {
                            HStack {
                                if isTranscribing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "waveform")
                                }
                                Text(isTranscribing ? "Transcribing..." : "Transcribe with AI")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isTranscribing)

                        // Secondary Actions
                        HStack(spacing: 12) {
                            Button(action: recorder.playRecording) {
                                Label("Play", systemImage: "play.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                            }

                            Button(action: recorder.deleteRecording) {
                                Label("Delete", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .foregroundStyle(.red)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Voice Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                if !transcription.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            saveNote()
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showLeadPicker) {
                LeadPickerView(selectedLead: $selectedLead)
            }
            .onAppear {
                recorder.requestPermission()
            }
        }
    }

    private func toggleRecording() {
        if recorder.isRecording {
            recorder.stopRecording()
        } else {
            recorder.startRecording()
        }
    }

    private func transcribe() {
        guard let audioData = recorder.getRecordingData() else { return }

        isTranscribing = true

        Task {
            do {
                let result = try await APIClient.shared.transcribeVoiceNote(audioData: audioData)
                transcription = result
            } catch {
                transcription = "Transcription failed: \(error.localizedDescription)"
            }
            isTranscribing = false
        }
    }

    private func saveNote() {
        // Save transcription to selected lead or as standalone note
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Voice Recorder
class VoiceRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var hasRecording = false
    @Published var currentTime: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    private var recordingURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("voice_note.m4a")
    }

    func requestPermission() {
        AVAudioApplication.requestRecordPermission { granted in
            if !granted {
                print("Microphone permission denied")
            }
        }
    }

    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)

            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.record()

            isRecording = true
            currentTime = 0

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.currentTime = self?.audioRecorder?.currentTime ?? 0
            }
        } catch {
            print("Recording failed: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        isRecording = false
        hasRecording = true
    }

    func playRecording() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
            audioPlayer?.play()
        } catch {
            print("Playback failed: \(error)")
        }
    }

    func deleteRecording() {
        try? FileManager.default.removeItem(at: recordingURL)
        hasRecording = false
        currentTime = 0
    }

    func getRecordingData() -> Data? {
        try? Data(contentsOf: recordingURL)
    }
}

// MARK: - Lead Picker
struct LeadPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLead: Lead?
    @StateObject private var leadService = LeadService.shared
    @State private var searchText = ""

    var filteredLeads: [Lead] {
        if searchText.isEmpty {
            return leadService.leads
        }
        return leadService.leads.filter {
            $0.companyName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredLeads) { lead in
                Button(action: {
                    selectedLead = lead
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(lead.companyName)
                                .font(.headline)
                            Text(lead.industry)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if selectedLead?.id == lead.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Select Lead")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search leads...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        selectedLead = nil
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    VoiceRecorderView()
}
