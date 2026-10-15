import SwiftUI

// MARK: - Models
struct SurfSpot: Identifiable {
    let id = UUID()
    let name: String
    let condition: String
    let waveFt: Int
    let windKts: Int
    let tempF: Int
    var isFavorite: Bool
}

struct SurfLog: Identifiable {
    let id = UUID()
    let spotName: String
    let waveCount: Int
    let board: String
    let date: String
}

// MARK: - Main Tab View
struct ContentView: View {
    @StateObject private var spoofDetector = LocationSpoofDetector.shared
    @StateObject private var developerOptionStatus =  DeveloperModeDetector.shared

    var body: some View {
        TabView {
            SurfDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "wave.3.right")
                }
            
            ResponsivenessTestView()
                .tabItem {
                    Label("Flow Test", systemImage: "rectangle.3.group")
                }
            
            NavigationTestView()
                .tabItem {
                    Label("Screens", systemImage: "sidebar.left")
                }
        }
        .onAppear {
            spoofDetector.startMonitoring()
            developerOptionStatus.checkDeveloperStatus()
        }
        .alert("Spoofed Location Detected", isPresented: $spoofDetector.isLocationSpoofed) {
            Button("OK", role: .cancel) {
                spoofDetector.dismissAlert()
            }
        } message: {
            Text(spoofDetector.spoofReason.isEmpty
                 ? "A virtual or simulated location source was detected on this device."
                 : spoofDetector.spoofReason)
        }
        .alert("Developer Mode active", isPresented: $developerOptionStatus.isDeveloperModeEnabled){
            Button("OK", role: .cancel){
                developerOptionStatus.dismissAlert()
            }
        } message: {
            Text(developerOptionStatus.developerModeReason.isEmpty
                 ? "iOS Developer Mode is turned ON on this device."
                 : developerOptionStatus.developerModeReason)
        }
    }
}

// MARK: - Tab 1: Simplified Surf Dashboard
struct SurfDashboardView: View {
    @State private var searchText: String = ""
    @State private var toastMessage: String? = nil
    @State private var selectedSpotIndex: Int = 0
    @State private var isMetric: Bool = false   
    @State private var showLogSheet: Bool = false
    
    @State private var spots: [SurfSpot] = [
        SurfSpot(name: "Malibu Beach", condition: "Epic", waveFt: 5, windKts: 8, tempF: 68, isFavorite: true),
        SurfSpot(name: "Pipeline Oahu", condition: "Heavy", waveFt: 10, windKts: 16, tempF: 75, isFavorite: false),
        SurfSpot(name: "Bells Beach", condition: "Fair", waveFt: 4, windKts: 12, tempF: 62, isFavorite: false),
        SurfSpot(name: "Gold Coast", condition: "Clean", waveFt: 6, windKts: 9, tempF: 72, isFavorite: true)
    ]
    
    @State private var loggedSessions: [SurfLog] = [
        SurfLog(spotName: "Malibu Beach", waveCount: 8, board: "9'2 Longboard", date: "Today"),
        SurfLog(spotName: "Pipeline Oahu", waveCount: 4, board: "6'0 Shortboard", date: "Yesterday")
    ]
    
    var currentSpot: SurfSpot {
        spots[selectedSpotIndex]
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Search Bar with Instant Toast Action
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search surf spots...", text: $searchText)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    triggerToast("Searched: \"\(searchText)\"")
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Button("Search") {
                                if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                    triggerToast("Please enter a search query")
                                } else {
                                    triggerToast("Searching: \"\(searchText)\"")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        .padding(12)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12)

                        // 2. Main Hero Card
                        VStack(spacing: 16) {
                            HStack {
                                Text(currentSpot.condition.uppercased())
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.white.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button {
                                    spots[selectedSpotIndex].isFavorite.toggle()
                                    triggerToast(spots[selectedSpotIndex].isFavorite ? "Added to favorites" : "Removed from favorites")
                                } label: {
                                    Image(systemName: currentSpot.isFavorite ? "heart.fill" : "heart")
                                        .font(.title3)
                                        .foregroundColor(currentSpot.isFavorite ? .red : .white)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(currentSpot.name)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                Text("Live Conditions")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider().background(.white.opacity(0.4))
                            
                            HStack {
                                MetricBox(
                                    title: "WAVE",
                                    value: isMetric ? String(format: "%.1f", Double(currentSpot.waveFt) * 0.3048) : "\(currentSpot.waveFt)",
                                    unit: isMetric ? "m" : "ft",
                                    icon: "water.waves"
                                )
                                Spacer()
                                MetricBox(
                                    title: "WIND",
                                    value: "\(currentSpot.windKts)",
                                    unit: "kts",
                                    icon: "wind"
                                )
                                Spacer()
                                MetricBox(
                                    title: "TEMP",
                                    value: isMetric ? "\(Int((Double(currentSpot.tempF) - 32) * 5/9))" : "\(currentSpot.tempF)",
                                    unit: isMetric ? "°C" : "°F",
                                    icon: "thermometer.medium"
                                )
                            }
                        }
                        .padding(20)
                        .background(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(20)

                        // 3. Horizontal Beach Selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Spot")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(0..<spots.count, id: \.self) { index in
                                        Button {
                                            withAnimation { selectedSpotIndex = index }
                                        } label: {
                                            Text(spots[index].name)
                                                .font(.subheadline.weight(.semibold))
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(selectedSpotIndex == index ? Color.blue : Color.gray.opacity(0.15))
                                                .foregroundColor(selectedSpotIndex == index ? .white : .primary)
                                                .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                        }

                        // 4. Compact Session Logbook
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Recent Sessions")
                                    .font(.headline)
                                Spacer()
                                Button("Log Surf") {
                                    showLogSheet = true
                                }
                                .font(.subheadline.bold())
                            }
                            
                            ForEach(loggedSessions) { log in
                                HStack {
                                    Image(systemName: "figure.surfing")
                                        .foregroundColor(.blue)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(log.spotName)
                                            .font(.subheadline.bold())
                                        Text("\(log.board) • \(log.waveCount) waves")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(log.date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(10)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                
                // Toast Banner Overlay
                if let message = toastMessage {
                    ToastView(message: message)
                }
            }
            .navigationTitle("Surf Forecast")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isMetric ? "Metric" : "Imperial") {
                        withAnimation { isMetric.toggle() }
                    }
                    .font(.caption.bold())
                }
            }
            .sheet(isPresented: $showLogSheet) {
                AddLogSheet(defaultSpot: currentSpot.name) { newLog in
                    loggedSessions.insert(newLog, at: 0)
                    triggerToast("Logged session for \(newLog.spotName)")
                }
            }
        }
    }
    
    private func triggerToast(_ message: String) {
        withAnimation(.spring()) { toastMessage = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut) {
                if toastMessage == message { toastMessage = nil }
            }
        }
    }
}

// MARK: - Tab 2: Responsiveness & Interactive Test View
struct ResponsivenessTestView: View {
    @State private var userNote: String = ""
    @State private var toastText: String? = nil
    
    // Adaptive grid columns to test responsiveness across sizes (iPhone SE, Pro Max, iPad)
    let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Interactive Text Field Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Interactive Text Input")
                                .font(.headline)
                            
                            TextField("Type notes here to trigger toast...", text: $userNote)
                                .padding()
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            
                            Button(action: {
                                if userNote.isEmpty {
                                    showLocalToast("Please enter text first!")
                                } else {
                                    showLocalToast("Note saved: \(userNote)")
                                }
                            }) {
                                Label("Submit Note", systemImage: "paperplane.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Divider()
                        
                        // Responsive Grid Layout
                        Text("Adaptive Layout Test")
                            .font(.headline)
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(1...6, id: \.self) { index in
                                VStack {
                                    Image(systemName: "water.waves")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    Text("Card Item \(index)")
                                        .font(.caption.bold())
                                }
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                
                if let toastText = toastText {
                    ToastView(message: toastText)
                }
            }
            .navigationTitle("Responsive Test")
        }
    }
    
    private func showLocalToast(_ msg: String) {
        withAnimation(.spring()) { toastText = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { if toastText == msg { toastText = nil } }
        }
    }
}

// MARK: - Tab 3: Navigation & Screen Stack Testing
struct NavigationTestView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Screen 1 Options")) {
                    NavigationLink("Go to Detailed Spot View") {
                        SpotDetailTestView(spotTitle: "Pipeline Oahu Detail")
                    }
                    NavigationLink("Go to Settings & Preferences") {
                        SettingsTestView()
                    }
                }
            }
            .navigationTitle("Multi-Screen Test")
        }
    }
}

// Sub-screen 1
struct SpotDetailTestView: View {
    let spotTitle: String
    @State private var feedbackText: String = ""
    @State private var toastText: String? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 20) {
                Text(spotTitle)
                    .font(.largeTitle.bold())
                
                Text("This detail view allows you to test navigation stack pop/push performance.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                TextField("Provide spot feedback...", text: $feedbackText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button("Submit Feedback") {
                    showLocalToast("Feedback: \(feedbackText.isEmpty ? "None" : feedbackText)")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            
            if let toastText = toastText {
                ToastView(message: toastText)
            }
        }
        .navigationTitle("Spot Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func showLocalToast(_ msg: String) {
        withAnimation(.spring()) { toastText = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { if toastText == msg { toastText = nil } }
        }
    }
}

// Sub-screen 2
struct SettingsTestView: View {
    @State private var notificationsEnabled = true
    @State private var offlineMode = false
    
    var body: some View {
        Form {
            Section(header: Text("App Preferences")) {
                Toggle("Enable Surf Alerts", isOn: $notificationsEnabled)
                Toggle("Offline Mode", isOn: $offlineMode)
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Reusable Views & Components
struct ToastView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
            Text(message)
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct MetricBox: View {
    let title: String
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(unit)
                    .font(.caption2.bold())
                    .foregroundColor(.white.opacity(0.8))
            }
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct AddLogSheet: View {
    @Environment(\.dismiss) var dismiss
    let defaultSpot: String
    var onSave: (SurfLog) -> Void

    @State private var spotName: String = ""
    @State private var waveCount: String = "5"
    @State private var board: String = "Shortboard"

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Session Details")) {
                    TextField("Spot Name", text: $spotName)
                    TextField("Board Used", text: $board)
                    TextField("Waves Caught", text: $waveCount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New Log Entry")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { spotName = defaultSpot }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let log = SurfLog(
                            spotName: spotName.isEmpty ? defaultSpot : spotName,
                            waveCount: Int(waveCount) ?? 0,
                            board: board,
                            date: "Just now"
                        )
                        onSave(log)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
