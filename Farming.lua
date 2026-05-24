local terrain = workspace:FindFirstChildOfClass("Terrain")
local region = terrain.MaxExtents
terrain:FillBlock(
    CFrame.new(region.Min:Lerp(region.Max, 0.5)),
    region.Max - region.Min,
    Enum.Material.Air
)
