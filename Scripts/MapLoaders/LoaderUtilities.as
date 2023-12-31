// LoaderUtilities.as

#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "BasePNGLoader.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	//if(map.getTile(offset).type > 255)
	//{
	//	CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
	//	if(blob !is null)
	//	{
	//		blob.server_Die();
	//	}
	//}
	if((map.getTile(offset).type > 260 && map.getTile(offset).type < 267) || (map.getTile(offset).type > 276 && map.getTile(offset).type < 292))
	{
		return false;
	}
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(map.getTile(index).type > 255)
	{
		switch(oldTileType)
		{	
			//GOLDEN BRICK
			case CMap::tile_goldenbrick: {OnGoldTileHit(map, index); return CMap::tile_goldenbrick_d0;}		
			case CMap::tile_goldenbrick_d0:
			case CMap::tile_goldenbrick_d1:
			case CMap::tile_goldenbrick_d2: {OnGoldTileHit(map, index); return oldTileType + 1;}		
			case CMap::tile_goldenbrick_d3:{OnGoldTileDestroyed(map, index); return CMap::tile_empty;}

			//STEEL BRICK
			case CMap::tile_steelbrick: {OnGoldTileHit(map, index); return CMap::tile_steelbrick_d0;}		
			case CMap::tile_steelbrick_d0:
			case CMap::tile_steelbrick_d1:
			case CMap::tile_steelbrick_d2:{OnGoldTileHit(map, index); return oldTileType + 1;}		
			case CMap::tile_steelbrick_d3: { OnGoldTileDestroyed(map, index); return CMap::tile_empty;	}		

			//BLOOD DIRT
			case CMap::tile_bloodground: { return CMap::tile_steelbrick_d0;}		
			case CMap::tile_bloodground_d0:
			case CMap::tile_bloodground_d1:
			case CMap::tile_bloodground_d2: { return oldTileType + 1; }		
			case CMap::tile_bloodground_d3: { return CMap::tile_empty; }	
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{

	switch(tile_new)
	{
		case CMap::tile_empty:
		map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
		break;
	}

	if (map.getTile(index).type > 255)
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			// golden brick
			case CMap::tile_goldenbrick:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_goldenbrick_d0:
			case CMap::tile_goldenbrick_d1:
			case CMap::tile_goldenbrick_d2:
			case CMap::tile_goldenbrick_d3:
			{
				OnGoldTileHit(map, index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}

			// steel brick
			case CMap::tile_steelbrick:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_steelbrick_d0:
			case CMap::tile_steelbrick_d1:
			case CMap::tile_steelbrick_d2:
			case CMap::tile_steelbrick_d3:
			{
				OnGoldTileHit(map, index);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}

			// blood ground
			case CMap::tile_bloodground:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				//if (getNet().isClient()) Sound::Play("build_wall2.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			}
			case CMap::tile_bloodground_d0:
			case CMap::tile_bloodground_d1:
			case CMap::tile_bloodground_d2:
			case CMap::tile_bloodground_d3:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES );
				map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
				break;
			}
		}
	}
	
	if(isDummyTile(tile_new))
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}
}

void OnGoldTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::BACKGROUND );
	
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		goldtilesparks(pos, -180+XORRandom(180), 1.0f);
	
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
	}
}

void OnGoldTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("destroy_gold.ogg", pos, 1.0f, 1.0f);
	}
}

void OnStoneTileDestroyed(CMap@ map, u32 index)
{
	if (getNet().isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
	
		Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.0f);
	}
}