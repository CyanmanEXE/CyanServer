
local encounter1 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Bladia6",rank=1},
        {name="Swordy",rank=8},
     
    },
    positions = {
        
        {0,0,0,0,2,0},
        {0,0,0,0,0,1},
        {0,0,0,0,2,0}
    },
    tiles = {
        {7,1,1,11,1,12},
        {7,1,1,11,1,1},
        {7,1,1,11,1,9}
    },
    teams = {
        {2,2,1,1,1,1},
        {2,2,1,1,1,1},
        {2,2,1,1,1,1}
    },
}


local encounter2 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="JokerEye",rank=1},
        {name="FighterPlane",rank=4},
        {name="Gloomer",rank=1},
     
    },
    positions = {
        
        {0,0,0,0,0,2},
        {0,0,0,0,1,0},
        {0,0,0,0,0,3}
    },
    tiles = {
        {1,1,1,1,1,1},
        {1,1,1,1,1,1},
        {1,1,1,1,1,1}
    },
}


local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="JokerEye",rank=1},
        {name="Canosmart",rank=1},
        {name="Sniper",rank=1},
        {name="Metrid",rank=4},
    },
    positions = {
        
        {0,0,0,0,0,3},
        {0,0,0,4,2,1},
        {0,0,0,0,0,3}
    },
    tiles = {
        {13,1,1,1,1,1},
        {12,11,1,1,1,1},
        {9,1,1,1,1,1}
    },
    obstacles = {
        {name="BlastCube"},
    },
    obstacle_positions = {
        {0,0,1,0,0,0},
        {0,0,0,0,0,0},
        {0,0,1,0,0,0}
    },    
}

return {
    minimum_steps_before_encounter=80,
    encounter_chance_per_step=0.9,
    encounters={encounter1, encounter2, encounter3}
}


