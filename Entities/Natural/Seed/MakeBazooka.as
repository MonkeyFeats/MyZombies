
// Making seeds - pass a blob name and grow time and it will set up and return the seed
// only functions on server - make sure to check for null.

// modify seed.as to make custom seed appearances

#include "ProductionCommon.as"

CBlob@ server_MakeSeed( Vec2f atpos, string blobname, u16 growtime, u8 spriteIndex, u8 created_blob_radius )
{
    if (!getNet().isServer()) { return null; }

    CBlob@ seed = server_CreateBlobNoInit( "seed" );

    if (seed !is null)
    {
        seed.setPosition( atpos );
        seed.set_string("seed_grow_blobname", blobname);
        seed.set_u16("seed_grow_time", growtime);
        seed.set_u8("sprite index", spriteIndex);
        seed.set_u8("created_blob_radius", created_blob_radius);
		seed.Init();
    }

    return seed;
}

CBlob@ server_MakeSeed( Vec2f atpos, string blobname, u16 growtime, u8 spriteIndex )
{
    return server_MakeSeed(atpos, blobname, growtime, spriteIndex, 8);
}

CBlob@ server_MakeSeed( Vec2f atpos, string blobname, u16 growtime )
{
    return server_MakeSeed(atpos, blobname, growtime, 0);
}

CBlob@ server_MakeSeed( Vec2f atpos, string blobname )
{
    if (blobname == "bazooka") {
        return server_MakeSeed( atpos, blobname, 600, 2, 8 );
    }
    

    return server_MakeSeed( atpos, blobname, 100, 0, 8 );
}


ShopItem@ addSeedItem( CBlob@ this, const string &in seedName,
	const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	const string newIcon = "$" + seedName + "$";
	ShopItem@ item = addProductionItem( this, seedName, newIcon, "bazooka", description, timeToMakeSecs, false, quantityLimit, requirements );
	return item;
}
