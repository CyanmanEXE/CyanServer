
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
    
}

local encounter2 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
        {name="CirKill",rank=1},
        {name="Knichovi",rank=1},
        
    },
    positions = {
        
        {0,0,0,0,0,2},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="Volcano",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter4 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="Lark",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="Skarab",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="Scutz",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="Flashy",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="Dominerd",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="Cragger",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="DarkMech",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="RayCannon",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=90,
    enemies = {
       
        
        {name="Juraigon",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    
}

return {
    minimum_steps_before_encounter=90,
    encounter_chance_per_step=0.9,
    encounters={encounter1, encounter2, encounter3}
}


