local create_obstacle_from_data = include("create_obstacle.lua")

function create_obstacle()
    local obstacle_data = {
        health = 200,
        texture = Engine.load_texture(_folderpath.."rock.png"),
        animation_path = _folderpath.."rock.animation",
        pushable = true,
        insta_break = true,
        can_continue_sliding = false
    }
    local obstacle = create_obstacle_from_data(obstacle_data)
    return obstacle
end

return create_obstacle