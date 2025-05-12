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

- Retarget
- Retreat when low on hp
- Radio chatter
- Ship names
- CL, CA, BC, BB ship classes
- Ship class speed
- CL and BC are faster, CA and BB more armored, etc
- Simple explosions
- Ships should reposition or at least hover when "parked"
- Visual damage: crack overlay, flicker
- Ship trails
- Commands: harass, regroup, keep together
- Ships instantly change direction, but have turning speed
- AI attacks: 20% chance per connection (except first 5 turns)
- AI parity at 80% then +2% every turn


## IDEAS

- Lasers lose power with range => leads to emergent behavior eg. closing in etc
- Fog of war: scouts, reserve
