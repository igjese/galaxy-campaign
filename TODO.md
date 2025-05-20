# Fleets and Worlds: Andromeda
(Implementation Status and TODO)

## TODO

### AI Enhancements

Tactical AI Enhancements
- Add `wait_for_allies` step to enable regrouping before engagement.
- Implement `formation_preferences` in doctrine (e.g., rear/front tags).
- Use `formation_offset` in Admiral to bias positioning based on role and HP.
- Add `move_behind_friendlies` step for basic support positioning.

Role Logic Refinement
- Prevent `support` or `retreat` roles if no frontline exists.
- Force `assault` role if ship is the only remaining combat unit.
- Add doctrine-defined `reactivation_conditions` (e.g., return from retreat if outnumbered).

Emergency Behavior
- Implement `should_emergency_retreat()` in ShipAI for critical HP override.
- Allow temporary self-directed goal override (`retreat`) when survival is at risk.

Targeting Behavior
- Extend `focus fire` scoring to include ally-fire weighting (e.g., prioritize common target).
- Add targeting bias for high-threat enemies (e.g., highest attack power).

Tactical Reserve
- Add `standby` goal for heavily damaged ships.
- Trigger `reactivation` from standby if allies are outnumbered or dying.


### Other
- CL, CA, BC, BB ship classes
- Ship class speed
- CL and BC are faster, CA and BB more armored, etc
- Commands: harass, regroup, keep together


## Feature Coverage Snapshot (vs. Planned Set)

This section tracks which parts of the high-level feature set are implemented in prototype form.

| **Category**               | **Prototype Status**                                                                                   |
|----------------------------|--------------------------------------------------------------------------------------------------------|
| **Map / Systems**          | ✅ Fixed star systems with resources; connection graph; capture mechanics.                             |
| **Resources**              | ✅ Materials implemented; supply/personnel placeholders only.                                          |
| **Galaxy AI**              | ✅ AI attacks based on parity and proximity; basic targeting of player systems.                        |
| **Fleet Combat**           | ✅ Tactical layer with move, shoot, retreat; cooldown loops; focus fire scoring added.                  |
| **Ship Design**            | ✅ Fixed ship classes (FF, DD) with defined stats in `GameData`; extensible dictionary.                |
| **Combat Roles**           | ✅ Doctrine-driven roles (assault, support, retreat); health-based assignment.                         |
| **Weapons**                | ✅ Basic flat-damage weapons with range.                                                               |
| **Defenses**               | ✅ Flat HP pool per ship; damage reduces HP.                                                           |
| **Tech Tree**              | ❌ Not implemented.                                                                                    |
| **Prototyping**            | ❌ Not implemented.                                                                                    |
| **Strategic Layer**        | ✅ Capturing worlds grants resources; system ownership tracked.                                        |
| **System Effects**         | ❌ None yet.                                                                                           |
| **Ship Production**        | ✅ Instant production with material cost; spawn at world location.                                     |
| **Unit Spam (SMAC-style)** | ✅ Frigates serve as basic expendable units; cheap and quick to field.                                |
| **Command Hierarchy**      | ✅ Admiral assigns goals; ShipAI executes steps; no squad-level yet.                                   |
| **Scouting / Intel**       | ❌ Full visibility; no fog of war or detection yet.                                                    |
| **Autoresolve Battles**    | ❌ Not implemented; all combat is visual/real-time for now.                                            |
| **Fleet Composition**      | ✅ AI fleet cost scaled to player + parity; uses `generate_ai_fleet()` logic.                          |


## In Progress / Partial Systems

These features are partially implemented, prototyped, or planned for short-term execution.

### Tactical AI Behavior
- Regrouping behavior discussed; `wait_for_allies` step not implemented yet.
- Formation hints planned via `doctrine.yaml → formation_preferences`.
- Retreating ships currently idle at edge; intended to re-enter fight under conditions.
- Support role functional but not context-sensitive (e.g. fallback only if frontline exists).

### Role Logic Enhancements
- No check yet for lone survivors: support/retreat roles can be misapplied.
- Captain override (emergency retreat) planned for HP < 15%, bypassing Admiral cooldown.
- Doctrine lacks `reactivation_conditions` for reserves / last stand logic.

### Targeting & Fire Control
- Focus fire logic implemented via scoring (proximity + low HP), but not coordinated across allies.
- No current weighting for threat level or strategic target value.

### Strategic Layer & AI
- AI parity-based attack logic works, but no memory, personality, or doctrine-based variation yet.
- Defender auto-spawn logic added for fallback cases, but no system defense templates yet.

### Infrastructure & Tools
- `materials` used for costs; `supply` and `personnel` tracked but unused.
- Only one ship type used for defense scaling (`FF`); extensible, but hardcoded.


## Other

- Fog of war: scouts, reserve
- Supply resource (ships use it for upkeep)
- Personel resource 
- Pre-generated batches of context-specific messages for radio-chatter and galaxy news
- Galaxy news from ai logs (battles, map movements)
