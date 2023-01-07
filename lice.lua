---@class Lice
---@field sizeX integer
---@field sizeY integer
---@field sizeZ integer
---@field atlas love.Texture
---@field atlasWidth integer
---@field atlasHeight integer
---@field tileWidth integer
---@field tileHeight integer
---@field data integer[]
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
---@return table
function lice.new(sizeX, sizeY, sizeZ, atlas, tileWidth, tileHeight)
	return setmetatable({
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
end

function lice:_validCoordinate(x, y, z)
	return x >= 1 and x <= self.sizeX and y >= 1 and y <= self.sizeY and z >= 1 and z <= self.sizeZ
end

function lice:_dataIndex(x, y, z)
	return z * self.sizeX * self.sizeY + y * self.sizeX + x + 1
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
	local xxOffset = x * -(self.tileWidth / 2)
	local xyOffset = x * (self.tileHeight / 4)

	local yxOffset = y * (self.tileWidth / 2)
	local yyOffset = y * (self.tileHeight / 4)

	local zyOffset = z * -(self.tileHeight / 2)

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
						local quad = self:_atlasQuad(tile)

						love.graphics.draw(self.atlas, quad, drawX + drawOffsetX - math.floor(self.tileWidth / 2), drawY + drawOffsetY - math.floor(self.tileHeight / 2))
					end
				end
			end
		end
	end
end

---Get the tile at `(x, y, z)`, or `nil` if it doesn't exist.
---@param x integer
---@param y integer
---@param z integer
---@return integer|nil
function lice:getTile(x, y, z)
	return self:_validCoordinate(x, y, z) and self.data[self:_dataIndex(x, y, z)] or nil
end

---Set the tile type at `(x, y, z)`.
---Doesn't work out of map bounds.
---@param x any
---@param y any
---@param z any
---@param tile any
function lice:setTile(x, y, z, tile)
	if self:_validCoordinate(x, y, z) then
		self.data[self:_dataIndex(x, y, z)] = tile
	end
end

return lice