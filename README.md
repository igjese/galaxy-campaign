# Worlds and Fleets: Andromeda
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

| **Category**               | **Prototype**                                                          | **Future**                                                                                 |
| -------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| **Map / Systems**          | Network of star systems with fixed resources (materials, supply).      | Add system types (e.g. academy, shipyard), chokepoints, random terrain effects.            |
| **Resources**              | Materials, Supply.                                                     | Add Personnel (crew), Work (industrial capacity), local production limits.                 |
| **Fleet AI**               | AI spawns equal-cost fleets in adjacent systems with chance to attack. | Smarter AI with defense priorities, personalities, response to tech or terrain.            |
| **Fleet Combat**           | Ships auto-move toward enemy, use simple damage rules.                 | Add rules for formation, targeting priority, range, terrain effects.                       |
| **Ship Design**            | Chassis + 1–2 fixed weapons.                                           | Full modular design: weapons, defenses, utility. Component interactions (e.g. rock-paper). |
| **Combat Roles**           | All-purpose ships.                                                     | Specialization: missile boat, tank, scout, drone carrier, etc.                             |
| **Weapons**                | Basic damage-dealing module.                                           | Rock-paper-scissors: lasers, missiles, railguns vs shields, armor, PDC.                    |
| **Defenses**               | Static HP.                                                             | Shields, armor, PDC, terrain-based modifiers.                                              |
| **Tech Tree**              | Linear unlock of new ship components.                                  | SMAC-style prototyping (expensive first build), cost reduction over time, branching paths. |
| **Prototyping**            | Not implemented.                                                       | First-time builds cost extra; standard after that; reduced costs at later tech levels.     |
| **Strategic Layer**        | Capture systems for more production.                                   | Minefields, battlestations, sensor arrays, repair stations.                                |
| **System Effects**         | None.                                                                  | Per-system terrain (e.g. nebula = no shields, asteroid = low accuracy).                    |
| **Ship Production**        | Instant spawn with cost deduction.                                     | Queues, production time, workforce limits.                                                 |
| **Unit Spam (SMAC-style)** | Basic scout ships, cheap to produce.                                   | Use weak, fast units for harassment, recon, distraction tactics.                           |
| **Command Hierarchy**      | None.                                                                  | Layered AI control: Admiral → Squad Leader → Captain, with different logic levels.         |
| **Scouting / Intel**       | Full visibility.                                                       | Fog of war, sensors, cloaking, detection modules.                                          |

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

- Bug: Retarget
- Bug: 2 battles, 2nd fleet gets deleted before battle
- Bug: laser not tracking ship
- Retreat when low on hp
- Radio chatter
- Ship names
- CL, CA, BC, BB ship classes
- Ship class speed
- CL and BC are faster, CA and BB more armored, etc
- Ships should reposition or at least hover when "parked"
- Visual damage: crack overlay, flicker
- Ship trails
- Commands: harass, regroup, keep together
- Ships instantly change direction, but have turning speed
- AI attacks: 20% chance per connection (except first 5 turns)
- AI parity at 80% then +2% every turn

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
