---@class LiceTile
---@field layers integer[]
---@field user table

---@class Lice
---@field sizeX integer
---@field sizeY integer
---@field sizeZ integer
---@field atlas love.Texture
---@field atlasWidth integer
---@field atlasHeight integer
---@field tileWidth integer
---@field tileHeight integer
---@field data LiceTile[]
---@field quads love.Quad[]
local lice = { }
lice.__index = lice

---Create a new isometric map
---@param sizeX integer X size of the map in tiles
---@param sizeY integer Y size of the map in tiles
---@param sizeZ integer Z size of the map in tiles
---@param atlas love.Texture Texture atlas to use when drawing
---@param tileWidth integer Width of a tile in the texture atlas
---@param tileHeight integer Height of a tile in the texture atlas
---@return Lice
function lice.new(sizeX, sizeY, sizeZ, atlas, tileWidth, tileHeight)
	local map = setmetatable({
		sizeX = sizeX,
		sizeY = sizeY,
		sizeZ = sizeZ,
		atlas = atlas,
		atlasWidth = math.floor(atlas:getWidth() / tileWidth),
		atlasHeight = math.floor(atlas:getHeight() / tileHeight),
		tileWidth = tileWidth,
		tileHeight = tileHeight,
		data = { },
		quads = { }
	}, lice)

	for i = 1, sizeX * sizeY * sizeZ do
		map.data[i] = { layers = { } }
	end

	return map
end

function lice:_validCoordinate(x, y, z)
	return x >= 1 and x <= self.sizeX and y >= 1 and y <= self.sizeY and z >= 1 and z <= self.sizeZ
end

function lice:_dataIndex(x, y, z)
	return (z - 1) * self.sizeX * self.sizeY + (y - 1) * self.sizeX + x
end

function lice:_atlasQuad(id)
	-- adjust for 1-based indexing in lua
	id = id - 1

	if not self.quads[id] then
		local x = self.tileWidth * math.floor(id % self.atlasWidth)
		local y = self.tileHeight * math.floor(id / self.atlasWidth)

		self.quads[id] = love.graphics.newQuad(
			x, y,
			self.tileWidth, self.tileHeight,
			self.tileWidth * self.atlasWidth, self.tileHeight * self.atlasHeight
		)
	end

	return self.quads[id]
end

---@param x integer
---@param y integer
---@param z integer
---@return integer X draw coordinate offset
---@return integer Y draw coordinate offset
function lice:_drawCoordinates(x, y, z)
	local xxOffset = x * -math.floor(self.tileWidth / 2)
	local xyOffset = x * math.floor(self.tileHeight / 4)

	local yxOffset = y * math.floor(self.tileWidth / 2)
	local yyOffset = y * math.floor(self.tileHeight / 4)

	local zyOffset = z * -math.floor(self.tileHeight / 2)

	return xxOffset + yxOffset, xyOffset + yyOffset + zyOffset
end

---Draw the isometric tilemap at `(drawX, drawY)`.
---@param drawX integer X coordinate to draw the center at
---@param drawY integer Y coordinate to draw the center at
---@param areaX? integer Number of tiles to draw on the x axis
---@param areaY? integer Number of tiles to draw on the y axis
---@param areaZ? integer Number of tiles to draw on the z axis
---@param centerX? integer X coordinate of the tile drawn in the middle
---@param centerY? integer Y coordinate of the tile drawn in the middle
---@param centerZ? integer Z coordinate of the tile drawn in the middle
function lice:draw(drawX, drawY, areaX, areaY, areaZ, centerX, centerY, centerZ)
	areaX = areaX or self.sizeX
	areaY = areaY or self.sizeY
	areaZ = areaZ or self.sizeZ
	centerX = centerX or math.floor(self.sizeX / 2)
	centerY = centerY or math.floor(self.sizeY / 2)
	centerZ = centerZ or math.floor(self.sizeZ / 2)

	local startX = centerX - math.floor(areaX / 2)
	local endX = startX + areaX - 1

	local startY = centerY - math.floor(areaY / 2)
	local endY = startY + areaY - 1

	local startZ = centerZ - math.floor(areaZ / 2)
	local endZ = startZ + areaZ - 1

	for z = startZ, endZ do
		for y = startY, endY do
			for x = startX, endX do
				if self:_validCoordinate(x, y, z) then
					local tile = self.data[self:_dataIndex(x, y, z)]
					if tile then
						local drawOffsetX, drawOffsetY = self:_drawCoordinates(x - centerX, y - centerY, z - centerZ)
						for i, layer in ipairs(tile.layers) do
							local quad = self:_atlasQuad(layer)
							love.graphics.draw(self.atlas, quad, drawX + drawOffsetX - math.floor(self.tileWidth / 2), drawY + drawOffsetY - math.floor(self.tileHeight / 2))
						end
					end
				end
			end
		end
	end
end

function lice:getSizeX()
	return self.sizeX
end

function lice:getSizeY()
	return self.sizeY
end

function lice:getSizeZ()
	return self.sizeZ
end

---Convert `(x, y)` coordinates to tilemap coordinates (excluding Z height).
---Assumes the map is centered at `(0, 0, 0)`.
---@param x number
---@param y number
---@return integer x Tilemap x coordinate
---@return integer y Tilemap y coordinate
function lice:toTilemap(x, y)
	local scaledX = x / self.tileWidth
	local scaledY = 2 * y / self.tileHeight

	return math.floor(scaledY - scaledX), math.floor(scaledY + scaledX)
end

---Get the number of draw layers at `(x, y, z)`, or `0` if the tile does not exist.
---Returns `0` out of map bounds.
---@param x any
---@param y any
---@param z any
---@return integer
function lice:getLayerCount(x, y, z)
	return self:_validCoordinate(x, y, z) and #self.data[self:_dataIndex(x, y, z)].layers or 0
end

---Get the texture ID at `(x, y, z, layer)`, or `nil` if it doesn't exist.
---Returns `nil` out of map bounds.
---@param x integer
---@param y integer
---@param z integer
---@param layer? integer
---@return integer|nil
function lice:getLayerID(x, y, z, layer)
	layer = layer or 1
	return self:_validCoordinate(x, y, z) and self.data[self:_dataIndex(x, y, z)].layers[layer] or nil
end

---Set the texture ID at `(x, y, z, layer)`.
---Doesn't work out of map bounds.
---@param x integer
---@param y integer
---@param z integer
---@param id integer|nil
---@param layer? integer
function lice:setLayerID(x, y, z, id, layer)
	layer = layer or 1
	if self:_validCoordinate(x, y, z) then
		self.data[self:_dataIndex(x, y, z)].layers[layer] = id
	end
end

---Get the tile user data at `(x, y, z)`, or `nil` if there is no user data.
---Returns `nil` out of map bounds.
---@param x integer
---@param y integer
---@param z integer
---@return table|nil
function lice:getTileData(x, y, z)
	return self:_validCoordinate(x, y, z) and self.data[self:_dataIndex(x, y, z)].user or nil
end

---Set the tile user data at `(x, y, z)`, or `nil` if it doesn't exist.
---Returns `nil` out of map bounds.
---@param x integer
---@param y integer
---@param z integer
---@param data table
function lice:setTileData(x, y, z, data)
	local index = self:_dataIndex(x, y, z)
	if self:_validCoordinate(x, y, z) and self.data[index] then
		self.data[self:_dataIndex(x, y, z)].user = data
	end
end

return lice