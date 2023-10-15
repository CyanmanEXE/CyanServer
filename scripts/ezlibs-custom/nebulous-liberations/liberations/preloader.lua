local Preloader = {}

local asset_paths = {
  "/server/assets/NebuLibsAssets/bots/blur.png",
  "/server/assets/NebuLibsAssets/bots/blur.animation",
  "/server/assets/NebuLibsAssets/bots/explosion.png",
  "/server/assets/NebuLibsAssets/bots/explosion.animation",
  "/server/assets/NebuLibsAssets/bots/paralyze.png",
  "/server/assets/NebuLibsAssets/bots/paralyze.animation",
  "/server/assets/NebuLibsAssets/bots/recover.png",
  "/server/assets/NebuLibsAssets/bots/recover.animation",
  "/server/assets/NebuLibsAssets/bots/item.png",
  "/server/assets/NebuLibsAssets/bots/item.animation",
  "/server/assets/NebuLibsAssets/sound effects/hurt.ogg",
  "/server/assets/NebuLibsAssets/sound effects/explode.ogg",
  "/server/assets/NebuLibsAssets/sound effects/paralyze.ogg",
  "/server/assets/NebuLibsAssets/sound effects/recover.ogg",
}

function Preloader.add_asset(asset_path)
  asset_paths[#asset_paths+1] = asset_path
end

function Preloader.update(area_id)
  for _, asset_path in ipairs(asset_paths) do
    Net.provide_asset(area_id, asset_path)
  end
end

return Preloader
