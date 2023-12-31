//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"


int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
    this.getSprite().getConsts().accurateLighting = true;
   
   //this.set_TileType("background tile", CMap::tile_castle_back);
    
    //block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}



bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

