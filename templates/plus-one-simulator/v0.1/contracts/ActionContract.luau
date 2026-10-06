-- Documentation contract only. No adapter/engine is installed in RocketShooter.
-- A next-game implementation supplies these server-only functions.
export type CorePhase = "Loading" | "Idle" | "Acting" | "Result" | "Returning" | "Closed"
export type RunContext = {
 RunId: number,
 Player: Player,
 Character: Model,
 StartedAt: number,
 Power: number, -- frozen core input, NOT a client-supplied number
 EquipmentFlat: number,
 EquipmentGrowth: number,
}
export type VerifiedHit = {
 TargetId: string,
 RewardTier: number, -- validated 1..9, mapped by server adapter definition
 Units: number, -- bounded logical targets, NOT debris count
}
export type ActionResult = {
 Success: boolean,
 Reason: string,
 MetricName: string,
 MetricValue: number,
 MetricUnit: string,
}
export type CoreCallbacks = {
 VerifiedHit: (RunContext, VerifiedHit) -> (),
 AwardTimedXP: (RunContext) -> (), -- core limits cadence; no XP amount input
 Complete: (RunContext, ActionResult) -> (), -- core guards exactly-once settlement
}
export type ActionAdapter = {
 CanStart: (RunContext, any) -> (boolean, string?),
 Start: (RunContext, CoreCallbacks) -> any,
 HandleInput: (any, any) -> (),
 Step: (any, number) -> (),
 Cleanup: (any) -> (),
}
return table.freeze({
 Version = "0.1",
 RewardTierMultipliers = table.freeze({1, 2, 3, 5, 8, 12, 20, 30, 40}),
 Compatibility = table.freeze({ActingAttribute = "FlightState", ActingValue = "Flying"}),
})
