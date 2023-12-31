//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"



void onInit(CBlob@ this)
{

   // this.getSprite().getConsts().accurateLighting = true;
   
   //this.set_TileType("background tile", CMap::tile_castle_back);
    
    //block knight sword

	this.Tag("veryheavy weight");
	//this.getSprite().SetZ(-50.0f);
	this.getSprite().SetRelativeZ(-10.0f);

}



bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return true;
}

