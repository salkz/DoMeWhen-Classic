local DMW = DMW
local AceGUI = LibStub("AceGUI-3.0")
local Point = DMW.Classes.Point

local defaults = {
    profile = {
        MinimapIcon = {
            hide = false
        },
        HUDPosition = {
            point = "LEFT",
            relativePoint = "LEFT",
            xOfs = 40,
            yOfs = 100
        },
        HUD = {
            Rotation = 1,
            Show = true
        },
        Enemy = {
            InterruptDelay = 0.2,
            InterruptTarget = 1,
            AutoFace = false
        },
        Friend = {
            DispelDelay = 1
        },
        Rotation = {},
        Queue = {
            Wait = 2,
            Items = true
        },
        Helpers = {
            AutoLoot = false,
            AutoSkinning = false,
            AutoGather = false,
        },
        Lilium = {
            Password = ""
        },
        Grind = {
            FoodVendorX = 0,
            FoodVendorY = 0,
            FoodVendorZ = 0,
            FoodVendorName = '',
            RepairVendorX = 0,
            RepairVendorY = 0,
            RepairVendorZ = 0,
            RepairVendorName = '',
            HotSpots = {},
            VendorWaypoints = {},
            FoodName = '',
            WaterName = '',
            FoodAmount = 60,
            WaterAmount = 60,
            RestHP = 60,
            RestMana = 50,
            CombatDistance = 3,
            maxNPCLevel = 2,
            minNPCLevel = 4,
            attackAny = false,
            RepairPercent = 40,
            MaximumVendorRarity = 1,
            MinFreeSlots = 5,
            RoamDistance = 100,
            MountName = '',
            BuyFood = false,
            BuyWater = false,
            autoFood = false,
            autoWater = false,
            UseMount = false,
            vendorMount = false,
            mountDistance = 60,
            SkipCombatOnTransport = true,
            drawPath = true,
            drawHotspots = true,
            drawCircles = false,
            openClams = false,
            MountBlacklist = {},
            beHuman = true,
            doSkin = false,
            useHearthstone = false,
            ignoreWhispers = false,
            randomizeWaypoints = false,
            preventPVP = false,
            preventPVPTime = 120,
            safeRess = false,
            randomizeWaypointDistance = 20,
            mineOre = false,
            gatherHerb = false,
            targetBlacklist = {},
            itemSaveList = {},
            rangeKite = false,
            firstAid = false,
        },
        Tracker = {
            Herbs = false,
            Ore = false,
            TrackNPC = false,
            QuestieHelper = false,
            QuestieHelperColor = {0,0,0,1},
            HerbsColor = {0,0,0,1},
            OreColor = {0,0,0,1},
            TrackUnitsColor = {0,0,0,1},
            TrackObjectsColor = {0,0,0,1},
            TrackPlayersColor = {0,0,0,1},
            TrackNPCColor = {1,0.6,0,1},
            OreAlert = 0,
            HerbsAlert = 0,
            QuestieHelperAlert = 0,
            TrackUnitsAlert = 0,
            TrackObjectsAlert = 0,
            TrackPlayersAlert = 0,
            OreLine = 0,
            HerbsLine = 0,
            QuestieHelperLine = 0,
            TrackUnitsLine = 0,
            TrackObjectsLine = 0,
            TrackPlayersLine = 0,
            TrackPlayersEnemy = false,
            TrackPlayersAny = false,
            TrackObjectsMailbox = false
        },
        Follower = {
            LeaderName = '',
            FollowDistance = 10
        }
    },
    char = {
        SelectedProfile = select(2, UnitClass("player")):gsub("%s+", "")
    }
}

local function MigrateSettings()
    local Reload = false
    if type(DMW.Settings.profile.Helpers.TrackPlayers) == "boolean" then
        DMW.Settings.profile.Helpers.TrackPlayers = nil
        Reload = true
    end
    for k,v in pairs(DMW.Settings.profile.Helpers) do
        local moveNew = true
        if k == "AutoGather" or k == "AutoLoot" or k == "AutoSkinning" then
            moveNew = false
        end
        if moveNew then
            DMW.Settings.profile.Tracker[k] = v
            DMW.Settings.profile.Helpers[k] = nil
            Reload = true
        end
    end

    -- Update waypoints to Point
    DMW.Settings.profile.Grind.HotSpots = MigratePoints(DMW.Settings.profile.Grind.HotSpots)
    DMW.Settings.profile.Grind.VendorWaypoints = MigratePoints(DMW.Settings.profile.Grind.VendorWaypoints)
    DMW.Settings.profile.Grind.MountBlacklist = MigratePoints(DMW.Settings.profile.Grind.MountBlacklist)

    if Reload then
        ReloadUI()
    end
end

function MigratePoints(spots)
    points = {}
    if not spots then
        return points
    end

    for i = 1, #spots do
        local spot = spots[i]
        if not spot then return end

        if spot.x then
            -- old format
            points[i] = Point(spot.x, spot.y, spot.z)
        elseif spot.X then
            -- new format
            points[i] = Point(spot.X, spot.Y, spot.Z)
        end
    end

    return points
end

function DMW.InitSettings()
    DMW.Settings = LibStub("AceDB-3.0"):New("DMWSettings", defaults, "Default")
    DMW.Settings:SetProfile(DMW.Settings.char.SelectedProfile)
    DMW.Settings.RegisterCallback(DMW, "OnProfileChanged", "OnProfileChanged")
    MigrateSettings()
end

function DMW:OnProfileChanged(self, db, profile)
    DMW.Settings.char.SelectedProfile = profile
    ReloadUI()
end
