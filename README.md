# Fleets and Worlds: Andromeda
(Game Design Document)

## Game Concept

A tactical space battle game focused on cinematic fleet engagements where the player acts as a Grand Admiral. The player sets strategic goals, doctrines, and fleet composition, then watches as AI-controlled admirals execute the battle. 

Core gameplay is about planning and ship/fleet design within a minimal 4X layer—no micromanagement, just chill and watch smart systems doing their thing.
## Core Ideas

- Cinematic Battles: Engaging, movie-like battles with minimal player input during combat.
- Strategic Planning: Players make impactful decisions before combat begins.
- Expert Systems AI: Fleet behavior is governed by layered AI logic that simulates intelligent command behavior.
- Meaningful Constraints: Limited mid-battle commands ensure tension and consequence.

## Implementation

Quick and cheap, for fast prototyping:
- Godot, plus custom gdscript: expert systems engine, minimal yaml parser
- Crude AI generated visuals, bare-bones very minimalistic effects

Simple minimalistic ideas that work:
- Campaign like Gratuitous space battles
- Ship designs like Sid Meiers Alpha Centauri


## Planned Feature Set

| **Category**               | **Prototype**                                                          | **Future**                                                         |
| -------------------------- | ---------------------------------------------------------------------- | -------------------------------------------------------------------|
| **Map / Systems**          | Network of star systems, fixed resources.      | Add system types (e.g. academy, shipyard), chokepoints, random terrain effects.            |
| **Resources**              | Materials, Supply.                             | Add Personnel (crew), Work (industrial capacity), local production limits.                 |
| **Galaxy AI**              | Chance to attack, parity fleets                | Smarter AI with defense priorities, personalities, response to tech or terrain.            |
| **Fleet Combat**           | Move toward enemy, simple damage rules.        | Add rules for formation, targeting priority, range, terrain effects.                       |
| **Ship Design**            | Chassis + 1–2 fixed weapons.                   | Full modular design: weapons, defenses, utility. Component interactions (e.g. rock-paper). |
| **Combat Roles**           | All-purpose ships.                             | Specialization: missile boat, tank, scout, drone carrier, etc.                             |
| **Weapons**                | Basic damage-dealing module.                   | Rock-paper-scissors: lasers, missiles, railguns vs shields, armor, PDC.                    |
| **Defenses**               | Static HP.                                     | Shields, armor, PDC, terrain-based modifiers.                                              |
| **Tech Tree**              | Linear unlock of new ship components.          | SMAC-style prototyping (expensive first build), cost reduction over time, branching paths. |
| **Prototyping**            | Not implemented.                               | First-time builds cost extra; standard after that; reduced costs at later tech levels.     |
| **Strategic Layer**        | Capture systems for more production.           | Minefields, battlestations, sensor arrays, repair stations.                                |
| **System Effects**         | None.                                          | Per-system terrain (e.g. nebula = no shields, asteroid = low accuracy).                    |
| **Ship Production**        | Instant spawn with cost deduction.             | Queues, production time, workforce limits.                                                 |
| **Unit Spam (SMAC-style)** | Basic scout ships, cheap to produce.           | Use weak, fast units for harassment, recon, distraction tactics.                           |
| **Command Hierarchy**      | None.                                          | Layered AI control: Admiral → Squad Leader → Captain, with different logic levels.         |
| **Scouting / Intel**       | Full visibility.                               | Fog of war, sensors, cloaking, detection modules.                                          |
| **Autoresolve Battles**    | No visuals, combat at 20x speed.               | ML trained on thousands of random battles                                                  |
| **Fleet Composition**      | Random up to parity                            | Templates with light weightings, successful fleets from testing runs                       |

## Pre-Battle Setup Examples

- Fleet Composition: Mix of roles like scouts, screens, capitals, interceptors, reserves.
- Mission Objective: Annihilation, Denial, Breakthrough, Hit & Run, or Delay.
- Loss Tolerance: High (fight to the end), Medium (e.g. 40% losses), or Low (abort early).
- Doctrine / ROE: Aggressive, Cautious, Balanced, Harassment, or Adaptive (advanced AI).
- Resource Limits: Missile policy, fuel range, reserve commitment rules.
- Formation: Choose or customize layouts (Line, Wedge, Pincer, etc.) and assign zones (core, screen, flank, reserve).

## In-Battle Commands Examples

 Cooldown: 30sec or limited uses per engagement.

- Retreat: Orderly / Panic Run
- Commit Reserves: 1/3, 2/3, or All
- Change Formation: Switch to alternative pre-selected layout
- Push Forward: Cautious / Aggressive
- Reform: Pull back and regroup

## Emergent Needs (Driven by Fog of War, Tactics)

- Recon / Counter-Recon / Recon-in-Force
- Anti-spotter pickets
- Flank denial and area control
- Fast-response squads and tactical reserves
- Target prioritization and dynamic formation shifts

## Layered AI

### AI Design Goals

Define all AI logic in YAML (rules, actions, goals, doctrine).

- Allow ships and fleets to pursue goals, not just react.
- Support multiple tactical options to fulfill a goal (e.g. flank vs. slug it out).
- Allow commander-level doctrine to influence or override behavior.
- Simulate human-like decision cadence (cooldowns per role).
- Emit "radio chatter" for decision transparency and immersion.
- Support interrupts (e.g. retreat on critical damage).

## Layered AI Engines

- Doctrine Layer: strategic posture, boosts/blocks rules
- Goal Layer: assigns goals per ship (e.g. engage, support)
- Action Planning: evaluates multiple tactical options (GOAP-style)
- Reactive Rule Engine: high-priority interrupts (e.g. retreat)
- Task Execution: carries out the selected action steps

```
[ Doctrine / Commander ]
        ↓
[ Goal Selection Layer ]
        ↓
[ Action Planning Layer ]  ←→  [ Reactive Rule Engine ]
        ↓
[ Task Execution Layer ]
        ↓
[ Game World / Godot Ships ]
```
## TODO

- Bug: 2 battles, 2nd fleet gets deleted before battle
- CL, CA, BC, BB ship classes
- Ship class speed
- CL and BC are faster, CA and BB more armored, etc
- Commands: harass, regroup, keep together

Later:
- Fog of war: scouts, reserve
- Supply resource (ships use it for upkeep)
- Personel resource 
- Pre-generated batches of context-specific messages for radio-chatter and galaxy news
- Galaxy news from ai logs (battles, map movements)

## Tech Tree

Tech is improved via R&D allocation, not a fixed tree. Upgrades require a mix of data (gathered from real battlefield use) and resources (assigned as % of income). Optimal efficiency is at a 50:50 split.

- New systems require **Prototypes**: first unit costs 3×
- Cost scaling (like SMAC):
    - Most advanced = x1.5
    - Next two levels = x1
    - Older = minimal cost
- As new systems are prototyped, cost levels shift upward automatically


## Galaxy Strategy Layer (Heuristic-Based)
The galaxy map simulates strategic warfare using simple heuristics, not full AI simulation. All behaviors are abstracted to create tension, fog of war, and emergent strategy, while remaining lightweight and deterministic.

- No direct fleet simulation — AI strength is represented as per-system threat values.
- AI behavior is faked through drift, decay, and bias, creating the illusion of planning.
- Player actions (scouting, positioning, splitting AI territory) influence outcomes.


Scouting
- If player scouts a system this turn: AI fleet is capped to visible threat (only slow reinforcements per turn).
- AI also "scouts" player systems: Scouted systems are twice as likely to be attacked next turn.

Main Fleet Weight
- A virtual “main fleet” weight moves randomly across AI systems.
- Boosts threat level in systems it visits.
- Encourages player to track and intercept “major enemy pushes.”

Cut-Off Systems
- AI systems disconnected from AI core begin to decay over time:
- 10% parity per turn, max -50%
- Optional: lose ability to launch attacks
- This encourages flanking, chokepoint control, and cleanup operations.

### Strategic Effects
| Player Action       | Result                                                      |
| ------------------- | ----------------------------------------------------------- |
| Scouting enemy      | Locks AI to revealed threat, prevents surprise buildup      |
| Positioning fleets  | Reduces attack odds or improves player parity when attacked |
| Watching main fleet | Helps decide where to defend or strike preemptively         |
| Splitting territory | Causes isolated AI systems to decay and become vulnerable   |

## Emulating Real-World Ship Roles

Each ship class reflects real-world naval roles, with distinct stats that drive emergent behavior. 

These natural differences let AI behavior emerge without scripting roles — ships act appropriately based on their attributes.


| Class                  | Real-World Role          | Traits to Emulate                 | Emergent Behavior              |
| ---------------------- | ------------------------ | --------------------------------- | ------------------------------ |
| **FF (Frigate)**       | Screening, escort, recon | Fast, cheap, low HP/attack        | Harass, scout, bait, screen    |
| **DD (Destroyer)**     | Strike escort, anti-cap  | Versatile, medium stats         | Flanker, burst damage, cover |
| **CL (Light Cruiser)** | Fast strike/support      | Moderate firepower/speed, fragile | Flankers, light push, screen   |
| **CA (Heavy Cruiser)** | General-purpose brawler  | Solid stats, slower, more durable | Backbone unit, flexible        |
| **BC (Battlecruiser)** | Fast but heavy-hitting   | High damage, fast, poor armor     | Shock tactics, hit-and-run     |
| **BB (Battleship)**    | Line anchor, tank        | High HP, slow, powerful           | Line holding, absorbs pressure |


### Realistic and Useful Subclasses

Subclasses simplify ship design by offering ready-made roles—like missile boats or recon destroyers—where core systems are fixed. The player only chooses the tech level (cost vs performance), not full layouts, making fleet building fast and strategic.

| Class  | Subclass             | Concept / Role                     | Tactical Flavor                               |
| ------ | -------------------- | ---------------------------------- | --------------------------------------------- |
| **FF** | Gunboat              | Cheap, swarmable cannon ship       | Harass, escort, disposable picket             |
|        | Missile Boat         | Light, long-range punch            | First-strike or bait, poor endurance          |
|        | Drone Frigate        | Deploys autonomous units           | Future tech scout, harassment swarm           |
| **DD** | PDC Escort           | Close-in defense specialist (CIWS) | Defends capital ships from missiles/drones    |
|        | Torpedo Destroyer    | Anti-capital burst damage          | Flanker or ambush finisher                    |
|        | Recon Destroyer      | High speed, decent sensors         | Fast-response scout or screen leader          |
| **CL** | Sensor Cruiser       | Superior detection, fog clearing   | Battlefield intel + midline support           |
|        | Skirmisher           | Mobility + moderate punch          | Maneuver doctrine enabler                     |
| **CA** | Assault Cruiser      | Heavy armor, short-range weapons   | Punches through screens, draws fire           |
|        | Missile CA           | Long-range, mid-speed              | Line-support or siege ship                    |
| **BC** | Fast Missile Cruiser | High DPS, low armor                | Shock & awe, but can't stay in a fight        |
|        | Command BC           | Bonus to nearby ships (flavor)     | Fleet leader with behavior-modifying doctrine |
| **BB** | Heavy Gun BB         | Massive cannons, short range       | Dominates line battles, poor agility          |
|        | Carrier BB           | Launches drones or strike craft    | Strategic asset, high priority target         |

### Ship attributes

Taken from the real world, but:
- Slightly exaggerated for more immediate impact / more clear disctinction between classes.
- Some sci-fi conventions are accepted: e.g. CL and BC are "fast", DD is "tincan but packs a punch" etc

| **Class**              | **Speed**(kt) | **Main Guns**(in) | **Armor**(in) | **Displacement**(kt) | **Cost**(\$M) | **Build Time**(mo) |
| ---------------------- | ------------- | ----------------- | ------------- | -------------------- | ------------- | ------------------ |
| **Frigate (FF)**       | 30            | 3                 | 0             | 20                   | 2             | 3                  |
| **Destroyer (DD)**     | 36            | 5                 | 1             | 30                   | 4             | 6                  |
| **Light Cruiser (CL)** | 38            | 6                 | 2             | 45                   | 8             | 12                 |
| **Heavy Cruiser (CA)** | 32            | 8                 | 3             | 60                   | 16            | 18                 |
| **Battlecruiser (BC)** | 40            | 14                | 5             | 90                   | 32            | 24                 |
| **Battleship (BB)**    | 28            | 16                | 8             | 120                  | 48            | 32                 |

## Weapons

| Weapon                       | Trait                                                     | Emergent Behavior                                        | Strategic Implication                                           |
| ---------------------------- | --------------------------------------------------------- | -------------------------------------------------------- | --------------------------------------------------------------- |
| **Laser**                    | Instant hit, full accuracy, **damage falloff with range** | Prefers close engagement                                 | Brawlers benefit; fast ships can “get under” long-range targets |
| **Kinetic**                  | No falloff, **can miss**, maybe has cooldown              | Requires line of sight & proximity                       | Good against slow targets; high agility counters it             |
| **Missiles**                 | **Limited ammo**, long-range, may be intercepted          | Forces ammo conservation, requires good target selection | Incentivizes first-strike, AI must "know when to launch"        |

### AI reactions based on weapon types

Lasers:
- Close in fast to maximize damage
- Retreat if outranged or outgunned

Kinetics:
- Prefer slower enemies or shoot at clusters
- If own hit chance is too low, seek better positioning

Missiles:
- Hold fire until good hit chance or high-value target
- Don't waste on fast ships or weak scouts
- Retreat if out of ammo (or change role to "distraction")

## Parity

In-battle parity: When the player initiates a battle, the AI fleet is spawned on-the-fly to roughly match the cost of the player’s attacking fleet (up to parity, not over). This avoids pre-simulating fleets and simplifies the campaign layer.


- **Reward Player Action**: 
    Scouting, cutting off systems, chokepoints - should visibly matter.
- **Create a Sense of Consequence**: 
    Wins and losses, reinforcements, system being cut-off - should matter.
- **Enable Predictable Planning with Occasional Surprise**: 
    Most parity shifts are visible and logical; rare spikes (e.g. AI main fleet) create narrative tension.
- **Support Strategy Without Burden**: 
    Strategic decisions matter, but without economic micromanagement or heavy UI layers.

### Global Parity - Ideas

| Factor                                  | Effect                        | Notes                                |
| --------------------------------------- | ----------------------------- | ------------------------------------ |
| 📈 Time                                 | +2% per turn                  | Basic ramp-up; controls pacing       |
| 🏁 Difficulty level                     | Base % and ramp rate          | Can adjust starting parity and slope |
| 🏠 AI holds more/less systems           | +/-X% global parity           | Simulates “momentum”                 |
| 🔄 AI reinforcements spent recently     | -X% next turn                 | Simulates “cooldown”                 |
| 🚨 Major AI loss (e.g. main fleet dies) | -X% global parity             | Optional global shock                |

### Local Parity (per World) - Ideas

| Factor                              | Effect                          | Notes                              |
| ----------------------------------- | ------------------------------- | ---------------------------------- |
| 🚀 Main fleet present               | +30% parity                     | Moves around, creates threats      |
| 🔗 Connected to core                | Full reinforcements             | Else suffers decay                 |
| 🪫 Cut off                          | -10% per turn                   | Down to -50%, no attacks           |
| 👁️ Player scouted system           | Reinforcements capped           | No surprise stacks                 |
| 🧭 System scouted player            | Doubles attack chance next turn | Sneaky tension bump                |
| 🛠️ Has special tag (e.g. Shipyard) | Faster reinforcement rate       | Good for choke design later        |
| 💥 Recently attacked                | -X% parity until cooldown       | Optional realism (damaged systems) |
| ⚔️ Recent win                       | +X% temporary boost             | If it successfully repelled player |

## Why Battles Stay Fun (Player Motivation)

- **Uncertainty**: Outcomes vary due to comp, doctrine, and parity — no two fights are alike.
- **Agency**: Grand Admiral-level commands offer rare but impactful influence mid-battle.
- **Learning**: Players observe ship and fleet behavior to refine their own doctrine and design.
- **Progression**: Watching battles generates battlefield data used to unlock tech and equipment upgrades.


# SHIP DESIGN SUMMARY

## Design Philosophy

- **SMAC-style system**: Simple parts with emergent combinations
- Each ship = **Chassis + Subclass + Tech Level**
- No granular customization: all loadouts are **predefined by subclass**
- Player only chooses **tech tier** (e.g. Laser Mk II, Armor Mk I)

## Structure Per Ship

| Component           | Controlled By                                                    |
| ------------------- | ---------------------------------------------------------------- |
| **Chassis**         | Ship class (FF, DD, etc.) → defines base stats & slots           |
| **Subclass**        | Fixed combo of weapon + special role behavior                    |
| **Main Weapon**     | Fixed per subclass (missile, laser, railgun)                     |
| **Defense Modules** | Predefined slots (vary by chassis), tech level selected globally |
| **Special Module**  | Baked into subclass (not player-selected)                        |

Role Scaling:
- Bigger ships = more slots, more systems
- Smaller ships = fewer systems, narrower roles
- No lasers on FF (realism: they shouldn’t close distance)
- No special for FF

Specials:
- Missile platform: extra tube, more ammo
- Sensors platform: extra sensor range
- Command & Control: sensors, aura cooldown boost

Weapons:
- All ships (except FF) have light weapons/armor of all types
- Main weapon is extra and defines the subclass (together with special)
- FF has either kinetic or missiles and no special
- Missiles have "ammo count" and can be depleted

## FRIGATE (FF) SUBCLASSES

Frigates are **cheap, expendable tactical tools** — not for direct combat.

| Code     | Subclass Name   | Main Weapon   | Built-In Special    | Role                  | Behavior                     |
| -------- | --------------- | ------------- | ------------------- | --------------------- | ---------------------------- |
| **FF-K** | Kinetic Frigate | Light railgun | *None*              | Scout, courier, bait  | Fast, agile, disposable      |
| **FF-M** | Missile Frigate | Missiles      | +6 missile capacity | Long-range skirmisher | Fire early, retreat when dry |

- FF-K is your **default utility frigate**
- FF-M is your **cheap burst striker**, becomes inefficient when empty


## DESTROYER (DD) SUBCLASSES

Destroyers are the first **specialist warships** — fast, lightly armored, role-focused.

| Code     | Subclass Name     | Main Weapon | Built-In Special          | Role                         | Behavior                           |
| -------- | ----------------- | ----------- | ------------------------- | ---------------------------- | ---------------------------------- |
| **DD-M** | Missile Destroyer | Missiles    | +6 missiles               | Anti-capital alpha strike    | Front-loads damage, then withdraws |
| **DD-I** | Interceptor       | Lasers      | Afterburner (speed burst) | Flanker, anti-scout          | Rush, harass, peel off             |
| **DD-P** | PDC Escort        | Lasers      | Point Defense enhancement | Protect allies from missiles | Escort capitals, defensive         |
| **DD-R** | Recon Destroyer   | Kinetics    | Sensor Suite              | Scouting / early detection   | Edge patrol, info role             |

- DDs scale from **fleet tools** to **detachment leaders**
- In small fleets, DDs act as mainline fighters
- In large fleets, they support, screen, or strike

## SUPPORT CLASSES (AUXILIARIES)

Provide more reason for fleet composition and need protecting.

- Tenders: resupply e.g. missiles mid-battle
- Repair ships: slow repair during combat, save heavily damaged ships from being scrapped after combat, provide repair in systems without shipyard
