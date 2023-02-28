local shared_package_init = include("../Quaker/character.lua")
local character_id = "com.louise.enemy."
function package_init(character)
    local character_info = {
        name = "Breaker",
        hp = 200,
        damage = 100,
        palette = _folderpath .. "palette.png",
        height = 44,
        shockwave_anim = "shockwave_fast.animation",
        frames_between_actions = 78,
        cascade_frame = 4
    }

    shared_package_init(character, character_info)
end
