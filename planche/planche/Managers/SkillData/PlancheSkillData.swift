import Foundation

// MARK: - Planche Skill Group Data

extension SkillCatalog {

    static let plancheGroup = SkillGroup(
        id: "planche",
        displayName: "Planche",
        iconName: "figure.strengthtraining.traditional",
        description: "Master the planche — from foundational strength to the full hold.",
        skillIDs: ["foundation", "foundation2", "tuckPlanche", "advTuckPlanche", "straddlePlanche", "fullPlanche"]
    )

    static let plancheSkills: [Skill] = [
        Skill(
            id: "foundation",
            groupID: "planche",
            displayName: "Base",
            categoryLabel: "STARTER",

            iconName: "figure.walk",
            description: "Xây dựng sức mạnh nền tảng, chuẩn bị cho mọi skill sau này",
            estimatedTime: "~23 min",
            equipment: "Body weight",
            difficultyStars: 1.0,
            order: 0,
            progressGoalSeconds: 45,
            progressRequirements: ["Body straight from head to heels", "Core braced, hips level", "Arms fully locked"],
            skillPrerequisites: [],
            requirement: nil,
            requiresSubscription: false,
            recommendedPreviousSkillID: nil,
            activeIconImageName: nil,
            deactiveIconImageName: nil
        ),
        Skill(
            id: "foundation2",
            groupID: "planche",
            displayName: "Frog Stand",
            categoryLabel: "BEGINNER",

            iconName: "figure.walk",
            description: "The frog stand is a foundational, beginner-level calisthenics balance skill that builds strength in the shoulders, arms, and core.",
            estimatedTime: "~23 min",
            equipment: "Parallettes",
            difficultyStars: 2.0,
            order: 1,
            progressGoalSeconds: 15,
            progressRequirements: ["Straight arms locked", "Core engaged and tight", "Stable - no falling"],
            skillPrerequisites: ["1 minute plank", "30 push-ups"],
            requirement: nil,
            requiresSubscription: false,
            recommendedPreviousSkillID: nil,
            activeIconImageName: "icon-frog-stand-active",
            deactiveIconImageName: "icon-frog-stand-deactive"
        ),
        Skill(
            id: "tuckPlanche",
            groupID: "planche",
            displayName: "Tuck Planche",
            categoryLabel: "FUNDAMENTAL",

            iconName: "figure.strengthtraining.traditional",
            description: "The Tuck planche is a fundamental calisthenics skill body to the ground, supported by straight arms with knees tucked tightly to the chest.",
            estimatedTime: "~30 min",
            equipment: "Body weight",
            difficultyStars: 2.0,
            order: 2,
            progressGoalSeconds: 10,
            progressRequirements: ["Hips level with shoulders", "Shoulders protracted", "Arms fully locked"],
            skillPrerequisites: ["15s planche lean hold", "50 push-ups"],
            requirement: "You can hold a tuck planche for 10 seconds",
            requiresSubscription: false,
            recommendedPreviousSkillID: "foundation2",
            activeIconImageName: "icon-tuck-planche-active",
            deactiveIconImageName: "icon-tuck-planche-deactive"
        ),
        Skill(
            id: "advTuckPlanche",
            groupID: "planche",
            displayName: "ADV Tuck Planche",
            categoryLabel: "ADVANCED",
            iconName: "figure.highintensity.intervaltraining",
            description: "Body horizontal with legs at 90-degree hip angle. Knees bent outward, no chest compression — more extended than basic tuck.",
            estimatedTime: "~35 min",
            equipment: "Parallettes, Band",
            difficultyStars: 2.5,
            order: 3,
            progressGoalSeconds: 10,
            progressRequirements: ["Back parallel to floor", "Hips pushed back", "Shoulders protracted"],
            skillPrerequisites: ["Hold Tuck Planche 15s"],
            requirement: "You can hold an advanced tuck planche for 10 seconds",
            requiresSubscription: false,
            recommendedPreviousSkillID: "tuckPlanche",
            activeIconImageName: "icon-adv-tuck-planche-active",
            deactiveIconImageName: "icon-adv-tuck-planche-deactive"
        ),
        Skill(
            id: "straddlePlanche",
            groupID: "planche",
            displayName: "Straddle Planche",
            categoryLabel: "PROFESSIONAL",

            iconName: "figure.martial.arts",
            description: "Your entire body parallel to ground with legs straddled wide apart, held in perfect balance on straight extended arms.",
            estimatedTime: "~40 min",
            equipment: "Parallettes",
            difficultyStars: 4.0,
            order: 4,
            progressGoalSeconds: 5,
            progressRequirements: ["Body parallel to ground", "Legs straddled wide", "Arms locked straight"],
            skillPrerequisites: ["Hold ADV Tuck Planche 10s"],
            requirement: "You can hold a straddle planche for 5 seconds",
            requiresSubscription: true,
            recommendedPreviousSkillID: "advTuckPlanche",
            activeIconImageName: "icon-straddle-planche-active",
            deactiveIconImageName: "icon-straddle-planche-deactive"
        ),
        Skill(
            id: "fullPlanche",
            groupID: "planche",
            displayName: "Full Planche",
            categoryLabel: "MASTERY",

            iconName: "crown.fill",
            description: "Body perfectly horizontal, supported only by straight arms. The legendary position that represents the peak of your Planche journey.",
            estimatedTime: "~45 min",
            equipment: "Parallettes",
            difficultyStars: 5.0,
            order: 5,
            progressGoalSeconds: 3,
            progressRequirements: ["Full body parallel", "Legs together, toes pointed", "Arms locked, shoulders protracted"],
            skillPrerequisites: ["Hold Straddle Planche 8s"],
            requirement: "You can hold a full planche for 3 seconds",
            requiresSubscription: true,
            recommendedPreviousSkillID: "straddlePlanche",
            activeIconImageName: "icon-full-planche-active",
            deactiveIconImageName: "icon-full-planche-deactive"
        ),
    ]

    // MARK: - Sprite Configs

    private static let spriteConfigs: [String: SpriteConfig] = [
        "Push-ups": SpriteConfig(imageName: "sprite-push-up", frameCount: 9, columns: 3, fps: 2),
        "Pseudo Planche Push-ups": SpriteConfig(imageName: "sprite-pseudo-planche-pushup", frameCount: 9, columns: 3, fps: 2),
        "Scapular Push-up": SpriteConfig(imageName: "sprite-scapular-push-up", frameCount: 9, columns: 3, fps: 2),
    ]

    private static let videoNames: [String: String] = [
        "Pike Push-ups": "pike-pushup",
    ]

    // MARK: - Foundation Templates

    private static let foundationTemplates: [(name: String, imageName: String, type: ExerciseType, durationSeconds: Int, reps: String, repsByDifficulty: [Difficulty: String], description: String, guide: String, summary: String)] = [
        (
            "Scapular Push-up", "sprite-scapular-push-up", .repBased, 0, "10 rep",
            [.starter: "10 rep", .standard: "10 rep", .solid: "10 rep"],
            "Keep your elbows fully locked throughout — this isolates the scapular movement. Focus on full protraction at the top and full retraction at the bottom. Avoid shrugging your shoulders or letting your hips sag.",
            "Track reps with full retraction and protraction; increase difficulty by slowing each phase to 3 seconds or performing on parallettes. Loop a resistance band across your chest anchored above to assist protraction, or elevate your feet to add difficulty.",
            "Isolates scapular retraction and protraction to build the pushing foundation for planche. Targets the serratus anterior and mid-traps — muscles critical for shoulder protraction. Essential for developing the scapular strength needed to support bodyweight in planche positions."
        ),
        (
            "Plank Hold", "plank-hold", .timed, 30, "30s",
            [.starter: "20s", .standard: "30s", .solid: "45s"],
            "Keep your body in a rigid straight line — no hip sag, no raised butt. Brace your core by drawing your navel toward your spine and squeeze your glutes. Avoid letting your lower back arch or your shoulders creep toward your ears.",
            "Track hold time each session and aim to add 5 seconds per week; increase difficulty by elevating your feet or adding a weight plate on your back. Drop to a knee plank if the full hold is too hard; use a band across your upper back anchored under your hands to challenge shoulder stability.",
            "Builds whole-body tension and straight-line body awareness — the foundation of every planche position. Targets the core, glutes, and shoulders simultaneously. Develops the isometric strength and body alignment needed to hold a rigid horizontal line under load."
        ),
        (
            "Push-ups", "sprite-push-up", .repBased, 0, "10 rep",
            [.starter: "8 rep", .standard: "10 rep", .solid: "14 rep"],
            "Keep your elbows at roughly 45 degrees — not flared wide. Maintain a rigid body line from head to heels and breathe steadily throughout. Avoid sagging hips or letting your head drop forward.",
            "Track total clean reps per session; increase difficulty by elevating your feet, wearing a weight vest, or using a slow 3-second descent. Loop a resistance band across your chest anchored under your hands to reduce load, or stretch one across your upper back to add resistance.",
            "A foundational pressing movement targeting the chest, triceps, and anterior deltoids. Builds horizontal push strength and body tension required for planche progressions. Consistent training develops the pressing power needed to perform planche push-ups."
        ),
        (
            "Pseudo Planche Push-ups", "sprite-pseudo-planche-pushup", .repBased, 0, "8 rep",
            [.starter: "5 rep", .standard: "8 rep", .solid: "12 rep"],
            "Keep your shoulders ahead of your wrists at all times — this is the key technique point. Tuck your elbows tight to your sides throughout the movement. Avoid letting your hips rise or your shoulders drift back behind your wrists.",
            "Track clean reps where your shoulders stay ahead of your wrists; increase difficulty by moving hands lower toward your hips or using a 3-second descent. Loop a resistance band around your waist anchored above to reduce load, or perform on parallettes for greater depth.",
            "Simulates the planche forward lean while building pressing strength. Targets the anterior deltoids, triceps, and serratus anterior under a forward-shifted bodyweight load. A key bridge between standard push-ups and true planche pressing."
        ),
        (
            "Hollow Rock", "hollow-rock", .timed, 5, "5s",
            [.starter: "15s", .standard: "20s", .solid: "30s"],
            "Press your lower back firmly into the floor — there must be no gap at any point. Keep your arms by your ears and legs straight, and breathe steadily. Avoid rocking with momentum; the movement must come entirely from your abs.",
            "Track total rock time per session; increase difficulty by extending arms and legs further out or holding a weight plate overhead. Use bent knees as an easier variation, or place a resistance band around your thighs to increase core demand.",
            "Trains the hollow body position — the core shape required in every planche hold. Targets the rectus abdominis and hip flexors through constant isometric tension. Develops the body compression needed to keep legs elevated without hip sag."
        ),
        (
            "Planche Lean", "planche-lean", .timed, 10, "10s",
            [.starter: "10s", .standard: "10s", .solid: "10s"],
            "Keep your arms fully locked straight — bending the elbows reduces the training effect. Maintain a rigid body line and breathe steadily throughout the hold. Avoid letting your hips pike up or your shoulders round inward.",
            "Track how far your shoulders pass your wrists each session; increase difficulty by leaning further forward or holding longer. Loop a resistance band around your waist anchored above to lighten the load, or elevate your feet to increase difficulty.",
            "Conditions the wrists, shoulders, and core for the forward lean required in planche. Targets the anterior deltoids and serratus anterior under bodyweight load. Progressively overloads the shoulder girdle with the exact lean angle of the planche skill."
        ),
    ]

    // MARK: - Frog Stand Stages

    private static let frogStandStages: [ExerciseStage] = [
        ExerciseStage(
            name: "Frog Stand Lean",
            description: "Keep your wrists directly below your shoulders and look slightly forward — not straight down. Engage your core as your weight shifts onto your hands. Avoid rushing the weight transfer; control is more important than speed.",
            imageName: "frog-stand-lean",
            guide: "Track how long you hold the forward lean before returning; increase difficulty by holding longer and reducing weight on your feet each rep. No bands needed — progress comes from controlled weight transfer.",
            reps: "5 rep",
            exerciseType: .repBased,
            nextStageCondition: "Move to Stage 2 when you can hold the forward lean position for 10–15 seconds with your full weight on your hands.",
            summary: "The entry point for wrist-supported balance training. Targets the wrists, core, and shoulder stabilisers through controlled forward weight transfer. Develops the balance awareness and wrist strength needed to progress into the full frog stand."
        ),
        ExerciseStage(
            name: "Frog Stand Toe Tap",
            description: "Lean forward and lift one foot first — feel the balance before trying the other. Once steady, slowly lift the second foot off the ground. Don't rush — one leg at a time builds real control.",
            guide: "Put a pillow in front of you so falling forward doesn't hurt. Start with one foot, then both; you'll fall, you'll wobble — that's normal, just don't quit.",
            reps: "8 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-frog-toe-tap", frameCount: 7, columns: 3, fps: 2),
            nextStageCondition: "Move to Stage 3 when you can hold both feet off the ground for 4–5 seconds.",
            summary: "Learn to balance on your hands by lifting one leg at a time. Works your wrists, shoulders, and core. A safe way to build up to the full frog stand."
        ),
        ExerciseStage(
            name: "Frog Stand Lean and Raise",
            description: "Press through your entire palm — not just the fingers — for better stability. Slightly protract your shoulders and look slightly forward, not straight down. Avoid looking up or making sudden corrections; find the balance point with small, steady adjustments.",
            guide: "Track how long you hold the raised position each rep — 3 seconds consistently means you're ready for the next stage; push through your entire palm for better stability. No bands needed — this is entirely about balance.",
            reps: "5 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-frog-lean-and-raise", frameCount: 8, columns: 4, fps: 2),
            nextStageCondition: "Move to Stage 4 when you can hold the raised position for 3+ seconds on each rep.",
            summary: "Develops the ability to find and hold the frog stand balance point under control. Targets wrist extensors, serratus anterior, and core stability. Bridges the gap between a partial lean and a full sustained frog stand hold."
        ),
        ExerciseStage(
            name: "Frog Stand Hold",
            description: "Breathe steadily and keep your core engaged — holding your breath causes tension that breaks balance. Fix your gaze on a spot about 30 cm ahead of your hands. Avoid looking up or letting your elbows flare outward.",
            imageName: "frog-stand",
            guide: "Track your longest unbroken hold and add 2–3 seconds per week; increase difficulty by reducing your elbow bend angle or performing on parallettes. No bands needed — progress comes from hold time and wrist strength.",
            reps: "10s",
            durationSeconds: 10,
            exerciseType: .timed,
            summary: "The first full wrist-supported bodyweight balance skill in calisthenics. Targets the wrist extensors, core, and shoulder stabilisers under static hold conditions. Builds the balance, wrist strength, and body awareness that serve as the foundation for all planche progressions."
        ),
    ]

    // MARK: - Tuck Planche Stages

    private static let tuckPlancheStages: [ExerciseStage] = [
        ExerciseStage(
            name: "Tuck Raise Toes Assisted",
            description: "Press actively through your hands and protract your shoulders — don't just balance on your toes. Keep your knees tight to your chest and breathe steadily. Avoid leaning too far forward; your hips should stay level with your shoulders.",
            guide: "Track how lightly your toes touch the floor — the lighter, the better; try to hold completely off the floor for 1–2 seconds per set. Loop a resistance band around your waist anchored above to help maintain elevation as you reduce toe contact.",
            reps: "10 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-tuck-toes-assisted", frameCount: 9, columns: 3, fps: 2),
            nextStageCondition: "Move to Stage 2 when you can hold for 5+ seconds with toes barely touching on every rep.",
            summary: "The closest toe-assisted version of the tuck planche, bridging floor work and air balance. Targets the shoulder girdle and core while relying minimally on ground contact. Builds the pressing strength and balance confidence needed for a fully unsupported tuck planche."
        ),
        ExerciseStage(
            name: "Tuck Planche (Support)",
            description: "Fight for balance even with the band — it assists but doesn't replace your effort. Keep your knees tight to your chest and shoulders protracted. Avoid sitting passively on the band; your hands should be doing most of the pressing work.",
            imageName: "tuck-parallettes",
            guide: "Track your hold time and band thickness each session; progress by switching to thinner bands to reduce assistance. The band should make the hold achievable — not effortless.",
            reps: "15s",
            durationSeconds: 15,
            exerciseType: .timed,
            nextStageCondition: "Move to Stage 3 when you can hold 15 seconds without relying on the band for balance.",
            summary: "A resistance band-assisted tuck planche hold that reduces bodyweight load for strength development. Targets the shoulder girdle, serratus anterior, and core under assisted conditions. Allows practice of correct planche form before full bodyweight is manageable."
        ),
        ExerciseStage(
            name: "Tuck Planche",
            description: "Push the floor away aggressively and keep your shoulders protracted — passive hanging doesn't build the required strength. Keep your knees tight to your chest, core braced, and breathe steadily. Avoid letting your hips drop or your gaze drift downward.",
            imageName: "tuck-planche-ground",
            guide: "Track your hold time and add 1–2 seconds per week; increase difficulty by holding longer or beginning to push your hips backward. Loop a resistance band around your waist anchored above when you can't hold unassisted, and remove it once you hold cleanly for 3+ seconds.",
            reps: "15s",
            durationSeconds: 15,
            exerciseType: .timed,
            nextStageCondition: "",
            summary: "The first fully unassisted tuck planche — both feet off the ground. Targets the shoulder girdle, serratus anterior, and core under full bodyweight. A critical milestone demonstrating the pressing strength and balance needed to advance toward the straddle planche."
        ),
    ]

    // MARK: - ADV Tuck Planche Stages

    private static let advTuckPlancheStages: [ExerciseStage] = [
        ExerciseStage(
            name: "Tuck to ADV hip open",
            description: "Maintain shoulder protraction and arm lock as your hips move back — don't let them slip. Push your shoulders forward to counterbalance the extending hips. Avoid losing elevation; your hips should not drop during the transition.",
            guide: "Track reps where you clearly control the hip open position without wobbling; increase difficulty by adding a 2-second pause in the open position. No band needed — this is a balance and mobility drill.",
            reps: "10 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-tuck-to-adv-1", frameCount: 9, columns: 3, fps: 2),
            nextStageCondition: "Move to Stage 2 when you can control the hip open position on every rep with steady balance.",
            summary: "An active drill teaching the hip extension pattern of the advanced tuck planche. Targets the shoulder girdle and core through controlled hip push-back under load. Develops the body awareness and balance control needed to hold the flat-back advanced tuck position."
        ),
        ExerciseStage(
            name: "Tuck to ADV pump",
            description: "Keep your arms locked and shoulders protracted throughout both positions. The flat-back position is the goal — avoid letting your lower back round as your hips extend. Don't rush; slow transitions build strength more effectively than fast ones.",
            guide: "Track reps with a flat back clearly achieved in the advanced position; increase difficulty by slowing each transition to 3 seconds. Use a resistance band around your waist anchored above if you struggle to maintain the advanced tuck position.",
            reps: "10 rep",
            exerciseType: .repBased,
            spriteConfig: SpriteConfig(imageName: "sprite-tuck-to-adv-2", frameCount: 9, columns: 3, fps: 2),
            nextStageCondition: "",
            summary: "A pump-style drill cycling between tuck and advanced tuck positions to build transition strength. Targets the shoulder girdle and hip flexors through repeated position changes. Develops the endurance and control needed to hold the advanced tuck planche statically."
        ),
    ]

    // MARK: - Exercise Data by Skill

    static let plancheExercises: [String: [Exercise]] = {
        var map: [String: [Exercise]] = [:]

        // Foundation
        map["foundation"] = foundationTemplates.map { t in
            Exercise(
                name: t.name,
                skillID: "foundation",
                description: t.description,
                imageName: t.imageName,
                spriteConfig: spriteConfigs[t.name],
                videoName: videoNames[t.name],
                reps: t.reps,
                repsByDifficulty: t.repsByDifficulty,
                durationSeconds: t.durationSeconds,
                exerciseType: t.type,
                guide: t.guide,
                summary: t.summary
            )
        }

        // Frog Stand
        map["foundation2"] = [
            Exercise(
                name: "Scapular Push-up",
                skillID: "foundation2",
                description: "Lock your elbows straight the entire time — only your shoulder blades should move. Push the ground away at the top, squeeze your shoulder blades together at the bottom. Don't shrug your shoulders or let your hips drop.",
                imageName: "sprite-scapular-push-up",
                spriteConfig: SpriteConfig(imageName: "sprite-scapular-push-up", frameCount: 9, columns: 3, fps: 2),
                reps: "10 rep",
                repsByDifficulty: [.starter: "10 rep", .standard: "10 rep", .solid: "10 rep"],
                exerciseType: .repBased,
                guide: "Slow each rep down to 3 seconds up, 3 seconds down to really feel it working. If it's too easy, elevate your feet to add more load.",
                sets: 3,
                summary: "A push-up where only your shoulder blades move — your arms stay locked straight. Works the muscles around your shoulder blades and upper back. Great for learning how to control your shoulders independently."
            ),
            Exercise(
                name: "Planche Lean",
                skillID: "foundation2",
                description: "Keep your arms completely straight — bent elbows take the work away from your shoulders. Lean forward until your shoulders pass your wrists, and hold. Don't let your hips pike up or your back round.",
                imageName: "planche-lean",
                reps: "15s",
                repsByDifficulty: [.starter: "15s", .standard: "15s", .solid: "15s"],
                durationSeconds: 15,
                exerciseType: .timed,
                guide: "Mark where your shoulders reach past your wrists and try to beat it next session. Start with a small lean and add distance as your wrists get stronger.",
                sets: 3,
                summary: "A plank position where you lean your weight forward past your wrists. Works your wrists, shoulders, and core under heavy load. The further you lean, the more your shoulders and wrists have to work."
            ),
            Exercise(
                name: "Pseudo Planche Push-ups",
                skillID: "foundation2",
                description: "Keep your shoulders ahead of your wrists the whole time — that's the whole point. Tuck your elbows close to your body as you go down and up. Don't let your hips rise or your shoulders drift backward.",
                imageName: "sprite-pseudo-planche-pushup",
                spriteConfig: SpriteConfig(imageName: "sprite-pseudo-planche-pushup", frameCount: 9, columns: 3, fps: 2),
                reps: "5 rep",
                repsByDifficulty: [.starter: "5 rep", .standard: "8 rep", .solid: "10 rep"],
                exerciseType: .repBased,
                guide: "Move your hands closer to your hips to make it harder, or closer to your shoulders to make it easier. Try a 3-second descent to build more strength in the bottom position.",
                sets: 3,
                summary: "A push-up with your hands placed further back toward your hips. Works your front shoulders, triceps, and chest with more shoulder load than a normal push-up. The hand position shifts your bodyweight forward, making your shoulders work harder."
            ),
            Exercise(
                name: "Pike Push-ups",
                skillID: "foundation2",
                description: "Keep your hips as high as possible — the steeper the angle, the harder your shoulders work. Lower the top of your head toward the floor between your hands. Don't drop your hips or push your head forward.",
                imageName: "sprite-pike-pushup",
                spriteConfig: SpriteConfig(imageName: "sprite-pike-pushup", frameCount: 9, columns: 3, fps: 2),
                reps: "8 rep",
                repsByDifficulty: [.starter: "8 rep", .standard: "10 rep", .solid: "12 rep"],
                exerciseType: .repBased,
                guide: "Put your feet on a box or step to make it harder — more height means more shoulder load. If you can't reach the floor yet, use a smaller range and build up over time.",
                sets: 3,
                summary: "A push-up with your hips high in the air, forming an upside-down V shape. Works your shoulders, triceps, and upper back. The steep angle puts most of the load on your shoulders instead of your chest."
            ),
            Exercise(
                name: "Hollow Rock",
                skillID: "foundation2",
                description: "Press your lower back flat into the floor — no gap, ever. Keep your arms by your ears and legs straight while you rock. Don't use momentum — your abs should do all the work.",
                imageName: "hollow-rock",
                reps: "15s",
                repsByDifficulty: [.starter: "15s", .standard: "15s", .solid: "15s"],
                durationSeconds: 15,
                exerciseType: .timed,
                guide: "Bend your knees if you can't keep your lower back flat — that's the easier version. Add time each week; when 30 seconds feels easy, hold a weight plate overhead.",
                sets: 3,
                summary: "A rocking movement on your back with arms and legs extended. Works your abs and hip flexors through constant tension. Teaches your body to stay tight and curved like a banana shape."
            ),
            Exercise(
                name: "Frog Stand",
                skillID: "foundation2",
                description: "A foundational balance skill. Select a stage that matches your current level and work through all four progressively.",
                imageName: "frog-stand-lean",
                sets: 3,
                stages: frogStandStages
            ),
        ]

        // Tuck Planche
        map["tuckPlanche"] = [
            Exercise(
                name: "Planche Lean",
                skillID: "tuckPlanche",
                description: "Keep your arms fully locked straight — bending the elbows reduces the training effect. Maintain a rigid body line and breathe steadily throughout the hold. Avoid letting your hips pike up or your shoulders round inward.",
                imageName: "planche-lean",
                reps: "15s",
                repsByDifficulty: [.starter: "15s", .standard: "15s", .solid: "15s"],
                durationSeconds: 15,
                exerciseType: .timed,
                guide: "Track how far your shoulders pass your wrists each session; increase difficulty by leaning further forward or holding longer. Loop a resistance band around your waist anchored above to lighten the load, or elevate your feet to increase difficulty.",
                sets: 3,
                summary: "Conditions the wrists, shoulders, and core for the forward lean required in planche. Targets the anterior deltoids and serratus anterior under bodyweight load. Progressively overloads the shoulder girdle with the exact lean angle of the planche skill."
            ),
            Exercise(
                name: "Pike Push-ups",
                skillID: "tuckPlanche",
                description: "Keep your hips high throughout — the steeper your angle, the more shoulder load you get. Lower the top of your head toward the floor and track your elbows slightly outward, not fully flared. Avoid dropping your hips during the movement or pushing your head forward instead of down.",
                imageName: "sprite-pike-pushup",
                spriteConfig: SpriteConfig(imageName: "sprite-pike-pushup", frameCount: 9, columns: 3, fps: 2),
                reps: "10 rep",
                repsByDifficulty: [.starter: "8 rep", .standard: "10 rep", .solid: "12 rep"],
                exerciseType: .repBased,
                guide: "Track reps with full depth — head nearly touching the floor; increase difficulty by elevating your feet on a box. Loop a resistance band across your upper back anchored under your hands to assist the press, or progress to deficit pike push-ups on parallettes.",
                sets: 3,
                summary: "A vertical pressing movement targeting the shoulders, triceps, and upper back. Builds the overhead strength required for handstands and handstand push-ups. The steep body angle shifts load onto the deltoids, making it a key progression toward overhead skills."
            ),
            Exercise(
                name: "Hollow Rock",
                skillID: "tuckPlanche",
                description: "Press your lower back firmly into the floor — there must be no gap at any point. Keep your arms by your ears and legs straight, and breathe steadily. Avoid rocking with momentum; the movement must come entirely from your abs.",
                imageName: "hollow-rock",
                reps: "15s",
                repsByDifficulty: [.starter: "15s", .standard: "15s", .solid: "15s"],
                durationSeconds: 15,
                exerciseType: .timed,
                guide: "Track total rock time per session; increase difficulty by extending arms and legs further out or holding a weight plate overhead. Use bent knees as an easier variation, or place a resistance band around your thighs to increase core demand.",
                sets: 3,
                summary: "Trains the hollow body position — the core shape required in every planche hold. Targets the rectus abdominis and hip flexors through constant isometric tension. Develops the body compression needed to keep legs elevated without hip sag."
            ),
            Exercise(
                name: "Pseudo Planche Push-ups",
                skillID: "tuckPlanche",
                description: "Keep your shoulders ahead of your wrists at all times — this is the key technique point. Tuck your elbows tight to your sides throughout the movement. Avoid letting your hips rise or your shoulders drift back behind your wrists.",
                imageName: "sprite-pseudo-planche-pushup",
                spriteConfig: SpriteConfig(imageName: "sprite-pseudo-planche-pushup", frameCount: 9, columns: 3, fps: 2),
                reps: "10 rep",
                repsByDifficulty: [.starter: "8 rep", .standard: "10 rep", .solid: "12 rep"],
                exerciseType: .repBased,
                guide: "Track clean reps where your shoulders stay ahead of your wrists; increase difficulty by moving hands lower toward your hips or using a 3-second descent. Loop a resistance band around your waist anchored above to reduce load, or perform on parallettes for greater depth.",
                sets: 3,
                summary: "Simulates the planche forward lean while building pressing strength. Targets the anterior deltoids, triceps, and serratus anterior under a forward-shifted bodyweight load. A key bridge between standard push-ups and true planche pressing."
            ),
            Exercise(
                name: "Tuck Sit Swing",
                skillID: "tuckPlanche",
                description: "Drive the swing from your core — not momentum. Keep your core tight and control the arc in both directions equally. Avoid letting the swing become passive; every rep should feel intentional and deliberate.",
                imageName: "sprite-tuck-sit-swing",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-sit-swing", frameCount: 9, columns: 3, fps: 2),
                reps: "8 rep",
                exerciseType: .repBased,
                guide: "Track reps where the forward lean clearly passes your wrists; increase difficulty by pausing 2 seconds at each end. Loop a resistance band around your waist anchored above to practice the forward lean depth safely.",
                sets: 3,
                summary: "Develops dynamic transition control between the tuck sit and forward lean positions. Targets the core, hip flexors, and shoulder stabilisers through rhythmic controlled movement. Builds the swing mechanics used in more advanced planche transitions on parallettes."
            ),
            Exercise(
                name: "Planche Lean Drag to Tuck Planche",
                skillID: "tuckPlanche",
                description: "Keep your arms straight throughout the drag and hold phases — bending the elbows turns this into a different exercise. Protract your shoulders actively as your knees come in. Avoid piking your hips too high; aim to keep them level with your shoulders.",
                imageName: "sprite-planche-lean-drag-tuck",
                spriteConfig: SpriteConfig(imageName: "sprite-planche-lean-drag-tuck", frameCount: 9, columns: 3, fps: 2),
                reps: "8 rep",
                exerciseType: .repBased,
                guide: "Track reps where you hold the tuck for at least 2 seconds before lowering; increase difficulty by extending the hold to 5 seconds or slowing the drag to 4 seconds. Loop a resistance band around your waist anchored above to assist the lift-off phase.",
                sets: 3,
                summary: "Bridges the gap between a floor-level lean and a full tuck planche. Targets the shoulder girdle, core, and hip flexors in a coordinated pull-through movement. Develops the proprioception and strength needed to transition into the tuck planche from a lean."
            ),
            Exercise(
                name: "Tuck Planche",
                skillID: "tuckPlanche",
                description: "A staged progression toward the tuck planche. Select the stage that matches your current ability and work through all stages progressively.",
                imageName: "tuck-planche-ground",
                sets: 3,
                stages: tuckPlancheStages
            ),
        ]

        // ADV Tuck Planche
        map["advTuckPlanche"] = [
            Exercise(
                name: "Planche Lean",
                skillID: "advTuckPlanche",
                description: "Keep your arms fully locked straight — bending the elbows reduces the training effect. Maintain a rigid body line and breathe steadily throughout the hold. Avoid letting your hips pike up or your shoulders round inward.",
                imageName: "planche-lean",
                reps: "20s",
                repsByDifficulty: [.starter: "20s", .standard: "20s", .solid: "20s"],
                durationSeconds: 20,
                exerciseType: .timed,
                guide: "Track how far your shoulders pass your wrists each session; increase difficulty by leaning further forward or holding longer. Loop a resistance band around your waist anchored above to lighten the load, or elevate your feet to increase difficulty.",
                sets: 3,
                summary: "Conditions the wrists, shoulders, and core for the forward lean required in planche. Targets the anterior deltoids and serratus anterior under bodyweight load. Progressively overloads the shoulder girdle with the exact lean angle of the planche skill."
            ),
            Exercise(
                name: "Handstand Hold (Wall)",
                skillID: "advTuckPlanche",
                description: "Stack your wrists, shoulders, and hips in one vertical line and press actively through your fingertips. Squeeze your glutes, engage your core, and breathe steadily throughout. Avoid arching your lower back or letting your legs drift apart.",
                imageName: "handstand-hold-wall",
                reps: "15s",
                repsByDifficulty: [.starter: "15s", .standard: "15s", .solid: "15s"],
                durationSeconds: 15,
                exerciseType: .timed,
                guide: "Track your longest unbroken hold and add 2–3 seconds per week; increase difficulty by reducing wall contact to fingertips only, building toward freestanding. Loop a resistance band around your hips overhead to assist freestanding balance practice.",
                sets: 3,
                summary: "An inverted isometric hold targeting the shoulders, triceps, and core under full bodyweight. Builds the overhead pushing endurance and straight-body tension required for freestanding handstands. Develops the shoulder stability critical for both handstand and planche skills."
            ),
            Exercise(
                name: "Tuck Planche Push-up",
                skillID: "advTuckPlanche",
                description: "Maintain the tuck position throughout — don't let your hips drop or legs extend during the push. Keep your elbows close to your sides and push through your full palm. Avoid rushing the descent; control is more important than rep count.",
                imageName: "sprite-tuck-planche-pushup",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-planche-pushup", frameCount: 9, columns: 3, fps: 2),
                reps: "7 rep",
                exerciseType: .repBased,
                guide: "Track clean reps where the tuck holds throughout; increase difficulty by slowing the descent to 4 seconds or adding a 2-second pause at the bottom. Loop a resistance band around your waist anchored above to reduce load.",
                sets: 3,
                summary: "A planche-specific pressing movement with legs tucked to the chest. Targets the anterior deltoids, triceps, and serratus anterior under maximum forward lean. Builds the pushing strength required to progress toward straddle and full planche push-ups."
            ),
            Exercise(
                name: "L-Sit Hold",
                skillID: "advTuckPlanche",
                description: "Press actively through both handles — passive resting won't build the strength needed. Keep your legs fully extended with toes pointed and thighs clear of the handles. Avoid letting your shoulders rise toward your ears.",
                imageName: "l-sit-hold",
                reps: "20s",
                repsByDifficulty: [.starter: "20s", .standard: "20s", .solid: "20s"],
                durationSeconds: 20,
                exerciseType: .timed,
                guide: "Track your longest unbroken hold and add 2–3 seconds per week; build up from a tucked L-Sit before extending fully. Loop a resistance band around a pull-up bar and pass it under your thighs to support your hips, or add ankle weights to increase difficulty.",
                sets: 3,
                summary: "An isometric compression hold targeting the triceps, hip flexors, and core. Builds the pushing and compression strength needed to support bodyweight on parallettes. Develops the pressing endurance and body tension that carry directly into planche work."
            ),
            Exercise(
                name: "Tuck Sit Swing",
                skillID: "advTuckPlanche",
                description: "Drive the swing from your core — not momentum. Keep your core tight and control the arc in both directions equally. Avoid letting the swing become passive; every rep should feel intentional and deliberate.",
                imageName: "sprite-tuck-sit-swing",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-sit-swing", frameCount: 9, columns: 3, fps: 2),
                reps: "12 rep",
                exerciseType: .repBased,
                guide: "Track reps where the forward lean clearly passes your wrists; increase difficulty by pausing 2 seconds at each end. Loop a resistance band around your waist anchored above to practice the forward lean depth safely.",
                sets: 3,
                summary: "Develops dynamic transition control between the tuck sit and forward lean positions. Targets the core, hip flexors, and shoulder stabilisers through rhythmic controlled movement. Builds the swing mechanics used in more advanced planche transitions on parallettes."
            ),
            Exercise(
                name: "Handstand Push-up (Wall)",
                skillID: "advTuckPlanche",
                description: "Keep your body in a straight line — squeeze your glutes and brace your core throughout. Lower under control with elbows tracking slightly outward, not flaring wide. Avoid arching your lower back or letting your head push forward rather than straight down.",
                imageName: "sprite-handstand-pushup-wall",
                spriteConfig: SpriteConfig(imageName: "sprite-handstand-pushup-wall", frameCount: 9, columns: 3, fps: 2),
                reps: "8 rep",
                exerciseType: .repBased,
                guide: "Track clean reps with full range of motion — head nearly touching the floor; increase difficulty by using a deficit on parallettes or slowing the descent. Loop a resistance band around your waist anchored above to reduce bodyweight when you can't complete full reps.",
                sets: 3,
                summary: "A vertical pressing movement in an inverted position targeting the deltoids, triceps, and upper traps. Builds the overhead strength required for freestanding handstand push-ups. Develops pressing power, body tension, and scapular stability for advanced overhead skills."
            ),
            Exercise(
                name: "Tuck to ADV Tuck Planche",
                skillID: "advTuckPlanche",
                description: "A staged progression from the tuck planche to the advanced tuck planche. Work through both stages progressively.",
                imageName: "sprite-tuck-to-adv-1",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-to-adv-1", frameCount: 9, columns: 3, fps: 2),
                sets: 3,
                stages: advTuckPlancheStages
            ),
        ]

        // Straddle Planche
        map["straddlePlanche"] = [
            Exercise(
                name: "Straddle Planche Lean",
                skillID: "straddlePlanche",
                description: "Keep your arms fully locked and shoulders protracted throughout the lean. Maintain a flat back — avoid letting your hips pike upward. Breathe steadily and don't hold your breath during the hold.",
                imageName: "straddle-lean",
                reps: "15s",
                repsByDifficulty: [.starter: "15s", .standard: "15s", .solid: "15s"],
                durationSeconds: 15,
                exerciseType: .timed,
                guide: "Track how far your shoulders extend past your wrists each session; increase difficulty by leaning further or working toward lifting your feet off the floor. Loop a resistance band around your waist anchored above to reduce load at extreme lean angles.",
                sets: 3,
                summary: "A straddle-specific forward lean targeting the shoulders and serratus anterior under wide-leg load. Develops the protraction strength and lean depth required to progress into the straddle planche. Wider legs reduce load compared to a full planche lean."
            ),
            Exercise(
                name: "Handstand Push-up (Wall)",
                skillID: "straddlePlanche",
                description: "Keep your body in a straight line — squeeze your glutes and brace your core throughout. Lower under control with elbows tracking slightly outward, not flaring wide. Avoid arching your lower back or letting your head push forward rather than straight down.",
                imageName: "sprite-handstand-pushup-wall",
                spriteConfig: SpriteConfig(imageName: "sprite-handstand-pushup-wall", frameCount: 9, columns: 3, fps: 2),
                reps: "10 rep",
                exerciseType: .repBased,
                guide: "Track clean reps with full range of motion — head nearly touching the floor; increase difficulty by using a deficit on parallettes or slowing the descent. Loop a resistance band around your waist anchored above to reduce bodyweight when you can't complete full reps.",
                sets: 3,
                summary: "A vertical pressing movement in an inverted position targeting the deltoids, triceps, and upper traps. Builds the overhead strength required for freestanding handstand push-ups. Develops pressing power, body tension, and scapular stability for advanced overhead skills."
            ),
            Exercise(
                name: "Handstand Hold (Wall)",
                skillID: "straddlePlanche",
                description: "Stack your wrists, shoulders, and hips in one vertical line and press actively through your fingertips. Squeeze your glutes, engage your core, and breathe steadily throughout. Avoid arching your lower back or letting your legs drift apart.",
                imageName: "handstand-hold-wall",
                reps: "15s",
                repsByDifficulty: [.starter: "15s", .standard: "15s", .solid: "15s"],
                durationSeconds: 15,
                exerciseType: .timed,
                guide: "Track your longest unbroken hold and add 2–3 seconds per week; increase difficulty by reducing wall contact to fingertips only, building toward freestanding. Loop a resistance band around your hips overhead to assist freestanding balance practice.",
                sets: 2,
                summary: "An inverted isometric hold targeting the shoulders, triceps, and core under full bodyweight. Builds the overhead pushing endurance and straight-body tension required for freestanding handstands. Develops the shoulder stability critical for both handstand and planche skills."
            ),
            Exercise(
                name: "Tuck Pushup to Straddle Planche Pushup",
                skillID: "straddlePlanche",
                description: "Maintain shoulder protraction and hips elevated through both the tuck and straddle positions. Control the leg extension — don't let your hips drop during the transition to straddle. Avoid collapsing at the top of the press.",
                imageName: "sprite-tuck-pushup-to-straddle",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-pushup-to-straddle", frameCount: 12, columns: 3, fps: 2),
                reps: "5 rep",
                exerciseType: .repBased,
                guide: "Track clean reps where both the tuck descent and straddle hold are clear; increase difficulty by holding the straddle for 2–3 seconds or slowing the descent to 4 seconds. Loop a resistance band around your waist anchored above to assist when you can't maintain elevation.",
                sets: 3,
                summary: "Combines a tuck planche push-up with a straddle extension at the top of each rep. Targets the anterior deltoids, triceps, and serratus anterior through a dynamic press-and-extend pattern. Builds the power and body control needed to progress toward full planche push-ups."
            ),
            Exercise(
                name: "ADV Tuck Hold",
                skillID: "straddlePlanche",
                description: "Push your hips as far back as possible while keeping your back parallel to the floor — this flat spine is the defining form cue. Shoulders must be maximally protracted and arms locked straight. Avoid letting your hips rise above shoulder level or your lower back round.",
                imageName: "adv-tuck-planche-hold",
                reps: "10s",
                repsByDifficulty: [.starter: "10s", .standard: "10s", .solid: "10s"],
                durationSeconds: 10,
                exerciseType: .timed,
                guide: "Track your hold time and add 1–2 seconds per week; increase difficulty by gradually pushing your hips further back toward a straddle. Loop a resistance band around your waist anchored above to reduce load when you can't hold the flat-back position.",
                sets: 3,
                summary: "An isometric hold with the back parallel to the floor — a key planche milestone. Targets the shoulder girdle, core, and hip flexors under maximum horizontal bodyweight load. Develops the scapular protraction and body tension required for the straddle planche."
            ),
            Exercise(
                name: "ADV Tuck to Straddle Planche",
                skillID: "straddlePlanche",
                description: "Maintain shoulder protraction and arm lock throughout the entire transition — don't let them slip as your legs move. Extend one leg at a time with control. Avoid dropping your hips during the leg extension; elevation must be maintained throughout.",
                imageName: "sprite-adv-tuck-to-straddle",
                spriteConfig: SpriteConfig(imageName: "sprite-adv-tuck-to-straddle", frameCount: 9, columns: 3, fps: 2),
                reps: "5 rep",
                exerciseType: .repBased,
                guide: "Track reps where both the ADV tuck and straddle positions are clearly held; increase difficulty by pausing 2 seconds in the straddle or extending both legs simultaneously. Loop a resistance band around your waist anchored above when you can't maintain elevation through the transition.",
                sets: 3,
                summary: "A dynamic transition from advanced tuck to straddle planche. Targets the shoulder girdle and core through controlled leg extension under load. Develops the proprioception and strength needed to bridge the gap to the full planche."
            ),
            Exercise(
                name: "Straddle Planche Hold",
                skillID: "straddlePlanche",
                description: "Keep your shoulders maximally protracted and arms fully locked throughout — any elbow bend kills the hold. Breathe steadily and maintain tension in your core and glutes. Avoid letting your hips sag below shoulder level.",
                imageName: "straddle-planche-hold",
                reps: "5s",
                repsByDifficulty: [.starter: "5s", .standard: "5s", .solid: "5s"],
                durationSeconds: 5,
                exerciseType: .timed,
                guide: "Track your hold time — even 1 extra second per week is excellent progress; increase difficulty by gradually bringing your legs closer together toward a full planche. Loop a resistance band around your waist anchored above to support your hips.",
                sets: 3,
                summary: "An elite static hold with the body parallel to the ground and legs straddled wide. Targets the entire shoulder girdle, core, and glutes under near-maximum bodyweight load. Develops the extreme scapular protraction and body tension required for the full planche."
            ),
        ]

        // Full Planche
        map["fullPlanche"] = [
            Exercise(
                name: "Planche Lean",
                skillID: "fullPlanche",
                description: "Keep your arms fully locked straight — bending the elbows reduces the training effect. Maintain a rigid body line and breathe steadily throughout the hold. Avoid letting your hips pike up or your shoulders round inward.",
                imageName: "planche-lean",
                reps: "20s",
                repsByDifficulty: [.starter: "20s", .standard: "20s", .solid: "20s"],
                durationSeconds: 20,
                exerciseType: .timed,
                guide: "Track how far your shoulders pass your wrists each session; increase difficulty by leaning further forward or holding longer. Loop a resistance band around your waist anchored above to lighten the load, or elevate your feet to increase difficulty.",
                sets: 3,
                summary: "Conditions the wrists, shoulders, and core for the forward lean required in planche. Targets the anterior deltoids and serratus anterior under bodyweight load. Progressively overloads the shoulder girdle with the exact lean angle of the planche skill."
            ),
            Exercise(
                name: "Handstand Push-up (Wall)",
                skillID: "fullPlanche",
                description: "Keep your body in a straight line — squeeze your glutes and brace your core throughout. Lower under control with elbows tracking slightly outward, not flaring wide. Avoid arching your lower back or letting your head push forward rather than straight down.",
                imageName: "sprite-handstand-pushup-wall",
                spriteConfig: SpriteConfig(imageName: "sprite-handstand-pushup-wall", frameCount: 9, columns: 3, fps: 2),
                reps: "5 rep",
                exerciseType: .repBased,
                guide: "Track clean reps with full range of motion — head nearly touching the floor; increase difficulty by using a deficit on parallettes or slowing the descent. Loop a resistance band around your waist anchored above to reduce bodyweight when you can't complete full reps.",
                sets: 3,
                summary: "A vertical pressing movement in an inverted position targeting the deltoids, triceps, and upper traps. Builds the overhead strength required for freestanding handstand push-ups. Develops pressing power, body tension, and scapular stability for advanced overhead skills."
            ),
            Exercise(
                name: "Handstand Hold (Wall)",
                skillID: "fullPlanche",
                description: "Stack your wrists, shoulders, and hips in one vertical line and press actively through your fingertips. Squeeze your glutes, engage your core, and breathe steadily throughout. Avoid arching your lower back or letting your legs drift apart.",
                imageName: "handstand-hold-wall",
                reps: "20s",
                repsByDifficulty: [.starter: "20s", .standard: "20s", .solid: "20s"],
                durationSeconds: 20,
                exerciseType: .timed,
                guide: "Track your longest unbroken hold and add 2–3 seconds per week; increase difficulty by reducing wall contact to fingertips only, building toward freestanding. Loop a resistance band around your hips overhead to assist freestanding balance practice.",
                sets: 3,
                summary: "An inverted isometric hold targeting the shoulders, triceps, and core under full bodyweight. Builds the overhead pushing endurance and straight-body tension required for freestanding handstands. Develops the shoulder stability critical for both handstand and planche skills."
            ),
            Exercise(
                name: "Tuck Pushup to Straddle Planche Pushup",
                skillID: "fullPlanche",
                description: "Maintain shoulder protraction and hips elevated through both the tuck and straddle positions. Control the leg extension — don't let your hips drop during the transition to straddle. Avoid collapsing at the top of the press.",
                imageName: "sprite-tuck-pushup-to-straddle",
                spriteConfig: SpriteConfig(imageName: "sprite-tuck-pushup-to-straddle", frameCount: 12, columns: 3, fps: 2),
                reps: "5 rep",
                exerciseType: .repBased,
                guide: "Track clean reps where both the tuck descent and straddle hold are clear; increase difficulty by holding the straddle for 2–3 seconds or slowing the descent to 4 seconds. Loop a resistance band around your waist anchored above to assist when you can't maintain elevation.",
                sets: 3,
                summary: "Combines a tuck planche push-up with a straddle extension at the top of each rep. Targets the anterior deltoids, triceps, and serratus anterior through a dynamic press-and-extend pattern. Builds the power and body control needed to progress toward full planche push-ups."
            ),
            Exercise(
                name: "Planche Lean Raise",
                skillID: "fullPlanche",
                description: "Keep your arms fully locked — any elbow bend reduces the training stimulus. Protract your shoulders maximally before initiating the raise. Avoid letting your hips pike upward; the body should rise as one rigid unit.",
                imageName: "sprite-planche-lean-raise",
                spriteConfig: SpriteConfig(imageName: "sprite-planche-lean-raise", frameCount: 12, columns: 3, fps: 2),
                reps: "5 rep",
                exerciseType: .repBased,
                guide: "Track reps where your feet clearly leave the ground with arms locked; increase difficulty by holding the raised position for 2–3 seconds. Loop a resistance band around your waist anchored above to practice the lift-off before you have full strength.",
                sets: 3,
                summary: "A dynamic lean where the feet lift at maximum forward shoulder position. Targets the anterior deltoids and serratus anterior under peak bodyweight load. Develops the transition strength needed to press into a full planche hold."
            ),
            Exercise(
                name: "Straddle Planche Hold",
                skillID: "fullPlanche",
                description: "Keep your shoulders maximally protracted and arms fully locked throughout — any elbow bend kills the hold. Breathe steadily and maintain tension in your core and glutes. Avoid letting your hips sag below shoulder level.",
                imageName: "straddle-planche-hold",
                reps: "5s",
                repsByDifficulty: [.starter: "5s", .standard: "5s", .solid: "5s"],
                durationSeconds: 5,
                exerciseType: .timed,
                guide: "Track your hold time — even 1 extra second per week is excellent progress; increase difficulty by gradually bringing your legs closer together toward a full planche. Loop a resistance band around your waist anchored above to support your hips.",
                sets: 3,
                summary: "An elite static hold with the body parallel to the ground and legs straddled wide. Targets the entire shoulder girdle, core, and glutes under near-maximum bodyweight load. Develops the extreme scapular protraction and body tension required for the full planche."
            ),
            Exercise(
                name: "Full Planche Hold",
                skillID: "fullPlanche",
                description: "Keep your entire body in one straight line — hips level with shoulders, legs together, toes pointed. Shoulders must be maximally protracted and arms fully locked; breathe steadily. Avoid letting your hips sag or your head drop forward.",
                imageName: "figure.gymnastics",
                reps: "5s",
                durationSeconds: 5,
                exerciseType: .timed,
                guide: "Track your hold time — adding even 1 second per week is significant progress; increase difficulty by extending hold time or progressing toward a full planche push-up. Loop a resistance band around your waist anchored above to support your hips, and remove it gradually as strength improves.",
                sets: 3,
                summary: "The pinnacle static hold — entire body parallel to the ground on straight arms. Targets the shoulder girdle, core, and glutes under maximum bodyweight load. Requires extreme scapular protraction and body tension developed across all preceding levels."
            ),
        ]

        return map
    }()
}
