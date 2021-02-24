# FiveM Ped Appearance Driver

Usage
```lua
local ped = Ped.new(PlayerPedId())

--- get a table containing the ped's appearance data
local appearance = ped:GetAppearance()

--- get a table which describes which components variations/texture ids etc this
--- ped can use
local availableAppearance = ped:GetAvailableAppearance()

--- set the peds appearance. expects the data to be in the same structure as the result from
--- GetAppearance
ped:SetAppearance(appearance)

--- SetAppearance will also accept partial data
ped:SetAppearance({
    Drawables = {
        Torso = {
            Variation = 10
        }
    }
})
```