local shared_package_init = include("../Quaker/character.lua")
local character_id = "com.louise.enemy."
function package_init(character)
    local character_info = {
        name = "Shaker",
        hp = 120,
        damage = 100,
        palette = _folderpath .. "palette.png",
        height = 44,
        frames_between_actions = 78,
        shockwave_anim = "shockwave_fast.animation",
        cascade_frame = 3
    }

    shared_package_init(character, character_info)
end
