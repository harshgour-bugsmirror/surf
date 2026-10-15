    import SwiftUI

    @main
    struct surfApp: App {
        var body: some Scene {
            WindowGroup {
                SplashScreenView()
            }
        }
    }

    // MARK: - Splash Screen View
    struct SplashScreenView: View {
        @State private var isActive = false
        @State private var scaleSize: CGFloat = 0.8
        @State private var opacity = 0.5

        var body: some View {
            if isActive {
                ContentView()
            } else {
                ZStack {
                    // Ocean Gradient Background
                    LinearGradient(
                        colors: [Color(red: 0.0, green: 0.4, blue: 0.8), Color(red: 0.1, green: 0.7, blue: 0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 20) {
                        // Surfer Icon (No Wi-Fi look!)
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.15))
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "figure.surfing")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 6) {
                            Text("SURF")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(6)
                            
                            Text("RIDE THE WAVES")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(3)
                        }
                    }
                    .scaleEffect(scaleSize)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            self.scaleSize = 1.0
                            self.opacity = 1.0
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
