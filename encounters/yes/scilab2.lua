
local encounter1 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Fishy",rank=1},
        {name="Canodumb",rank=1},
        
        
    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,0,0,2},
        {0,0,0,0,0,0}
    },
    
}

local encounter2 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Swordy",rank=1},
        {name="Canodumb",rank=1},
      
        
    },
    positions = {
        
        {0,0,0,0,1,0},
        {0,0,0,0,0,2},
        {0,0,0,1,0,0}
    },
    
}

local encounter3 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Canodumb",rank=1},
        {name="Quaker",rank=1},
    },
    positions = {
        
        {0,0,0,0,1,0},
        {0,0,0,0,0,2},
        {0,0,0,0,1,0}
    },
    
}


local encounter4 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Fishy",rank=1},
        {name="Quaker",rank=1},
        
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,0,0},
        {0,0,0,2,0,0}
    },
    
}

local encounter5 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Ratty",rank=1},
        {name="Boomer",rank=1},
        
        
    },
    positions = {
        
        {0,0,0,0,2,0},
        {0,0,0,0,0,1},
        {0,0,0,0,0,0}
    },
    
}


local encounter6 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Ratty",rank=1},
    
        
    },
    positions = {
        
        {0,0,0,0,1,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,1}
    },
    
}


local encounter7 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Swordy",rank=1},
        {name="Ratty",rank=1},
        
        
    },
    positions = {
        
        {0,0,0,0,1,0},
        {0,0,0,0,0,0},
        {0,0,0,0,2,0}
    },
    
}


local encounter8 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Quaker",rank=1},
        
    },
    positions = {
        
        {0,0,0,1,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,1}
    },
    
}


local encounter9 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Fishy",rank=1},
        
        
    },
    positions = {
        
        {0,0,0,0,0,1},
        {0,0,0,0,0,0},
        {0,0,0,1,0,0}
    },
    
}

local encounter10 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Fishy",rank=1},
        {name="Ratty",rank=1},
        
    },
    positions = {
        
        {0,0,0,2,0,0},
        {0,0,0,0,2,0},
        {0,0,0,0,0,1}
    },
    
}

local encounter11 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Ratty",rank=1},
        {name="Quaker",rank=1},
        
    },
    positions = {
        
        {0,0,0,2,0,1},
        {0,0,0,0,0,0},
        {0,0,0,0,1,0}
    },
    
}

local encounter12 = {
    path="/server/assets/ezlibs-assets/ezencounters/ezencounters.zip",
    weight=8,
    enemies = {
        {name="Swordy",rank=1},
        {name="Fishy",rank=1},
        {name="Boomer",rank=1},
        
    },
    positions = {
        
        {0,0,0,0,2,0},
        {0,0,0,1,0,0},
        {0,0,0,0,0,3}
    },
    
}


return {
    minimum_steps_before_encounter=230,
    encounter_chance_per_step=0.2,
    encounters={encounter1, encounter2, encounter3, encounter4, encounter5, encounter6, encounter7, encounter8, encounter9, encounter10, encounter11, encounter12}
}


