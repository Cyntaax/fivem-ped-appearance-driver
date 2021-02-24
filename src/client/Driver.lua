--- @class Ped
Ped = setmetatable({}, Ped)

Ped.__index = Ped

Ped.__call = function()
    return "Ped"
end

--- Creates a new instance of the `Ped` class.
---@param handle number
function Ped.new(handle)
    local _Ped = {
        Handle = handle,
    }
    return setmetatable(_Ped, Ped)
end

function Ped:SetAppearance(data)
    local currentAppearance = self:GetAppearance()
    Citizen.Wait(0)
    if data.Drawables then
        for k,v in pairs(data.Drawables) do
            Citizen.Wait(0)
            local currentDrawable = currentAppearance.Drawables[k]
            SetPedComponentVariation(self.Handle, PedComponent[k], v.Variation or currentDrawable.Variation,
                    v.Texture or currentDrawable.Texture, v.Palette or currentDrawable.Palette)
        end
    end

    if data.Props then
        for k,v in pairs(data.Props) do
            local currentProp = currentAppearance.Props[k]
            if v.PropIndex and not v.Texture and currentProp.Texture == -1 then
                currentProp.Texture = 0
            end
            SetPedPropIndex(self.Handle, PedProp[k], v.PropIndex or currentProp.PropIndex, v.Texture or currentProp.Texture, false)
        end
    end

    if data.HeadOverlays then
        for k,v in pairs(data.HeadOverlays) do
            local currentOverlay = currentAppearance.HeadOverlays[k]
            SetPedHeadOverlay(self.Handle, PedHeadOverlay[k], v.Value or currentOverlay.Value, v.Opacity or currentOverlay.Opacity)
        end

        for k,v in pairs(data.HeadOverlays) do
            local currentOverlay = currentAppearance.HeadOverlays[k]
            SetPedHeadOverlayColor(self.Handle, PedHeadOverlay[k], v.ColorType or currentOverlay.ColorType,
                    v.FirstColor or currentOverlay.FirstColor, v.SecondColor or currentOverlay.SecondColor)
        end
    end

    if data.Inheritance then
        local setData = data.Inheritance
        local currentBlend = currentAppearance.Inheritance
        SetPedHeadBlendData(self.Handle, setData.Father or currentBlend.Father, setData.Mother or currentBlend.Mother, 0,
                setData.FatherSkin or currentBlend.FatherSkin, setData.MotherSkin or currentBlend.MotherSkin, 0,
                setData.ShapeMix or currentBlend.ShapeMix, setData.SkinMix or currentBlend.SkinMix, 0, 0 )
        while not HasPedHeadBlendFinished(self.Handle) do
            Citizen.Wait(10)
        end
    end
end

function Ped:GetAppearance()

    local Drawables = {}
    local Props = {}
    local HeadOverlays = {}
    for k,v in pairs(PedComponent) do
        local variation = GetPedDrawableVariation(self.Handle, v)
        local name = k
        Drawables[name] = {
            ComponentID = v,
            Variation = variation
        }
        Drawables[name].Texture = GetPedTextureVariation(self.Handle, v)
        Drawables[name].Palette = GetPedPaletteVariation(self.Handle, v)

    end

    for k,v in pairs(PedProp) do
        Props[k] = {
            PropID = v,
            PropIndex = GetPedPropIndex(self.Handle, v),
            Texture = GetPedPropTextureIndex(self.Handle, v)
        }
    end

    for k,v in pairs(PedHeadOverlay) do
        local _, overlayValue, colorType, firstColor, secondColor, opacity = GetPedHeadOverlayData(self.Handle, v)
        HeadOverlays[k] = {
            OverlayID = v,
            Value = overlayValue,
            ColorType = colorType,
            FirstColor = firstColor,
            SecondColor = secondColor,
            Opacity = opacity
        }
    end

    Model = GetEntityModel(self.Handle)

    local shapeFirst, shapeSecond, _, skinFirst, skinSecond, _,
    shapeMix, skinMix, _= table.unpack({GetHeadBlendData()})
    ---@type PedInheritanceData
    local finalBlend = {}
    finalBlend.Father = shapeFirst
    finalBlend.Mother = shapeSecond
    finalBlend.FatherSkin = skinFirst
    finalBlend.MotherSkin = skinSecond
    finalBlend.ShapeMix = shapeMix
    finalBlend.SkinMix = skinMix

    return {
        Drawables = Drawables,
        Props = Props,
        HeadOverlays = HeadOverlays,
        Inheritance = finalBlend
    }
end

function Ped:GetAvailableAppearance()
    local data = {
        Drawables = {},
        Props = {},
        HeadOverlays = {}
    }
    for k,v in pairs(PedComponent) do
        local componentId = v
        local drawables = GetNumberOfPedDrawableVariations(self.Handle, componentId)
        data.Drawables[k] = {
            NumDrawables = drawables,
            TextureVariations = {}
        }
        local tmpTable = {
            Drawables = {},
        }

        tmpTable.Drawables[k] = {}
        for i = 0, drawables - 1, 1 do
            tmpTable.Drawables[k] = {
                Variation = i,
                Texture = 0,
                Palette = 0
            }

            local textureVariations = GetNumberOfPedTextureVariations(self.Handle, PedComponent[k], i)
            table.insert(data.Drawables[k], {
                DrawableIndex = i,
                TextureVariations = textureVariations
            })
        end
    end

    for k,v in pairs(PedProp) do
        local propId = v
        local drawables = GetNumberOfPedPropDrawableVariations(self.Handle, propId)
        data.Props[k] = {
            NumDrawables = drawables,
            TextureVariations = {}
        }

        for i = 0, drawables - 1, 1 do
            local textureVariations = GetNumberOfPedPropTextureVariations(self.Handle, propId, i)
            table.insert(data.Props[k], {
                DrawableIndex = i,
                TextureVariations = textureVariations
            })
        end
    end

    return data
end

PedComponent = {
    Face = 0,
    Mask = 1,
    Hair = 2,
    Torso = 3,
    Leg = 4,
    Bag = 5,
    Shoes = 6,
    Accessory = 7,
    Undershirt = 8,
    Kevlar = 9,
    Badge = 10,
    Torso2 = 11
}

PedProp = {
    Hat = 0,
    Glasses = 1,
    Ear = 2,
    Unk1 = 3,
    Unk2 = 4,
    Unk3 = 5,
    Watch = 6,
    Bracelet = 7
}

PedHeadOverlay = {
    Blemishes = 0,
    FacialHair = 1,
    Eyebrows = 2,
    Ageing = 3,
    Makeup = 4,
    Blush = 5,
    Complexion = 6,
    SunDamage = 7,
    Lipstick = 8,
    MolesFreckles = 9,
    Chesthair = 10,
    BodyBlemishes = 11,
    BodyBlemishes2 = 12
}

PedHeadOverlayData = {
    Blemishes = {
        Range = {0, 23},
        Disable = 255
    },
    FacialHair = {
        Range = {0,28},
        Disable = 255
    },
    Eyebrows = {
        Range = {0, 33},
        Disable = 255,
    },
    Ageing = {
        Range = {0, 14},
        Disable = 255
    },
    Makeup = {
        Range = {0, 74},
        Disable = 255
    },
    Blush = {
        Range = {0, 6},
        Disable = 255
    },
    Complexion = {
        Range = {0, 11},
        Disable = 255
    },
    SunDamage = {
        Range = {0, 10},
        Disable = 255
    },
    LipStick = {
        Range = {0, 9},
        Disable = 255
    },
    MolesFreckles = {
        Range = {0, 17},
        Disable = 255
    },
    Chesthair = {
        Range = {0, 16},
        Disable = 255
    },
    BodyBlemishes = {
        Range = {0, 11},
        Disable = 255
    },
    BodyBlemishes2 = {
        Range = {0, 1},
        Disable = 255
    }
}

---@class PedInheritanceData
PedInheritanceData = {
    Father = 0,
    Mother = 0,
    Third = 0,
    FatherSkin = 0,
    MotherSkin = 0,
    ThirdSkin = 0,
    ShapeMix = 0,
    SkinMix = 0
}