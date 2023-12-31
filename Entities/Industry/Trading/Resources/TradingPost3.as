// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";



void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(8, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-12, 0));

	{
		ShopItem@ s = addShopItem(this, "Wood", "$mat_wood$", "mat_wood", "Receive 250 wood for 50 gold", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50 );
	}
	{
		ShopItem@ s = addShopItem(this, "Wood for coins", "$mat_wood$", "mat_wood", "Receive 250 wood for 2 coin sacks", true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Coin Sacks", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Stone", "$mat_stone$", "mat_stone", "Receive 250 stone for 125 gold", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 125 );
	}
	{
		ShopItem@ s = addShopItem(this, "Stone with Coins", "$mat_stone$", "mat_stone", "Receive 250 stone for 125 coins", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 125 );
	}
	{
		ShopItem@ s = addShopItem(this, "Stone for coins", "$mat_stone$", "mat_stone", "Receive 250 stone for 6 coin sacks", true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Coin Sacks", 6);
	}
	{
		ShopItem@ s = addShopItem(this, "Gold", "$mat_gold$", "mat_gold", "Receive 250 gold for 2000 wood", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 2000 );
	}
	{
		ShopItem@ s = addShopItem(this, "Gold with coins", "$mat_gold$", "mat_gold", "Receive 250 gold for 250 coins", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 250 );
	}
	{
		ShopItem@ s = addShopItem(this, "Gold for coins", "$mat_gold$", "mat_gold", "Receive 250 gold for 10 coin sacks", true);
		AddRequirement(s.requirements, "blob", "mat_sack", "Coin Sacks", 10);
	}


}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item")) {
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null) {
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null) {
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}