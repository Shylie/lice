```
┌─╖    ┌────╖ ┌───╖ ┌───╖
│ ║    └─┐╓─╜ │╓──╜ │┌──╜
│ ║      │║   │║    │└─╖ 
│ ║      │║   │║    │┌─╜ 
│ ╙──╖ ┌─┘╙─╖ │╙──╖ │└──╖
└────╜ └────╜ └───╜ └───╜
```
A löve library for drawing 3D isometric tile maps.

---
## Basic usage:
1. Require the file with `local lice = require "folder.to.lice"`.
2. Create an instance of a tilemap with `local map = lice.new(sizeX, sizeY, sizeZ, atlas, tileWidth, tileHeight)`.
	- `sizeX` — Maximum size of the map.
	- `sizeY` — Maximum size of the map.
	- `sizeZ` — Maximum size of the map.
	- `atlas` — A texture atlas¹ for drawing the map.
	- `tileWidth` — Pixel width of a single tile in the atlas.
	- `tileHeight` — Pixel height of a single tile in the atlas.
3. Set up the map data² like so: `map:setLayerID(x, y, z, id, layer?)`.
4. Draw the map in `love.draw` with `map:draw(x, y, areaX?, areaY?, areaZ?, centerX?, centerY?, centerZ?)`.

---
## Footnotes

¹ Texture atlases are expected to be a grid of `tileWidth`×`tileHeight` tiles.
A 4×4 grid of textures would have IDs as follows:
<table>
    <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
        <td>4</td>
    </tr>
    <tr>
        <td>5</td>
        <td>6</td>
        <td>7</td>
        <td>8</td>
    </tr>
    <tr>
        <td>9</td>
        <td>10</td>
        <td>11</td>
        <td>12</td>
    </tr>
    <tr>
        <td>13</td>
        <td>14</td>
        <td>15</td>
        <td>16</td>
    </tr>
</table>

\
² Map data is just an integer corresponding to an atlas ID (see footnote 1).
