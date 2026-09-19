# rocketShooter — Level Design

## Goal

Gradually make flight content constructible through data/configuration
instead of requiring every object to be manually placed in Studio.

Target concept:

    LevelConfig
        ↓
    LevelBuilder
        ↓
    AssetRegistry
        ↓
    Generated Flight Course

Do not build the entire architecture prematurely.

Add pieces when gameplay actually requires them.

---

## Level Sections

Prefer reusable gameplay sections such as:

- ObstacleField
- RingSection
- RouteSplit
- ResourceSection
- EventSection
- LandingSection

A section represents a gameplay idea, not merely decoration.

---

## Distance & Coordinates

The game progresses primarily through flight distance.

Before implementing level generation, inspect the existing implementation
and determine:

- actual flight direction
- coordinate axis
- launch origin/reference
- current distance calculation
- existing map layout

Do not assume a coordinate axis.

The current prototype's distance system may not necessarily be the final
region progression metric.

---

## Obstacles

Obstacle generation may eventually describe:

- distance range
- asset pool
- density
- difficulty
- movement
- safe gaps

Generated layouts must remain achievable and readable.

Randomness is variation, not a substitute for level design.

---

## Rings

Ring sections should eventually support configuration such as:

- start position/distance
- count
- spacing
- curve
- difficulty
- reward profile

Possible patterns:

- straight
- left/right curve
- wave
- ascending/descending
- precision sequence

New courses should primarily require configuration rather than new
gameplay code.

---

## Routes

Route splits should create different objectives.

Examples:

    SAFE
    SKILL
    RESOURCE

Route identity should be visually readable before the player must decide.

---

## Regions

Regions should eventually be data-driven.

Potential properties:

    Name
    DistanceRange
    Environment
    AssetPool
    Obstacles
    Rings
    RewardProfile
    Events

Avoid scattering region-specific values throughout unrelated scripts.

---

## Asset Registry

Reusable assets should eventually be referenced centrally.

Conceptually:

    Assets.Obstacles.*
    Assets.Rings.*
    Assets.Environment.*
    Assets.Cannons.*
    Assets.Rockets.*

Exact architecture is not predetermined.

---

## Asset Discovery

When available tools permit it, actively research and select appropriate
assets rather than automatically requiring the user to find them.

Evaluate:

- visual consistency
- gameplay readability
- performance
- permitted usage
- geometry complexity
- unnecessary or suspicious scripts

Never blindly trust imported free models.

Preferred workflow:

    discover
      → inspect
      → sanitize
      → register
      → integrate

If direct Studio insertion is available, perform it when safe.

If unavailable, automate as much integration as possible and clearly
identify the remaining manual action.

---

## Art Direction

Until finalized, prefer:

- stylized
- colorful
- readable silhouettes
- coherent visual style
- moderate geometry complexity
- Roblox-appropriate visuals

Gameplay readability takes priority over realism.

---

## Long-Distance Performance

The player may eventually travel very far.

Do not assume unlimited world content can remain active forever.

Future solutions may include:

- distance-based activation
- region spawning/despawning
- pooling
- section recycling

Implement these when scale or profiling justifies them.

---

## Agent Workflow

When improving a flight region:

    inspect gameplay purpose
        ↓
    identify missing interaction
        ↓
    design section
        ↓
    select/research assets
        ↓
    configure/build section
        ↓
    integrate
        ↓
    verify
        ↓
    tune from Play Test feedback

Avoid filling empty space with meaningless scenery.
