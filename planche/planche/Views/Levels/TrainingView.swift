import SwiftUI
import SwiftData

private enum TrainingPhase {
    case countdown
    case exercise
    case resting
}

struct TrainingView: View {
    let skill: Skill
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var adManager: AdManager
    @State private var currentIndex = 0
    @State private var showCompletion = false
    @State private var sessionStartTime = Date()
    @State private var timeRemaining = 0
    @State private var totalPhaseTime = 0
    @State private var isPaused = false
    @State private var timer: Timer?
    @State private var showQuitConfirmation = false
    @State private var countdownValue = 5
    @State private var phase: TrainingPhase = .countdown
    @State private var currentSet = 1
    @State private var detailExercise: Exercise? = nil
    @State private var currentExerciseStageIndex = 0
    @State private var sessionDuration: TimeInterval = 0
    @State private var showStageProgress = false
    @Query private var allStageProgress: [StageProgress]

    @State private var restDuration = 45
    @State private var showRestPicker = false

    private var exercises: [Exercise] {
        SkillCatalog.shared.exercises(for: skill.id)
    }

    private var currentExercise: Exercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }

    private var isLastSet: Bool {
        guard let exercise = currentExercise else { return true }
        return currentSet >= exercise.sets
    }

    private var nextExercise: Exercise? {
        if !isLastSet { return currentExercise }
        guard currentIndex + 1 < exercises.count else { return nil }
        return exercises[currentIndex + 1]
    }

    private var isLastExercise: Bool {
        currentIndex >= exercises.count - 1 && isLastSet
    }

    private var currentExerciseStage: ExerciseStage? {
        guard let stages = currentExercise?.stages,
              currentExerciseStageIndex < stages.count else { return nil }
        return stages[currentExerciseStageIndex]
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                switch phase {
                case .countdown:
                    Color.clear
                case .exercise:
                    exerciseContent
                case .resting:
                    restContent
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))

            // Countdown overlay
            if phase == .countdown {
                ZStack {
                    Color(.systemBackground).opacity(0.95)
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        Spacer()

                        Text("Get Ready")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        Text("\(countdownValue)")
                            .font(.system(size: 120, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText(countsDown: true))
                            .animation(.linear(duration: 0.4), value: countdownValue)

                        if let exercise = currentExercise {
                            Text(exercise.name)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button {
                            stopTimer()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 44)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(Circle())
                        }
                        .padding(.bottom, 40)
                    }
                }
            }

            // Close button overlay (non-countdown phases)
            if phase != .countdown {
                Button {
                    stopTimer()
                    showQuitConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                }
                .padding(.leading, 20)
                .padding(.top, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            startCountdown()
            if !storeManager.isSubscribed {
                adManager.preloadInterstitial()
            }
        }
        .onDisappear {
            stopTimer()
        }
        .navigationDestination(isPresented: $showCompletion) {
            TrainingCompleteView(skill: skill, trainingDuration: sessionDuration)
        }
        .alert("Quit Training?", isPresented: $showQuitConfirmation) {
            Button("Continue", role: .cancel) {
                if phase == .exercise, let exercise = currentExercise, exercise.exerciseType == .timed {
                    startCountdownTimer()
                } else if phase == .resting {
                    startCountdownTimer()
                }
            }
            Button("Quit", role: .destructive) {
                if !storeManager.isSubscribed {
                    adManager.showInterstitial {
                        navigationState.popToRoot = true
                    }
                } else {
                    navigationState.popToRoot = true
                }
            }
        } message: {
            Text("Your progress in this session will be lost.")
        }
        .sheet(item: $detailExercise) { exercise in
            NavigationStack {
                ExerciseDetailView(exercise: exercise)
            }
        }
        .sheet(isPresented: $showRestPicker) {
            RestDurationPicker(restDuration: $restDuration, timeRemaining: $timeRemaining, totalPhaseTime: $totalPhaseTime)
                .presentationDetents([.height(280)])
        }
        .sheet(isPresented: $showStageProgress) {
            if let stage = currentExerciseStage {
                StageProgressOverlay(
                    exerciseName: exercises[currentIndex].name,
                    skillID: skill.id,
                    stageIndex: currentExerciseStageIndex,
                    stageName: stage.name,
                    isTimedStage: stage.exerciseType == .timed
                )
                .presentationDetents([.fraction(0.4)])
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        let totalBars = exercises.map { $0.sets }.reduce(0, +)
        let completedSetCount = exercises[0..<currentIndex].reduce(0) { $0 + $1.sets }
        let filledBars = completedSetCount + currentSet
        return HStack(spacing: 4) {
            ForEach(0..<totalBars, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < filledBars ? Color.blue : Color(.systemGray4))
                    .frame(height: 4)
            }
        }
    }

    // MARK: - Exercise Content

    private var exerciseContent: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.top, 72)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            stageTabsBar

            exerciseImageSection

            if let exercise = currentExercise {
                exerciseInfoSection(exercise: exercise)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var stageTabsBar: some View {
        Group {
            if let stages = currentExercise?.stages {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(stages.indices, id: \.self) { index in
                            Text("Stage \(index + 1)")
                                .font(.system(size: 13)).fontWeight(.semibold)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(currentExerciseStageIndex == index ? Color.blue : Color(.systemGray5))
                                .foregroundStyle(currentExerciseStageIndex == index ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .onTapGesture {
                                    guard index != currentExerciseStageIndex else { return }
                                    stopTimer()
                                    currentExerciseStageIndex = index
                                    startExercisePhase()
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Exercise Image Section

    private var exerciseImageSection: some View {
        ZStack {
            Color(.systemBackground)
            if let exercise = currentExercise {
                if let stage = currentExerciseStage {
                    stageImage(for: stage)
                } else {
                    exerciseImage(for: exercise)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }

    @ViewBuilder
    private func stageImage(for stage: ExerciseStage) -> some View {
        if let sprite = stage.spriteConfig {
            SpriteAnimationView(config: sprite, maxWidth: 800)
        } else if stage.imageName.hasPrefix("figure.") {
            Image(systemName: stage.imageName)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
        } else {
            Image(stage.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func exerciseImage(for exercise: Exercise) -> some View {
        if let sprite = exercise.spriteConfig {
            SpriteAnimationView(config: sprite, maxWidth: 800)
        } else if exercise.imageName.hasPrefix("figure.") {
            Image(systemName: exercise.imageName)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
        } else {
            Image(exercise.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity,)
        }
    }

    // MARK: - Exercise Info Section

    private func stageProgressRecord(for exercise: Exercise) -> StageProgress? {
        allStageProgress.first { p in
            p.exerciseName == exercise.name
            && p.skillID == skill.id
            && p.stageIndex == currentExerciseStageIndex
        }
    }

    private func exerciseInfoSection(exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text(currentExerciseStage?.name ?? exercise.name)
                    .font(.title3).fontWeight(.bold)
                Button { detailExercise = exercise } label: {
                    Image(systemName: "info.circle")
                        .font(.body).foregroundStyle(.primary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            HStack(spacing: 8) {
                ForEach(1...exercise.sets, id: \.self) { s in
                    Circle()
                        .fill(s <= currentSet ? Color.blue : Color(.systemGray4))
                        .frame(width: 9, height: 9)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            if currentExerciseStage != nil {
                Text("To Failure")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.blue)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }

            if let condition = currentExerciseStage?.nextStageCondition, !condition.isEmpty {
                Text(condition)
                    .font(.system(size: 17)).foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
            }

            if currentExerciseStage != nil {
                let record = stageProgressRecord(for: exercise)
                let value = record?.currentValue ?? 0

                Button { showStageProgress = true } label: {
                    HStack(spacing: 6) {
                        Text("progress:")
                            .font(.system(size: 17))
                            .foregroundStyle(Color(.secondaryLabel))
                        Text("\(value)")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                        Image(systemName: "pencil")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(.secondaryLabel))
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Group {
                if currentExerciseStage != nil {
                    EmptyView()
                } else if exercise.exerciseType == .timed {
                    Text(timerText)
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                } else {
                    let manager = CustomizationManager(modelContext: modelContext)
                    Text(manager.effectiveDisplayText(for: exercise))
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.blue)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            let isReallyLast = isLastExercise
            Button {
                finishCurrentExercise()
            } label: {
                Text(isReallyLast ? "Finish" : "Take the Rest")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Rest Content

    private var restContent: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("Rest")
                    .font(.title2).fontWeight(.semibold).foregroundStyle(.primary)

                Spacer()

                Text(timerText)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))

                Spacer()

                HStack(spacing: 12) {
                    Button { showRestPicker = true } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.subheadline)
                            Text("\(restDuration)s")
                                .font(.headline).fontWeight(.bold)
                        }
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button { skipRest() } label: {
                        Text("Skip")
                            .font(.headline).fontWeight(.bold).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 16)

                if let next = nextExercise {
                    let isStageExercise = next.stages != nil && !(next.stages!.isEmpty)
                    VStack(alignment: .leading, spacing: 6) {
                        if isLastSet {
                            Text("Next")
                                .font(.subheadline).foregroundStyle(Color.secondary)
                        }
                        HStack {
                            HStack(spacing: 8) {
                                Text(next.name).font(.headline).fontWeight(.bold)
                                Button { detailExercise = next } label: {
                                    Image(systemName: "info.circle")
                                        .font(.body).foregroundStyle(.primary)
                                }
                            }
                            Spacer()
                            if isLastSet && !isStageExercise {
                                let m = CustomizationManager(modelContext: modelContext)
                                Text(m.effectiveDisplayText(for: next))
                                    .font(.headline).fontWeight(.bold)
                            }
                        }
                        if !isLastSet && !isStageExercise {
                            HStack(spacing: 8) {
                                ForEach(1...(next.sets), id: \.self) { s in
                                    Circle()
                                        .fill(s <= currentSet ? Color.blue : Color(.systemGray4))
                                        .frame(width: 9, height: 9)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                if let next = nextExercise {
                    Spacer().frame(height: 12)

                    exerciseImage(for: next)
                        .frame(maxWidth: .infinity)
                } else {
                    Color.clear
                }

                // Banner ad for free users during rest
                if !storeManager.isSubscribed {
                    BannerAdView()
                        .frame(height: 50)
                }
            }
        }
    }

    // MARK: - Timer Logic

    private var timerText: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func startCountdown() {
        countdownValue = 5
        phase = .countdown
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdownValue > 1 {
                withAnimation {
                    countdownValue -= 1
                }
            } else {
                stopTimer()
                sessionStartTime = Date()
                startExercisePhase()
            }
        }
    }

    private func startExercisePhase() {
        guard let exercise = currentExercise else { return }
        phase = .exercise
        isPaused = false
        stopTimer()

        // Stages: no auto-timer — user taps "Take the Rest" / "Finish" manually
        if currentExerciseStage == nil, exercise.exerciseType == .timed {
            let manager = CustomizationManager(modelContext: modelContext)
            let duration = manager.effectiveDuration(for: exercise)
            totalPhaseTime = duration
            timeRemaining = duration
            startCountdownTimer()
        }
    }

    private func startRestPhase() {
        phase = .resting
        isPaused = false
        stopTimer()
        totalPhaseTime = restDuration
        timeRemaining = restDuration
        startCountdownTimer()
    }

    private func startCountdownTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                onTimerComplete()
            }
        }
    }

    private func onTimerComplete() {
        stopTimer()
        if phase == .exercise {
            finishCurrentExercise()
        } else {
            advanceToNextExercise()
        }
    }

    private func finishCurrentExercise() {
        stopTimer()
        if isLastExercise {
            completeSession()
        } else {
            startRestPhase()
        }
    }

    private func skipRest() {
        stopTimer()
        advanceToNextExercise()
    }

    private func advanceToNextExercise() {
        if isLastExercise {
            completeSession()
            return
        }
        if !isLastSet {
            withAnimation { currentSet += 1 }
        } else {
            withAnimation {
                currentIndex += 1
                currentSet = 1
            }
            currentExerciseStageIndex = 0
        }
        startExercisePhase()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func togglePause() {
        if isPaused {
            startCountdownTimer()
        } else {
            stopTimer()
        }
        isPaused.toggle()
    }

    private func completeSession() {
        stopTimer()
        let duration = Date().timeIntervalSince(sessionStartTime)
        sessionDuration = duration
        let manager = ProgressManager(modelContext: modelContext)
        manager.completeSession(for: skill, duration: duration)

        if !storeManager.isSubscribed {
            adManager.showInterstitial {
                showCompletion = true
            }
        } else {
            showCompletion = true
        }
    }
}

// MARK: - Rest Duration Picker

private struct RestDurationPicker: View {
    @Binding var restDuration: Int
    @Binding var timeRemaining: Int
    @Binding var totalPhaseTime: Int
    @Environment(\.dismiss) private var dismiss

    private let options = [30, 45, 60, 90, 120]

    var body: some View {
        VStack(spacing: 20) {
            Text("Rest Duration")
                .font(.title3).fontWeight(.semibold)
                .padding(.top, 24)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(options, id: \.self) { seconds in
                    Button {
                        restDuration = seconds
                        totalPhaseTime = seconds
                        timeRemaining = seconds
                        dismiss()
                    } label: {
                        Text("\(seconds)s")
                            .font(.headline).fontWeight(.bold)
                            .foregroundStyle(seconds == restDuration ? .white : .primary)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(seconds == restDuration ? Color.blue : Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}
