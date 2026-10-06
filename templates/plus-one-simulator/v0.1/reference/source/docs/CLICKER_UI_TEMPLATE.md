## Compact-v3 display

Auto cards contain only the cursor, mode title and 켜기/끄기. Card size is 228×84; title is 20px and action 36px. Rates and trial/free badges are omitted from the player UI; internal server rates and prototype availability are unchanged. UpdateButton(view,selected) controls the two-state label.

# Clicker UI template

Reference: https://app.notion.com/p/3eea5ec9ae238061a920f227bdbe4afb (read in the user's logged-in Chrome).

`ReplicatedStorage.ClickerUI` is a presentation module. `Progress(parent)` creates a propulsion title, an amber XP bar with level and XP count inside, and a click hint. `UpdateProgress(view,level,xp,required,power)` updates displayed values without granting anything. `Button(parent,"Free"|"OP")` creates the outlined white/yellow card and white/rainbow cursor; `UpdateButton(view,selected)` renders on/off. `Cursor(parent,rainbow)` exposes the scalable cursor illustration separately. Shared colors and template version are exposed as `Colors` and `Version`.

Example:

```luau
local UI=require(game.ReplicatedStorage.ClickerUI)
local progress=UI.Progress(screenGui)
UI.UpdateProgress(progress,4,10,16,10)
local free=UI.Button(buttonDock,"Free")
UI.UpdateButton(free,false)
free.Button.Activated:Connect(function()
 -- Send a mode request to your server; never grant XP from this component.
end)
```

`ResizeProgress(view,availableWidth,compact)` adjusts the bar width while retaining legible type sizes instead of shrinking the entire UI. The readable-v2 template enlarges the cursor cards, captions, rates and the level/XP bar.

The live binding is `ClickerClient.client.luau`. The progress block is responsive and remains visible in flight. Clicker buttons hide in flight and when progression modals are open, while an enabled mode keeps running on the server. Mobile taps use TouchTapInWorld so camera drags and held joystick gestures do not repeatedly farm XP. Interactive menus do not count as world clicks; the training panel has a dedicated +1 click button.

`ClickerConfig` owns base XP and rates: manual +1, free 3/sec, OP 6/sec. Manual and automatic awards use the same server-side multipliers/remainder pipeline as passive/flight/toilet XP. Modes are exclusive. Lag catch-up is capped; manual input has a separate 10/sec token budget with a two-click burst. No changes to persistent player fields.

OP is currently a labelled free trial: PreviewOP=true. No purchase prompt, GamePass, Robux charge or durable paid ownership is implemented. PreviewOP=false disables OP on the server; connect verified paid entitlement before a paid release. UI template components do not implement purchasing.

Artwork uses code-built native GUI scanlines with a black cursor outline and white/rainbow fill. No image uploads, private image URLs, external plugins or Creator Store models are required. The source reference remains read-only.
