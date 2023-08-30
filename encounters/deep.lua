
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

local encounter12 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Canosmart",rank=1},
        {name="Sniper",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,0,2},
        {0,0,0,0,0,1}
    },
    
}
local encounter13 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=40,
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
    
}
local encounter14 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Ratty",rank=4},--!
        {name="OldBurner",rank=1},
        {name="Volgear",rank=3},
        {name="Metrid",rank=3},
    },
    positions = {
        
        {0,0,0,0,0,2},
        {0,0,0,0,0,1},
        {0,0,0,4,3,0}
    },
    tiles = {
        {2,1,8,1,1,11},
        {1,1,9,9,9,9},
        {1,8,2,11,1,11}
    },

}



local encounter15 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Fishy",rank=4},
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,1,0},
        {0,0,0,1,0,0}
    },
    tiles = {
        {5,5,5,5,5,5},
        {11,1,1,1,1,1},
        {11,1,1,1,1,1}
    },
    obstacles = {
        {name="IceCube"},
    },
    obstacle_positions = {
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,1}
    },
   
}

local encounter16 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="JokerEye",rank=1},--!
        {name="WindBox",rank=8},
        {name="Chimpy",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,3},
        {0,0,0,1,0,0},
        {0,0,0,0,0,2}
    },
  
}

local encounter17 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Bladia6",rank=1},--!
        {name="ColdHead",rank=1},
        
    },
    positions = {
        
        {0,0,0,2,0,0},
        {0,0,0,2,0,1},
        {0,0,0,2,0,0}
    },
 
}

local encounter18 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Canosmart",rank=1},--!
        {name="Catack",rank=4},
        {name="Metrid",rank=4},
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,2,3},
        {0,0,0,0,0,1}
    },
    tiles = {
        {1,1,6,1,1,1},
        {7,1,6,1,1,1},
        {1,1,6,1,1,1}
    },
  
}

local encounter19 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Catack",rank=4},--!
        {name="Fishy",rank=3},
        {name="Metrid",rank=1},
        {name="Powie3",rank=1},

    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,0,2,0},
        {0,0,0,3,0,4}
    },
  
}


local encounter20 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Powie3",rank=5},--!
        {name="FighterPlane",rank=4},
        {name="Canosmart",rank=1},
        {name="JokerEye",rank=1},
    },
    positions = {
        
        {0,0,0,0,1,4},
        {0,0,0,0,0,2},
        {0,0,0,0,1,3}
    },
 
}



local encounter21 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Basher",rank=1},--!
        {name="VacuumFan",rank=4},
        {name="Mettaur",rank=3},
        
    },
    positions = {
        
        {0,0,0,0,0,3},
        {0,0,0,0,2,1},
        {0,0,0,0,0,3}
    },
    tiles = {
        {2,1,1,1,9,1},
        {1,12,1,1,1,1},
        {14,1,2,1,9,1}
    },
    obstacles = {
        {name="RockCube"},
    },
    obstacle_positions = {
        {0,0,0,0,0,0},
        {0,0,0,1,0,0},
        {0,0,0,0,0,0}

    },

    } 


local encounter22 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Swordy",rank=3},--!
        {name="Swordy",rank=4},
        {name="Swordy",rank=8},
    },
    positions = {
        
        {0,0,0,1,0,1},
        {0,0,0,0,3,0},
        {0,0,0,2,0,2}
    },

}

local encounter23 = {
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
        {1,1,1,8,1,1},
        {11,1,11,1,1,1},
        {1,1,1,8,1,1}
    },

}

local encounter24 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Swordy",rank=8,},--!

        
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,0,1},
        {0,0,0,0,0,1}
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
        {0,0,0,0,0,0},
        {0,0,1,1,0,0},
        {0,0,0,0,0,0}
    },
   
}

local encounter25 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="GigaCorn",rank=1},--!
        {name="OldBurner",rank=1},
        {name="Volgear",rank=3},
        {name="Metrid",rank=3},
    },
    positions = {
        
        {0,0,0,0,0,2},
        {0,0,0,0,0,1},
        {0,0,0,4,3,0}
    },
    tiles = {
        {2,1,8,1,1,11},
        {1,1,9,9,9,9},
        {1,8,2,11,1,11}
    },
}



local encounter26 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Fishy",rank=4},
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,1,0},
        {0,0,0,1,0,0}
    },
    tiles = {
        {5,5,5,5,5,5},
        {11,1,1,1,1,1},
        {11,1,1,1,1,1}
    },
    obstacles = {
        {name="IceCube"},
    },
    obstacle_positions = {
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,1}
    },
    
}

local encounter27 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="JokerEye",rank=1},--!
        {name="WindBox",rank=8},
        {name="Chimpy",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,3},
        {0,0,0,1,0,0},
        {0,0,0,0,0,2}
    },
    
}

local encounter28 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Bladia6",rank=1},--!
        {name="ColdHead",rank=1},
        
    },
    positions = {
        
        {0,0,0,2,0,0},
        {0,0,0,2,0,1},
        {0,0,0,2,0,0}
    },
    
}

local encounter29 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Canosmart",rank=1},--!
        {name="Doomer",rank=1},
        {name="Metrid",rank=4},
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,2,3},
        {0,0,0,0,0,1}
    },
    tiles = {
        {1,1,6,1,1,1},
        {7,1,6,1,1,1},
        {1,1,6,1,1,1}
    },
    
}

local encounter30 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Catack",rank=4},--!
        {name="Fishy",rank=3},
        {name="Metrid",rank=1},
        {name="Gloomer",rank=1},

    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,0,2,0},
        {0,0,0,3,0,4}
    },
    
}


local encounter31 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Powie3",rank=5},--!
        {name="FighterPlane",rank=4},
        {name="Canosmart",rank=1},
        {name="JokerEye",rank=1},
    },
    positions = {
        
        {0,0,0,0,1,4},
        {0,0,0,0,0,2},
        {0,0,0,0,1,3}
    },
    
}



local encounter32 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Basher",rank=1},--!
        {name="VacuumFan",rank=4},
        {name="Canodumb",rank=3},
        
    },
    positions = {
        
        {0,0,0,0,0,3},
        {0,0,0,0,2,1},
        {0,0,0,0,0,3}
    },
    tiles = {
        {2,1,1,1,9,1},
        {1,12,1,1,1,1},
        {14,1,2,1,9,1}
    },
    obstacles = {
        {name="RockCube"},
    },
    obstacle_positions = {
        {0,0,0,0,0,0},
        {0,0,0,1,0,0},
        {0,0,0,0,0,0}
    },    
}

local encounter33 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Mettaur",rank=3},--!
        {name="Mettaur",rank=4},
       
    },
    positions = {
        
        {0,0,0,1,0,1},
        {0,0,0,0,2,0},
        {0,0,0,2,0,2}
    },
}

local encounter34 = {
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
        {1,1,1,8,1,1},
        {11,1,11,1,1,1},
        {1,1,1,8,1,1}
    },
}

local encounter35 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=50,
    enemies = {
        {name="Bladia6",rank=1,},--!

        
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,0,1},
        {0,0,0,0,0,1}
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

return {
    minimum_steps_before_encounter=230,
    encounter_chance_per_step=0.2,
    encounters={encounter1, encounter2, encounter3, encounter4, encounter5, encounter6, encounter7, encounter8, encounter9, encounter10, encounter11, encounter12, encounter13, encounter14, encounter15, encounter16, encounter17, encounter18, encounter19, encounter20, encounter21, encounter22, encounter23, encounter24, encounter25, encounter26, encounter27, encounter28, encounter29, encounter30, encounter31, encounter32, encounter33, encounter34, encounter35}
}


