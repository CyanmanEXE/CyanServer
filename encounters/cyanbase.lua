
local encounter1 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=100,
    enemies = {
        {name="Swordy",rank=8},
        {name="Bladia6",rank=1},
        {name="Chimpy",rank=1},
        {name="JokerEye",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,3,4,2},
        {0,0,0,0,0,1}
    },
    tiles = {
        {11,11,11,11,11,11},
        {9,9,9,9,9,9},
        {11,11,11,11,1,11}
    },
    music={
        path="CyanServer/assets/vschamp.ogg"
    }
}





return {
    minimum_steps_before_encounter=90,
    encounter_chance_per_step=0.9,
    encounters={encounter1}
}


