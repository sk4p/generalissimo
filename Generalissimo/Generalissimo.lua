local addonName = ...
_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
local addon = _G[addonName]

addon.Version = '0.01'

-- Current info
local myAccount = "default"
local myRealm = GetRealmName()
local myName = UnitName("player")

-- Key for storing characters.
local function charKey(char,realm,acct)
   local n = char or UnitName("player")
   local r = realm or GetRealmName()
   local a = acct or myAccount

   -- Just like a unix path
   return format("%s/%s/%s", a, r, n)
end

-- subframes for characters
local charFrame = {}

-- The database.
local db_defaults = {
   global = {
      Characters = {
	 ['*'] = {
	    faction = nil,
	    guildName = nil
	 }
      },
      Guilds = {

      }
   }
}

-- colors
addon.Colors = {
   white   = "|cFFFFFFFF",
   red = "|cFFFF0000",
   darkred = "|cFFF00000",
   green = "|cFF00FF00",
   orange = "|cFFFF7F00",
   yellow = "|cFFFFFF00",
   gold = "|cFFFFD700",
   teal = "|cFF00FF9A",
   cyan = "|cFF1CFAFE",
   lightBlue = "|cFFB0B0FF",
   battleNetBlue = "|cff82c5ff",
   grey = "|cFF909090",

   -- classes
   classDEATHKNIGHT =  "|cFFC41F3B",
   classDEMONHUNTER = "|cFFA330C9",
   classDRUID = "|cFFFF7D0A",
   classHUNTER = "|cFFABD473",
   classMAGE = "|cFF69CCF0",
   classMONK = "|cFF00FF96",
   classPALADIN = "|cFFF58CBA",
   classPRIEST = "|cFFFFFFFF",
   classROGUE = "|cFFFFF569",
   classSHAMAN = "|cFF0070DE",
   classWARLOCK = "|cFF9482C9",
   classWARRIOR = "|cFFC79C6E",

   -- recipes
   recipeGrey = "|cFF808080",
   recipeGreen = "|cFF40C040",
   recipeOrange = "|cFFFF8040",

   -- rarity : http://wow.gamepedia.com/Quality
   common = "|cFFFFFFFF",
   uncommon = "|cFF1EFF00",
   rare = "|cFF0070DD",
   epic = "|cFFA335EE",
   legendary = "|cFFFF8000",
   heirloom = "|cFFE6CC80",

   Alliance = "|cFF2459FF",
   Horde = "|cFFFF0000"
}

local colors = addon.Colors

-- databases of characters and guilds
local charDB
local guildDB

-- dummy slash command
local options = {
   name = "WelcomeHome",
   handler = Generalissimo,
   type = 'group',
   args = {
   },
}

-- Dump function, for debugging.
--
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
	 if type(k) ~= 'number' then k = '"'..k..'"' end
	 s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- Coin texture string which actually includes zeroes.
--
local function GetGenCoin(copper)

   -- Get the numbers of coins
   local gold = floor(copper / 100 / 100)
   copper = copper - gold * 100 * 100
   local silver = floor(copper / 100)
   copper = copper - silver * 100

   local gf = format("%02d|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:2:0|t", gold)
   local sf = format("%02d|TInterface\\MoneyFrame\\UI-SilverIcon:14:14:2:0|t", silver)
   local cf = format("%02d|TInterface\\MoneyFrame\\UI-CopperIcon:14:14:2:0|t", copper)

   return gf.." "..sf.." "..cf

end

-- List of characters for an account on a realm.
--
local function listChars(realm,acct)

   -- empty table and parameters
   local chars = {}
   realm = realm or myRealm
   acct = acct or myAccount

   -- loop over and look for ones that match this realm/acct
   local i = 1
   for k, v in pairs(charDB) do
      ak,rk,ck = strsplit("/", k)
      if ak and rk then
	 if ak == acct and rk == realm then
	    chars[i] = k
	    i = i + 1
	 end
      end
   end

   -- sort the list
   table.sort(chars)

   -- and we're done
   return chars

end

function Generalissimo:OnInitialize()
   -- Database!
   self.db = LibStub("AceDB-3.0"):New("GeneralissimoDB", db_defaults, true)
   charDB = self.db.global.Characters
   guildDB = self.db.global.Guilds

   -- dummy slash command
   self:RegisterChatCommand("gen","ToggleFrame")

   -- Labels in the header
   GeneralissimoSummaryInteriorHeader.name.text:SetText("Name")
   GeneralissimoSummaryInteriorHeader.level.text:SetText("Level")
   GeneralissimoSummaryInteriorHeader.ail.text:SetText("AIL")
   GeneralissimoSummaryInteriorHeader.gold.text:ClearAllPoints()
   GeneralissimoSummaryInteriorHeader.gold.text:SetPoint("CENTER")
   GeneralissimoSummaryInteriorHeader.gold.text:SetText("Money")

end

local function ClassifyName(n,c)
   c = c or "PRIEST" -- nice plain white name if we happened to not get the class
   return format("%s%s", addon.Colors["class"..c], n)
end

function Generalissimo:OnShow()

   -- Total gold, total levels, total (for average) AIL
   local totalgold = 0
   local totallevels = 0
   local totalail = 0

   -- Now print how much money everyone has.
   for i,k in ipairs(listChars()) do

      local _, _, name = strsplit("/", k)

      local fn = "GeneralissimoCharFrame"..i

      -- Have we exceeded our max number of character frames?
      if i > #charFrame then
	 charFrame[i] = CreateFrame("Frame",fn,GeneralissimoSummaryInterior,"GeneralissimoCharacterTemplate")
	 -- Anchor the new frame to the last one.
	 if i == 1 then
	    charFrame[i]:SetPoint("TOPLEFT",GeneralissimoSummaryInteriorHeader,"BOTTOMLEFT",0,-5)
	 else
	    charFrame[i]:SetPoint("TOPLEFT",charFrame[i-1],"BOTTOMLEFT",0,-5)
	 end
      end

--      charFrame[i].name.over:SetText(ClassifyName(charDB[k].localClass or charDB[k].class or "Unknown",charDB[k].class))

      charFrame[i].name.text:SetText(ClassifyName(name, charDB[k].class))
      charFrame[i].level.text:SetText(charDB[k].level)
      charFrame[i].ail.text:SetText(charDB[k].ail == nil and "--" or format("%.1f",charDB[k].ail))
      charFrame[i].gold.text:SetText(GetGenCoin(charDB[k].Currency['gold']))
      totalgold = totalgold + charDB[k].Currency['gold']
      totallevels = totallevels + charDB[k].level
      totalail = totalail + (charDB[k].ail == nil and 0 or charDB[k].ail)

   end

   GeneralissimoFrame.totals.name.text:SetText("Total/Avg*")
   GeneralissimoFrame.totals.level.text:SetText(floor(totallevels/#charFrame).."*")
   GeneralissimoFrame.totals.ail.text:SetText(floor(totalail/#charFrame).."*")
   GeneralissimoFrame.totals.gold.text:SetText(GetGenCoin(totalgold))
   
end

function Generalissimo:LoadCharacter()
   -- Cash!
   charDB[charKey()].Currency = charDB[charKey()].Currency or {}
   charDB[charKey()].Currency['gold'] = GetMoney()

   -- Level
   charDB[charKey()].level = UnitLevel("player")

   -- Item level
   charDB[charKey()].ail = GetAverageItemLevel()

   -- Faction
   charDB[charKey()].faction = UnitFactionGroup("player")

   -- Class
   charDB[charKey()].localClass, charDB[charKey()].class, _ = UnitClass("player")

end

function Generalissimo:ToggleFrame()
      if (GeneralissimoFrame:IsVisible()) then
	 GeneralissimoFrame:Hide()
      else
	 GeneralissimoFrame:Show()
      end
end

function Generalissimo:OnEnable()

   --
   -- Events we care about
   --

   -- Entered the world.
   self:RegisterEvent("PLAYER_ENTERING_WORLD")

   -- Amount of money I have changed.
   self:RegisterEvent("PLAYER_MONEY")

end

function Generalissimo:OnDisable()
    -- Called when the addon is disabled
end

function Generalissimo:PLAYER_ENTERING_WORLD()
   -- Is this character in the DB already?  If not, let's make an
   -- empty table for them.
   
   if (charDB[charKey()] == nil) then
      charDB[charKey()] = newChar()
   end

   self:LoadCharacter()

end

function Generalissimo:PLAYER_MONEY()
   local cash = GetMoney()
   charDB[charKey()].Currency['gold'] = cash
end

local function newChar()
   local c = {}
   c.Currency = {}
   return c
end

