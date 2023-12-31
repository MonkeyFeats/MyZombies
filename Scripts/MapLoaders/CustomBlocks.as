#include "LoaderUtilities.as";

namespace CMap
{
	enum CustomTiles
	{
		tile_goldenbrick 	= 400,
		tile_goldenbrick_d0	= 401,
		tile_goldenbrick_d1	= 402,
		tile_goldenbrick_d2	= 403,
		tile_goldenbrick_d3	= 404,

		tile_steelbrick    	= 416,
		tile_steelbrick_d0 	= 417,
		tile_steelbrick_d1 	= 418,
		tile_steelbrick_d2 	= 419,
		tile_steelbrick_d3 	= 420,

		tile_bloodground 	= 432,
		tile_bloodground_d0	= 433,
		tile_bloodground_d1	= 434,
		tile_bloodground_d2	= 435,
		tile_bloodground_d3	= 436,

		tile_bloodgrass 	= 440,
		tile_bloodgrass_d0	= 441,
		tile_bloodgrass_d1	= 452,
		tile_bloodgrass_d2	= 453,
		tile_bloodgrass_d3	= 454,
	};
};

const SColor color_goldenbrick(255, 254, 160, 30);
const SColor color_steelbrick(255, 196, 207, 161);
const SColor color_bloodground(255, 183, 51, 51);
const SColor color_bloodgrass(255, 100, 120, 20);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	if (pixel == color_goldenbrick)
	{
		map.SetTile(offset, CMap::tile_goldenbrick );
		map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
	}

	if (pixel == color_steelbrick)
	{
		map.SetTile(offset, CMap::tile_steelbrick );
		map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
	}

	if (pixel == color_bloodground)
	{
		map.SetTile(offset, CMap::tile_bloodground );
		map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
	}

	if (pixel == color_bloodgrass)
	{
		map.SetTile(offset, CMap::tile_bloodgrass );
		map.RemoveTileFlag( offset, Tile::SOLID | Tile::COLLISION );
		map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES );
	}
}