
local encounter1 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Metrid",rank=4},--!
        {name="Spikey",rank=4},
        {name="WindBox",rank=8},
        {name="Quaker",rank=3},
    },
    positions = {
        
        {0,0,0,0,4,0},
        {0,0,0,1,0,3},
        {0,0,0,0,2,0}
    },
    tiles = {
        {2,1,9,11,1,11},
        {1,1,9,11,11,11},
        {1,1,2,11,1,11}
    },
}



local encounter2 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Ratty",rank=4},--!
        {name="MegaBunny",rank=1},
        {name="HauntedCandle",rank=7},
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,2,0},
        {0,0,0,3,0,3}
    },
    tiles = {
        {1,2,14,11,11,11},
        {2,12,14,11,11,11},
        {13,1,2,11,11,11}
    },
    obstacles = {
        {name="BlastCube"},
    },
    obstacle_positions = {
        {1,1,0,0,0,0},
        {1,0,0,0,0,0},
        {1,1,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="JokerEye",rank=1},--!
        {name="WindBox",rank=8},
        {name="Puffy",rank=1},
    },
    positions = {
        
        {0,0,0,0,1,2},
        {0,0,0,0,0,3},
        {0,0,0,0,1,0}
    },
    
}

local encounter4 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Puffy",rank=1},--!
        {name="Quaker",rank=3},
        
    },
    positions = {
        
        {0,0,0,2,0,1},
        {0,0,0,2,0,1},
        {0,0,0,2,0,1}
    },
    
}

local encounter5 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Canosmart",rank=1},--!
        {name="Volgear",rank=4},
        {name="Metrid",rank=4},
    },
    positions = {
        
        {0,0,0,0,3,0},
        {0,0,0,0,1,2},
        {0,0,0,1,0,0}
    },
    obstacles = {
        {name="IceCube"},
    },
    obstacle_positions = {
        {1,0,0,0,0,1},
        {0,0,0,1,0,0},
        {0,0,1,0,0,0}
    },    
    tiles = {
        {1,8,1,1,1,1},
        {12,9,1,1,1,1},
        {15,9,1,1,1,1}
    },
    
}

local encounter6 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Bladia6",rank=1},--!
        {name="HauntedCandle",rank=1},
        {name="HotHead",rank=1},
        {name="Gloomer",rank=1},

    },
    positions = {
        
        {0,0,0,4,0,0},
        {0,0,0,3,1,2},
        {0,0,0,4,0,0}
    },
    
}


local encounter7 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Powie3",rank=5},--!
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
        {name="OldBurner",rank=1},--!
        {name="VacuumFan",rank=4},
        {name="BigBrute",rank=1},
        {name="Volgear",rank=4},
    },
    positions = {
        
        {0,0,0,0,1,0},
        {0,0,0,4,3,2},
        {0,0,0,0,1,0}
    },
    tiles = {
        {2,1,13,9,1,1},
        {2,2,2,2,11,11},
        {1,1,9,9,1,1}
    },
    obstacles = {
        {name="RockCube"},
    },
    obstacle_positions = {
        {1,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,1,0,0,0}
    },    
}

local encounter9 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Bugtank",rank=1,max_hp=500,nickname="Ar24Grds"},--!
        
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
        {name="WindBox",rank=8},--!
        {name="HotHead",rank=1},
        
    },
    positions = {
        
        {0,0,0,0,2,0},
        {0,0,0,0,2,1},
        {0,0,0,0,2,0}
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
        {name="Puffy",rank=1,max_hp=500,nickname="Nightmare"},--!

        
    },
    positions = {
        
        {0,0,0,0,1,1},
        {0,0,0,0,1,1},
        {0,0,0,0,1,1}
    },
    tiles = {
        {1,1,1,11,11,11},
        {1,1,1,11,11,11},
        {1,1,1,11,11,11}
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

local encounter12 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Puffy",rank=1,max_hp=500,nickname="Nightmar2"},--!

        
    },
    positions = {
        
        {0,0,0,0,1,1},
        {0,0,0,0,1,1},
        {0,0,0,0,1,1}
    },
    tiles = {
        {1,1,1,11,11,11},
        {1,1,1,11,11,11},
        {1,1,1,11,11,11}
    },
    obstacles = {
        {name="RockCube"},
    },
    obstacle_positions = {
        {1,1,1,1,0,0},
        {1,0,1,1,0,0},
        {1,1,1,1,0,0}
    },    
}

return {
    minimum_steps_before_encounter=90,
    encounter_chance_per_step=0.7,
    encounters={encounter1, encounter2, encounter3, encounter4, encounter5, encounter6, encounter7, encounter8, encounter9, encounter10, encounter11, encounter12}
}


