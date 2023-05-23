
local encounter1 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=5,
    enemies = {
        {name="DemonEye",rank=1},--add in!
        {name="TuffBunny",rank=1},
        
        
    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,2}
    },  
    tiles = {
        {9,9,14,9,9,14},
        {9,14,9,9,14,9},
        {14,9,9,14,9,9}
    },
    player_positions = {
        {0,0,0,0,0,0},
        {1,0,0,0,0,0},
        {0,0,0,0,0,0}
    },
    
}

local encounter2 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=5,
    enemies = {
        {name="TuffBunny",rank=1},
        
        
      
        
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0}
    },
    tiles = {
        {9,14,14,14,14,9},
        {9,14,14,14,14,9},
        {9,14,14,14,14,9}
    },
    player_positions = {
        {0,0,0,0,0,0},
        {1,0,0,0,0,0},
        {0,0,0,0,0,0}
    },
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=5,
    enemies = {
        {name="DemonEye",rank=1},
        
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,1,0,0}
    },
    tiles = {
        {14,9,9,9,9,14},
        {14,9,9,9,9,14},
        {14,9,9,9,9,14}
    },
   
}


local encounter4 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=5,
    enemies = {
        {name="TuffBunny",rank=1},
        
        
        
    },
    positions = {
        
        {0,0,0,0,1,0},
        {0,0,0,0,0,0},
        {0,0,0,0,1,0}
    },
    tiles = {
        {14,9,9,9,9,14},
        {14,9,9,9,9,14},
        {14,9,9,9,9,14}
    },
    
   
}

local encounter5 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=5,
    enemies = {
        {name="TuffBunny",rank=1},
        
        
        
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    tiles = {
        {9,14,14,9,9,9},
        {9,9,14,14,9,9},
        {9,9,9,14,14,9}
    },
   
}


local encounter6 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=5,
    enemies = {
        {name="Mettaur",rank=3},
       
    
        
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,1,1}
    },
    tiles = {
        {9,9,9,9,14,14},
        {14,14,9,9,14,14},
        {14,14,9,9,9,9}
    },
    player_positions = {
        {0,1,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0}
    },
    
}


local encounter7 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=5,
    enemies = {
        {name="Mettaur",rank=3},
        {name="TuffBunny",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,1,0,0},
        {0,0,0,0,1,0}
    },
    tiles = {
        {9,9,9,9,14,14},
        {14,14,9,9,14,14},
        {14,14,9,9,9,9}
    },
    player_positions = {
        {0,1,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0}
    },
}


local encounter8 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=5,
    enemies = {
        {name="DemonEye",rank=1},
        
        
    },
    positions = {
        
        {0,0,0,0,1,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0}
    },
    tiles = {
        {9,9,9,9,9,9},
        {14,14,14,14,14,14},
        {9,9,9,9,9,9}
    },
}






return {
    minimum_steps_before_encounter=230,
    encounter_chance_per_step=0.2,
    encounters={encounter1, encounter2, encounter3, encounter4, encounter5, encounter6, encounter7, encounter8}
}


--remind self to add in darkman encounters (5/12/23)