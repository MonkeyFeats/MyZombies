// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
AddIconToken( "$fastrune$", "FastRune.png", Vec2f(8,8), 0 );
AddIconToken( "$fastrune2$", "FastRune2.png", Vec2f(8,8), 0 );
AddIconToken( "$fastrune3$", "FastRune3.png", Vec2f(8,8), 0 );
AddIconToken( "$regenrune$", "RegenRune.png", Vec2f(8,8), 0 );
AddIconToken( "$regenrune2$", "RegenRune2.png", Vec2f(8,8), 0 );
AddIconToken( "$regenrune3$", "RegenRune3.png", Vec2f(8,8), 0 );
AddIconToken( "$jumprune2$", "JumpRune2.png", Vec2f(8,8), 0 );
AddIconToken( "$jumprune3$", "JumpRune3.png", Vec2f(8,8), 0 );
AddIconToken( "$flyrune$", "FlyRune.png", Vec2f(8,8), 0 );

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(3, 3));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-12, 0));

	{
		ShopItem@ s = addShopItem(this, "Speed Rune Level 1", "$fastrune$", "fastrune", "+%15 movement speed, hold it to activate.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50 );
	}
	{
		ShopItem@ s = addShopItem(this, "Speed Rune Level 2", "$fastrune2$", "fastrune2", "+%30 movement speed, hold it to activate.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem(this, "Speed Rune Level 3", "$fastrune3$", "fastrune3", "+%45 movement speed, hold it to activate.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 150 );
	}
	{
		ShopItem@ s = addShopItem(this, "Regen Rune Level 1", "$regenrune$", "regenrune", "Slow Regeneration, hold it to activate.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50 );
	}
	{
		ShopItem@ s = addShopItem(this, "Regen Rune Level 2", "$regenrune2$", "regenrune2", "Medium Regeneration, hold it to activate.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100 );
	}
	{
		ShopItem@ s = addShopItem(this, "Regen Rune Level 3", "$regenrune3$", "regenrune3", "Fast Regeneration, hold it to activate.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 150 );
	}
	//{
		//ShopItem@ s = addShopItem(this, "Jump Rune", "$jumprune2$", "jumprune2", "Triple Jump!", true);
		//AddRequirement(s.requirements, "coin", "", "Coins", 100 );
	//}	
	{
		ShopItem@ s = addShopItem(this, "Flying Rune", "$flyrune$", "flyrune", "Harness the power of flying but beware it drains your life's energy!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 800 );
	}
	
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
	
		this.set_Vec2f("shop offset", Vec2f(0, 0));
	
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item")) {
		this.getSprite().PlaySound( "/ChaChing.ogg" );
	}
}
