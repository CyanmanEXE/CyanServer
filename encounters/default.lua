
local encounter1 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Mettaur",rank=6},
        {name="Bladia",rank=1},
        {name="Gunner",rank=7},
        {name="HardHead",rank=1},
    },
    positions = {
        
        {0,0,0,4,0,4},
        {0,0,0,2,1,2},
        {0,0,0,3,0,0}
    },
    
}



local encounter2 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="MegaBunny",rank=1},
        {name="Metrid",rank=4},
        {name="Gunner",rank=7},
    },
    positions = {
        
        {0,0,0,0,1,0},
        {0,0,0,2,1,2},
        {0,0,0,1,0,3}
    },
    tiles = {
        {1,1,14,11,11,11},
        {13,12,14,11,11,11},
        {1,1,14,11,11,11}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Sniper",rank=1},
        {name="Canosmart",rank=1},
        {name="JokerEye",rank=1},
        {name="WindBox",rank=8}
    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,2,0,4},
        {0,0,0,0,3,0}
    },
    
}

local encounter4 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Powie3",rank=5},--1
        {name="Fishy",rank=4},
        {name="JokerEye",rank=1},
    },
    positions = {
        
        {0,0,0,1,0,2},
        {0,0,0,0,3,0},
        {0,0,0,0,3,2}
    },
    
}

local encounter5 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="KillerEye",rank=7},--1
        {name="Volgear",rank=4},
        {name="Metrid",rank=4},
    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,0,2,3},
        {0,0,0,1,3,0}
    },
    obstacles = {
        {name="BlastCube"},
    },
    obstacle_positions = {
        {0,0,0,0,1,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0}
    },    
    
}

local encounter6 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Basher",rank=1},
        {name="RareChampy",rank=1},
        {name="HauntedCandle",rank=7},
    },
    positions = {
        
        {0,0,0,0,1,3},
        {0,0,0,0,0,2},
        {0,0,0,0,0,3}
    },
    
}


local encounter7 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Powie3",rank=5},
        {name="FighterPlane",rank=4},
        {name="Canosmart",rank=1},
        {name="JokerEye",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,4,3,1},
        {0,0,0,0,0,2}
    },
    
}



local encounter8 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="GigaCorn",rank=1},
        {name="Cacter",rank=5},
        {name="Volgear",rank=4},
        {name="Metrid",rank=4},
    },
    positions = {
        
        {0,0,0,1,3,4},
        {0,0,0,2,0,2},
        {0,0,0,3,0,4}
    },
    tiles = {
        {1,1,9,9,1,1},
        {12,12,12,12,12,12},
        {1,1,9,9,1,1}
    },
    obstacles = {
        {name="BlastCube"},
    },
    obstacle_positions = {
        {1,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,1,0,0,0}
    },    
}

local encounter9 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=70,
    enemies = {
        {name="Sniper",rank=1,max_hp=500,starting_hp=500,nickname="Ar51Grds"},

    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,0,1},
        {0,0,0,0,0,1}
    },
    tiles = {
        {8,15,8,8,8,1},
        {8,15,8,8,8,1},
        {8,15,8,8,8,1}
    },
}

local encounter10 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Canosmart",rank=1},
        {name="HotHead",rank=1},
        
    },
    positions = {
        
        {0,0,0,0,2,1},
        {0,0,0,0,2,1},
        {0,0,0,0,2,1}
    },
    tiles = {
        {8,1,8,8,1,1},
        {8,1,8,1,1,1},
        {8,1,8,8,1,1}
    },
}

local encounter11 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Puffy",rank=1,max_hp=500,starting_hp=500,nickname="Nightmare"},

        
    },
    positions = {
        
        {0,0,0,0,1,1},
        {0,0,0,0,1,1},
        {0,0,0,0,1,1}
    },
    tiles = {
        {1,1,1,1,1,1},
        {1,1,1,1,1,1},
        {1,1,1,1,1,1}
    },
    obstacles = {
        {name="RockCube"},
    },
    obstacle_positions = {
        {0,0,1,1,0,0},
        {0,0,1,1,0,0},
        {0,0,1,1,0,0}
    },    
}


return {
    minimum_steps_before_encounter=230,
    encounter_chance_per_step=0.2,
    encounters={encounter1, encounter2, encounter3, encounter4, encounter5, encounter6, encounter7, encounter8, encounter9, encounter10, encounter11}
}


