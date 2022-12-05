CreateConVar("pt_sandbox", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Allow sandbox spawning.", 0, 1)
CreateConVar("pt_deathcam", 5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Deathcam.")

CreateConVar("pt_money_starting", 5000, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Starting cash for players.", 0)
CreateConVar("pt_money_dropondeath", 0.2, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Fraction of your current money that will be dropped on death.", 0, 1)
CreateConVar("pt_money_dropondeath_min", 5000, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Amount of money that won't be dropped on death.", 0)
CreateConVar("pt_money_dropondeath_max", 100000, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Maximum amount of money you can drop. 0 - infinite.", 0)
CreateConVar("pt_money_dropondeath_takemult", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Fraction of the death drop money that will go into the player's pocket immediately. The rest are dropped on the ground.", 0, 1)

CreateConVar("pt_money_guncost", 1000, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Weapon cost when you don't have an Arsenal.", 0)
CreateConVar("pt_money_sellmult", 0.75, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Price multiplier when you sell something.", 0, 1)
CreateConVar("pt_money_killmult", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Price multiplier when you destroy something.", 0, 1)
CreateConVar("pt_money_nukemult", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Price multiplier when you destroy or sell the nuke.", 0, 1)
CreateConVar("pt_money_airmult", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Price multiplier when you destroy enemy aircraft.", 0, 1)

CreateConVar("pt_nuke_time", 180, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Nuke arm duration.", 5)

CreateConVar("pt_airdrop_amount", 250000, FCVAR_ARCHIVE + FCVAR_REPLICATED, "How much money an airdrop will carry.", 0)
CreateConVar("pt_airdrop_planehealth", 2500, FCVAR_ARCHIVE + FCVAR_REPLICATED, "The durability of the airdrop plane.", 0)
CreateConVar("pt_airdrop_moneyhealth", 800, FCVAR_ARCHIVE + FCVAR_REPLICATED, "The durability of the parachute. If destroyed, it will fall immediately.", 0)

CreateConVar("pt_tele_recall_cooldown", 180, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Pocket Teleporter cooldown for recall.", 0)
CreateConVar("pt_tele_recall_delay", 10, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Pocket Teleporter delay for recall.", 0)
CreateConVar("pt_tele_disperse_cooldown", 60, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Pocket Teleporter cooldown for disperse.", 0)
CreateConVar("pt_tele_disperse_delay", 5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Pocket Teleporter delay for disperse.", 0)

CreateConVar("pt_prop_ghost", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Ghost props.", 0, 1)
CreateConVar("pt_beacon_radius", 2048, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Protection radius for the Base Beacon.", 512)
CreateConVar("pt_beacon_mobile_radius", 256, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Protection radius for the Mobile Beacon.", 128)

CreateConVar("pt_prop_quota_disable", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Disable prop quota entirely (for testing).", 0, 1)
CreateConVar("pt_prop_quota", 50000, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Total amount of health a player's props can have. 0 - infinite.", 0)

CreateConVar("pt_npc_max", 60, FCVAR_REPLICATED, "Total amount of NPCs that can be spawned at once.", 0)

CreateConVar("pt_dev_airffa", 0, FCVAR_REPLICATED, "Make aircraft and anti-air engage everything.", 0, 1)
CreateConVar("pt_dev_wtf", 0, FCVAR_REPLICATED, "Bypass shop cooldowns.", 0, 1)
CreateConVar("pt_dev_communism", 0, FCVAR_REPLICATED, "It's all free, comrade!", 0, 1)
CreateConVar("pt_dev_lonely", 0, FCVAR_REPLICATED, "No NPC spawning.", 0, 1)

hook.Add("Profiteers_IsFriendly", "airffa", function(ent1, ent2)
    if GetConVar("pt_dev_airffa"):GetBool() and (ent1.IsAirAsset or ent2.IsAirAsset) then
        return false
    end
end)