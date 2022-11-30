local Player = FindMetaTable("Player")
function Player:HasBoughtEntity(class, requireBeacon, requireAnchor)
    self.BoughtEntities = self.BoughtEntities or {}
    for i, ent in pairs(self.BoughtEntities[class] or {}) do
        if not IsValid(ent) then
            table.remove(self.BoughtEntities[class], i)
            continue
        end
        if ent:CPPIGetOwner() == self and (not requireBeacon or ent:WithinBeacon()) and (not requireAnchor or (ent.GetAnchored and ent:GetAnchored())) then
            return true, ent
        end
    end
    return false
end

function Player:CountBoughtEntities(class)
    local count = 0
    self.BoughtEntities = self.BoughtEntities or {}
    for i, ent in pairs(self.BoughtEntities[class] or {}) do
        if not IsValid(ent) then
            table.remove(self.BoughtEntities[class], i)
            continue
        end
        count = count + 1
    end
    return count
end

function Player:OwnsBoughtEntity(ent)
    self.BoughtEntities = self.BoughtEntities or {}
    for i, e in pairs(self.BoughtEntities[ent:GetClass()] or {}) do
        if not IsValid(e) then
            table.remove(self.BoughtEntities[ent:GetClass()], i)
            continue
        end
        if e == ent then
            return true
        end
    end
    return false
end