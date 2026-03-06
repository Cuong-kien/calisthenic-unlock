import Foundation

struct ExerciseStore {
    static let shared = ExerciseStore()

    let exercises: [Level: [Exercise]]

    private static let spriteConfigs: [String: SpriteConfig] = [
        "Push-ups": SpriteConfig(imageName: "sprite-push-up", frameCount: 9, columns: 3, fps: 2),
        "Hollow Rock": SpriteConfig(imageName: "sprite-hollow-rock", frameCount: 9, columns: 3, fps: 2),
        "Pseudo Planche Push-ups": SpriteConfig(imageName: "sprite-pseudo-planche-pushup", frameCount: 9, columns: 3, fps: 2),
    ]

    private static let videoNames: [String: String] = [
        "Pike Push-ups": "pike-pushup",
    ]

    private static let templates: [(name: String, imageName: String, type: ExerciseType, durationSeconds: Int, reps: String, repsByDifficulty: [Difficulty: String], guide: String)] = [
        ("Plank Hold",          "plank-hold",              .timed,    30, "30s",  [.starter: "20s", .standard: "30s", .solid: "45s"], "Keep your body in a straight line from head to heels. Engage your core and avoid sagging hips."),
        ("Push-ups",            "sprite-push-up",                      .repBased, 0, "10 rep", [.starter: "8 rep", .standard: "10 rep", .solid: "14 rep"], "Lower your chest to the floor with elbows at 45 degrees. Push through your palms fully."),
        ("L-Sit Hold",          "l-sit-hold",              .timed,    20, "20s",  [.starter: "10s", .standard: "20s", .solid: "30s"], "Press down firmly through the parallettes. Keep legs straight and toes pointed forward."),
        ("Pike Push-ups",       "figure.strengthtraining.traditional", .repBased, 0, "8 rep",  [.starter: "6 rep", .standard: "8 rep", .solid: "12 rep"], "Hinge at the hips with hands shoulder-width apart. Lower the top of your head toward the floor."),
        ("Hollow Body Hold",    "figure.core.training",    .timed,    25, "25s",  [.starter: "15s", .standard: "25s", .solid: "35s"], "Press your lower back into the floor. Extend arms overhead and keep legs straight and hovering."),
        ("Dips",                "figure.strengthtraining.traditional", .repBased, 0, "10 rep", [.starter: "6 rep", .standard: "10 rep", .solid: "14 rep"], "Lower until your upper arms are parallel to the floor. Keep elbows tucked and lean slightly forward."),
        ("Tuck Planche Hold",   "figure.gymnastics",       .timed,    15, "15s",  [.starter: "8s", .standard: "15s", .solid: "20s"], "Lean forward with protracted shoulders and lift your tucked knees off the ground completely."),
        ("Pseudo Planche Push-ups", "sprite-pseudo-planche-pushup", .repBased, 0, "8 rep", [.starter: "5 rep", .standard: "8 rep", .solid: "12 rep"], "Place hands by your waist with fingers pointing backward. Lean forward and keep elbows tight."),
        ("Handstand Wall Hold", "figure.gymnastics",       .timed,    20, "20s",  [.starter: "10s", .standard: "20s", .solid: "30s"], "Kick up gently against the wall. Stack your wrists, shoulders, and hips in a straight line."),
        ("Straight Bar Dips",   "figure.strengthtraining.traditional", .repBased, 0, "8 rep",  [.starter: "5 rep", .standard: "8 rep", .solid: "10 rep"], "Grip the bar at hip width and lean forward slightly. Lower with control and press up fully."),
        ("Hollow Rock",         "sprite-hollow-rock",                  .repBased, 0, "8 rep",  [.starter: "6 rep", .standard: "8 rep", .solid: "12 rep"], "Keep your body in a tight hollow shape — lower back pressed down, arms by ears, legs straight. Rock forward and backward using your abs, not momentum."),
    ]

    private static let frogStandLevelExercises: [Exercise] = [
        Exercise(
            name: "Scapular Push-up",
            level: .foundation2,
            description: "Perform Scapular Push-up with proper form and controlled movements.",
            imageName: "sprite-scapular-push-up",
            spriteConfig: SpriteConfig(imageName: "sprite-scapular-push-up", frameCount: 9, columns: 3, fps: 2),
            reps: "10 rep",
            repsByDifficulty: [.starter: "10 rep", .standard: "10 rep", .solid: "10 rep"],
            exerciseType: .repBased,
            guide: "Start in a push-up position with arms straight. Without bending your elbows, let your chest sink by retracting your shoulder blades, then push back up by protracting them.",
            sets: 3
        ),
        Exercise(
            name: "Planche Lean",
            level: .foundation2,
            description: "Perform Planche Lean with proper form and controlled movements.",
            imageName: "planche-lean",
            reps: "15s",
            repsByDifficulty: [.starter: "15s", .standard: "15s", .solid: "15s"],
            durationSeconds: 15,
            exerciseType: .timed,
            guide: "In push-up position, lean your body forward until your shoulders pass your wrists. Keep arms straight, core tight, and toes on the ground. Hold the position.",
            sets: 3
        ),
        Exercise(
            name: "Pseudo Planche Push-ups",
            level: .foundation2,
            description: "Perform Pseudo Planche Push-up with proper form and controlled movements.",
            imageName: "sprite-pseudo-planche-pushup",
            spriteConfig: SpriteConfig(imageName: "sprite-pseudo-planche-pushup", frameCount: 9, columns: 3, fps: 2),
            reps: "5 rep",
            repsByDifficulty: [.starter: "5 rep", .standard: "8 rep", .solid: "10 rep"],
            exerciseType: .repBased,
            guide: "Place hands by your waist with fingers pointing backward. Lean forward and keep elbows tight to your sides as you lower and press.",
            sets: 3
        ),
        Exercise(
            name: "Pike Push-ups",
            level: .foundation2,
            description: "Perform Pike Push-up with proper form and controlled movements.",
            imageName: "sprite-pike-pushup",
            spriteConfig: SpriteConfig(imageName: "sprite-pike-pushup", frameCount: 9, columns: 3, fps: 2),
            reps: "8 rep",
            repsByDifficulty: [.starter: "8 rep", .standard: "10 rep", .solid: "12 rep"],
            exerciseType: .repBased,
            guide: "Hinge at the hips with hands shoulder-width apart. Lower the top of your head toward the floor, then press back up.",
            sets: 3
        ),
        Exercise(
            name: "Hollow Rock",
            level: .foundation2,
            description: "Perform Hollow Rock with proper form and controlled movements.",
            imageName: "sprite-hollow-rock",
            spriteConfig: SpriteConfig(imageName: "sprite-hollow-rock", frameCount: 9, columns: 3, fps: 2),
            reps: "8 rep",
            repsByDifficulty: [.starter: "6 rep", .standard: "8 rep", .solid: "12 rep"],
            exerciseType: .repBased,
            guide: "Keep your body in a tight hollow shape — lower back pressed down, arms by ears, legs straight. Rock forward and backward using your abs, not momentum.",
            sets: 3
        ),
        Exercise(
            name: "Frog Stand",
            level: .foundation2,
            description: "A foundational balance skill. Select a stage that matches your current level and work through all four progressively.",
            imageName: "frog-stand-lean",
            sets: 3,
            stages: frogStandStages
        ),
    ]

    private static let tuckPlancheLevelExercises: [Exercise] = {
        let lookup = Dictionary(uniqueKeysWithValues: frogStandLevelExercises.map { ($0.name, $0) })
        func fromFrog(_ name: String) -> Exercise {
            let ex = lookup[name]!
            return Exercise(
                name: ex.name, level: .tuckPlanche, description: ex.description,
                imageName: ex.imageName, spriteConfig: ex.spriteConfig,
                videoName: ex.videoName, reps: ex.reps,
                repsByDifficulty: ex.repsByDifficulty,
                durationSeconds: ex.durationSeconds, exerciseType: ex.exerciseType,
                guide: ex.guide, sets: ex.sets, stages: ex.stages
            )
        }
        return [
            fromFrog("Planche Lean"),
            fromFrog("Hollow Rock"),
            fromFrog("Pike Push-ups"),
            Exercise(
                name: "L-Sit Hold", level: .tuckPlanche,
                description: "Perform L-Sit Hold with proper form and controlled movements.",
                imageName: "l-sit-hold",
                reps: "20s", durationSeconds: 20, exerciseType: .timed,
                guide: "Press down firmly through the parallettes. Keep legs straight and toes pointed forward.",
                sets: 3
            ),
            fromFrog("Pseudo Planche Push-ups"),
            Exercise(
                name: "Tuck Planche Push-up", level: .tuckPlanche,
                description: "Perform Tuck Planche Push-up with proper form and controlled movements.",
                imageName: "sprite-tuck-planche-pushup",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-planche-pushup", frameCount: 9, columns: 3, fps: 2),
                reps: "5 rep",
                exerciseType: .repBased,
                guide: "Maintain a tight tuck position throughout. Keep your elbows close and push through your palms fully. Control the descent and drive up with intention.",
                sets: 3
            ),
            Exercise(
                name: "Tuck Sit Swing", level: .tuckPlanche,
                description: "Perform Tuck Sit Swing with proper form and controlled movements.",
                imageName: "sprite-tuck-sit-swing",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-sit-swing", frameCount: 9, columns: 3, fps: 2),
                reps: "8 rep",
                exerciseType: .repBased,
                guide: "From a seated tuck position on the parallettes, drive your knees forward and swing into a forward lean. Control the swing in both directions and keep your core tight throughout.",
                sets: 3
            ),
            Exercise(
                name: "Planche Lean Drag to Tuck Planche",
                level: .tuckPlanche,
                description: "Perform Planche Lean Drag to Tuck Planche with proper form and controlled movements.",
                imageName: "sprite-planche-lean-drag-tuck",
                spriteConfig: SpriteConfig(imageName: "sprite-planche-lean-drag-tuck", frameCount: 9, columns: 3, fps: 2),
                reps: "5 rep",
                exerciseType: .repBased,
                guide: "From a planche lean position, drag your knees forward toward your chest as you shift your bodyweight onto your hands. Hold briefly at the top then return with control. Keep shoulders protracted throughout.",
                sets: 3
            ),
            Exercise(
                name: "Tuck Planche", level: .tuckPlanche,
                description: "A staged progression toward the tuck planche. Select the stage that matches your current ability and work through all four progressively.",
                imageName: "tuck-planche-ground",
                sets: 3, stages: tuckPlancheStages
            ),
        ]
    }()

    private static let advTuckPlancheLevelExercises: [Exercise] = {
        let templateNames: [String] = ["Plank Hold", "Push-ups", "L-Sit Hold", "Pseudo Planche Push-ups", "Hollow Rock"]
        let fromTemplates = templateNames.compactMap { name -> Exercise? in
            guard let t = templates.first(where: { $0.name == name }) else { return nil }
            return Exercise(
                name: t.name, level: .advTuckPlanche,
                description: "Perform \(t.name) with proper form and controlled movements.",
                imageName: t.imageName, spriteConfig: spriteConfigs[t.name],
                videoName: videoNames[t.name], reps: t.reps,
                repsByDifficulty: t.repsByDifficulty,
                durationSeconds: t.durationSeconds, exerciseType: t.type,
                guide: t.guide
            )
        }
        return fromTemplates + [
            Exercise(
                name: "Handstand Push-up (Wall)", level: .advTuckPlanche,
                description: "Perform Handstand Push-up (Wall) with proper form and controlled movements.",
                imageName: "sprite-handstand-pushup-wall",
                spriteConfig: SpriteConfig(imageName: "sprite-handstand-pushup-wall", frameCount: 9, columns: 3, fps: 2),
                reps: "5 rep", exerciseType: .repBased,
                guide: "Kick up against the wall and find a straight, balanced body line. Lower your head toward the floor with control, then press back up explosively. Keep your core tight throughout.",
                sets: 3
            ),
            Exercise(
                name: "Tuck to ADV Tuck Planche", level: .advTuckPlanche,
                description: "A staged progression from the tuck planche to the advanced tuck planche. Work through both stages progressively.",
                imageName: "sprite-tuck-to-adv-1",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-to-adv-1", frameCount: 9, columns: 3, fps: 2),
                sets: 3, stages: advTuckPlancheStages
            ),
        ]
    }()

    private static let straddlePlancheLevelExercises: [Exercise] = {
        let tuckLookup = Dictionary(uniqueKeysWithValues: tuckPlancheLevelExercises.map { ($0.name, $0) })
        let advLookup  = Dictionary(uniqueKeysWithValues: advTuckPlancheLevelExercises.map { ($0.name, $0) })

        func fromTuck(_ name: String) -> Exercise {
            let ex = tuckLookup[name]!
            return Exercise(name: ex.name, level: .straddlePlanche, description: ex.description,
                            imageName: ex.imageName, spriteConfig: ex.spriteConfig,
                            videoName: ex.videoName, reps: ex.reps,
                            repsByDifficulty: ex.repsByDifficulty,
                            durationSeconds: ex.durationSeconds, exerciseType: ex.exerciseType,
                            guide: ex.guide, sets: ex.sets, stages: ex.stages)
        }
        func fromAdv(_ name: String) -> Exercise {
            let ex = advLookup[name]!
            return Exercise(name: ex.name, level: .straddlePlanche, description: ex.description,
                            imageName: ex.imageName, spriteConfig: ex.spriteConfig,
                            videoName: ex.videoName, reps: ex.reps,
                            repsByDifficulty: ex.repsByDifficulty,
                            durationSeconds: ex.durationSeconds, exerciseType: ex.exerciseType,
                            guide: ex.guide, sets: ex.sets, stages: ex.stages)
        }

        return [
            fromTuck("L-Sit Hold"),
            Exercise(
                name: "Straddle Planche Lean",
                level: .straddlePlanche,
                description: "Perform Straddle Planche Lean with proper form and controlled movements.",
                imageName: "straddle-lean",
                reps: "15s", durationSeconds: 15, exerciseType: .timed,
                guide: "From a support position on the parallettes, lean your body forward with legs straddled wide apart. Keep arms straight, shoulders protracted, and hold the position.",
                sets: 3
            ),
            Exercise(
                name: "Handstand Hold (Wall)",
                level: .straddlePlanche,
                description: "Perform Handstand Hold (Wall) with proper form and controlled movements.",
                imageName: "handstand-hold-wall",
                reps: "20s", durationSeconds: 20, exerciseType: .timed,
                guide: "Kick up against the wall and find a straight, balanced body line. Stack your wrists, shoulders, and hips in a straight line.",
                sets: 3
            ),
            Exercise(
                name: "Tuck Planche Push-up",
                level: .straddlePlanche,
                description: "Perform Tuck Planche Push-up with proper form and controlled movements.",
                imageName: "sprite-tuck-planche-pushup",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-planche-pushup", frameCount: 9, columns: 3, fps: 2),
                reps: "5 rep", exerciseType: .repBased,
                guide: "Maintain a tight tuck position throughout. Keep elbows close and push through your palms fully.",
                sets: 3
            ),
            fromAdv("Handstand Push-up (Wall)"),
            Exercise(
                name: "ADV Tuck Hold",
                level: .straddlePlanche,
                description: "Perform ADV Tuck Hold with proper form and controlled movements.",
                imageName: "adv-tuck-planche-hold",
                reps: "8s", durationSeconds: 8, exerciseType: .timed,
                guide: "Hold the advanced tuck planche with your back parallel to the floor. Hips pushed back, shoulders protracted, arms locked straight.",
                sets: 3
            ),
            Exercise(
                name: "Straddle Planche Hold",
                level: .straddlePlanche,
                description: "Perform Straddle Planche Hold with proper form and controlled movements.",
                imageName: "straddle-planche-hold",
                reps: "5s", durationSeconds: 5, exerciseType: .timed,
                guide: "Hold your body parallel to the ground with legs straddled wide apart, supported only by straight arms. Keep shoulders protracted and hips elevated.",
                sets: 3
            ),
            Exercise(
                name: "ADV Tuck to Straddle Planche",
                level: .straddlePlanche,
                description: "Perform ADV Tuck to Straddle Planche with proper form and controlled movements.",
                imageName: "sprite-adv-tuck-to-straddle",
                spriteConfig: SpriteConfig(imageName: "sprite-adv-tuck-to-straddle", frameCount: 9, columns: 3, fps: 2),
                reps: "5 rep", exerciseType: .repBased,
                guide: "From an advanced tuck planche, extend one leg out to the side then follow with the other to reach a straddle position. Keep your shoulders protracted and hips elevated throughout the transition.",
                sets: 3
            ),
        ]
    }()

    private init() {
        var all: [Level: [Exercise]] = [:]
        for level in Level.allCases {
            if level == .foundation2 {
                all[level] = Self.frogStandLevelExercises
            } else if level == .tuckPlanche {
                all[level] = Self.tuckPlancheLevelExercises
            } else if level == .advTuckPlanche {
                all[level] = Self.advTuckPlancheLevelExercises
            } else if level == .straddlePlanche {
                all[level] = Self.straddlePlancheLevelExercises
            } else {
                all[level] = Self.templates.map { t in
                    Exercise(
                        name: t.name,
                        level: level,
                        description: "Perform \(t.name) with proper form and controlled movements.",
                        imageName: t.imageName,
                        spriteConfig: Self.spriteConfigs[t.name],
                        videoName: Self.videoNames[t.name],
                        reps: t.reps,
                        repsByDifficulty: t.repsByDifficulty,
                        durationSeconds: t.durationSeconds,
                        exerciseType: t.type,
                        guide: t.guide
                    )
                }
            }
        }
        exercises = all
    }

    func exercises(for level: Level) -> [Exercise] {
        exercises[level] ?? []
    }

    // MARK: - ADV Tuck Planche Stages

    private static let advTuckPlancheStages: [ExerciseStage] = [
        ExerciseStage(
            name: "Tuck Planche",
            description: "Hold a full tuck planche with both knees pulled tightly to your chest and your hips level with your shoulders. Both feet are completely off the ground.",
            guide: "Push the floor away aggressively and keep your shoulders protracted. Keep your elbows locked and your core maximally braced. Focus on keeping your hips as high as possible.",
            reps: "8s",
            durationSeconds: 8,
            exerciseType: .timed,
            spriteConfig: SpriteConfig(imageName: "sprite-tuck-to-adv-1", frameCount: 9, columns: 3, fps: 2),
            nextStageCondition: "Move to Stage 2 when you can hold the tuck planche for 8 seconds with hips level and controlled breathing."
        ),
        ExerciseStage(
            name: "Advanced Tuck Planche",
            description: "From the tuck position, begin extending your hips back so your back is parallel to the floor. Knees remain tucked but your hips are now pushed back behind your shoulders.",
            guide: "The key difference from the tuck is a flat back — fight to keep your spine horizontal. Squeeze your glutes and push your shoulders forward to counterbalance the extended hip position.",
            reps: "5s",
            durationSeconds: 5,
            exerciseType: .timed,
            spriteConfig: SpriteConfig(imageName: "sprite-tuck-to-adv-2", frameCount: 9, columns: 3, fps: 2),
            nextStageCondition: ""
        ),
    ]

    // MARK: - Tuck Planche Stages

    private static let tuckPlancheStages: [ExerciseStage] = [
        ExerciseStage(
            name: "Tuck Lean and Raise",
            description: "From a push-up position with hands slightly behind shoulders, tuck your knees and lean your entire body forward until your feet naturally lift off the ground. Lower back down with control.",
            guide: "Protract your shoulders (push them forward and apart) before you lean. Think about pushing the floor away, not pulling yourself up. Keep your elbows straight throughout.",
            reps: "5 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-tuck-raise", frameCount: 9, columns: 3, fps: 2),
            nextStageCondition: "Move to Stage 2 when you can raise your feet cleanly and hold for 2–3 seconds on every rep."
        ),
        ExerciseStage(
            name: "Tuck Toes Assisted",
            description: "Hold the tuck planche position with just your toes lightly resting on the floor for balance. Each rep, try to reduce the weight on your toes until they barely touch.",
            guide: "Position your toes a few centimetres behind your feet's natural resting point. As your strength grows, aim for only the lightest tiptoe contact. Fight for balance — the goal is fingertip-level support only.",
            reps: "8 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-tuck-toes-assisted", frameCount: 9, columns: 3, fps: 2),
            nextStageCondition: "Move to Stage 3 when you can hold for 5+ seconds with toes barely touching on every rep."
        ),
        ExerciseStage(
            name: "Tuck Band",
            description: "Loop a resistance band around your waist and anchor it overhead. Hold a full tuck planche with the band absorbing a portion of your bodyweight.",
            imageName: "tuck-parallettes",
            guide: "Use the band as a training tool, not a crutch — still fight for balance and control on every hold. Progress by switching to a thinner band over time.",
            reps: "10s",
            durationSeconds: 10,
            exerciseType: .timed,
            nextStageCondition: "Move to Stage 4 when you can hold 10 seconds without relying on the band for balance."
        ),
        ExerciseStage(
            name: "Tuck Planche",
            description: "Hold a full tuck planche with both feet off the ground, hips high, and shoulders well in front of your wrists. Keep your core fully braced throughout.",
            imageName: "tuck-planche-ground",
            guide: "Push the floor away aggressively and keep your shoulders protracted. Breathe steadily, squeeze your abs, and fix your gaze on a point just ahead of your hands.",
            reps: "5s",
            durationSeconds: 5,
            exerciseType: .timed,
            nextStageCondition: ""
        ),
    ]

    // MARK: - Frog Stand Stages

    private static let frogStandStages: [ExerciseStage] = [
        ExerciseStage(
            name: "Frog Stand Lean",
            description: "Place your hands shoulder-width apart on the floor, crouch down, and rest your knees on the backs of your upper arms. Slowly shift your weight forward onto your hands without lifting your feet.",
            imageName: "frog-stand-lean",
            guide: "Keep wrists directly below shoulders. Engage your core and look slightly forward — not straight down. Focus on feeling the weight transfer.",
            reps: "5 rep",
            exerciseType: .repBased,
            nextStageCondition: "Move to Stage 2 when you can shift your full weight onto your hands for 2–3 seconds without losing balance."
        ),
        ExerciseStage(
            name: "Frog Stand Toe Tap",
            description: "From the Frog Stand Lean position, lightly tap your toes off the ground for a brief moment before returning. This builds confidence in the balance point.",
            guide: "You can tap one or both toes at a time. Keep elbows bent at roughly 90 degrees to create a shelf for your knees. Don't rush — control is everything.",
            reps: "8 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-frog-toe-tap", frameCount: 7, columns: 3, fps: 2),
            nextStageCondition: "Move to Stage 3 when you can lift both feet off the ground cleanly on every rep without wobbling."
        ),
        ExerciseStage(
            name: "Frog Stand Lean and Raise",
            description: "Lean forward until your feet naturally lift off the ground, then hold for 2–3 seconds before lowering back down. Aim to find and hold the balance point each rep.",
            guide: "Push down through the entire palm, not just the fingers. Protract your shoulders slightly for extra stability. Exhale as you lean forward.",
            reps: "5 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-frog-lean-and-raise", frameCount: 8, columns: 4, fps: 2),
            nextStageCondition: "Move to Stage 4 when you can hold the raised position for 3+ seconds on each rep."
        ),
        ExerciseStage(
            name: "Frog Stand Hold",
            description: "Lift both feet completely off the ground and hold the full Frog Stand position for time. Keep your knees pressing firmly against your upper arms for a stable shelf.",
            imageName: "frog-stand",
            guide: "Breathe steadily and squeeze your abs. Fix your gaze on a point on the floor about 30 cm ahead of your hands. Resist the urge to look up.",
            reps: "10s",
            durationSeconds: 10,
            exerciseType: .timed
        )
    ]

}
