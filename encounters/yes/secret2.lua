
local encounter1 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Doomer",rank=1},--add in!
        
        
        
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,0,1},
        {0,0,0,0,0,0}
    },
    tiles = {
        {2,2,2,2,2,2},
        {1,1,1,1,1,1},
        {2,2,2,2,2,2}
    },

    
}

local encounter2 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Basher",rank=1},
        
        
      
        
    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,0,0,2},
        {0,0,0,0,2,0}
    },
    tiles = {
        {1,1,13,1,1,1},
        {1,1,1,1,1,13},
        {1,13,1,1,13,1}
    },
 
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Spikey",rank=3},
        {name="Metrodo",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,2},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    tiles = {
        {1,1,13,1,1,1},
        {1,1,1,1,1,13},
        {1,13,1,1,13,1}
    },

   
}


local encounter4 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Doomer",rank=1},
        
        
        
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,1,0},
        {0,0,0,0,0,0}
    },
    tiles = {
        {1,1,1,2,1,1},
        {1,2,1,1,1,2},
        {2,1,1,1,1,1}
    },
    
   
}

local encounter5 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Metrodo",rank=1},
        {name="Doomer",rank=1},
        
        
    },
    positions = {
        
        {0,0,0,0,0,0},
        {0,0,0,0,0,1},
        {0,0,0,0,2,0}
    },
    tiles = {
        {1,11,1,1,11,1},
        {1,1,1,1,1,1},
        {1,11,1,1,11,1}
    },
   
}


local encounter6 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Volcaner",rank=1},
        {name="Basher",rank=1},
    
        
    },
    positions = {
        
        {0,0,0,0,2,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,1}
    },
    tiles = {
        {13,1,1,1,1,13},
        {1,1,13,13,1,1},
        {1,1,13,13,1,1}
    },
    
}


local encounter7 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Volcaner",rank=1},
        {name="Volcano",rank=1},
    },
    positions = {
        
        {0,0,0,0,0,2},
        {0,0,0,0,0,0},
        {0,0,0,1,0,0}
    },
    tiles = {
        {12,12,12,12,12,12},
        {12,12,12,12,12,12},
        {13,12,12,12,12,13}
    },

}


local encounter8 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Mettaur",rank=3},
        
        
    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,1,0}
    },
    tiles = {
        {1,1,1,1,1,1},
        {2,2,2,2,2,2},
        {1,1,1,1,1,1}
    },


}




return {
    minimum_steps_before_encounter=230,
    encounter_chance_per_step=0.2,
    encounters={encounter1, encounter2, encounter3, encounter4, encounter5, encounter6, encounter7, encounter8}
}


