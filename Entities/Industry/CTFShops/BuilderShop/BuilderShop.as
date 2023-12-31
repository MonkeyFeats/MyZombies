// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as";
#include "WARCosts.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
AddIconToken( "$dirtdrill$", "dirtdrill.png", Vec2f(16,16), 0 );
AddIconToken( "$gaslantern$", "gaslantern.png", Vec2f(16,16), 0 );
AddIconToken( "$handsaw$", "handsaw.png", Vec2f(16,16), 0 );
AddIconToken( "$chainsaw$", "chainsaw.png", Vec2f(16,16), 0 );
AddIconToken( "$drill$", "drill.png", Vec2f(16,16), 0 );
AddIconToken( "$statue1$", "statue1.png", Vec2f(16,16), 0 );
AddIconToken( "$statue2$", "statue2.png", Vec2f(16,16), 0 );
AddIconToken( "$statue3$", "statue3.png", Vec2f(16,16), 0 );
AddIconToken( "$statue4$", "BatIcon.png", Vec2f(16,16), 0 );
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));


	{
		ShopItem@ s = addShopItem(this, "Gas Lantern", "$gaslantern$", "gaslantern", "a light", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", "holds water", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_BUCKET);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", "clears water", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SPONGE);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", "a rock", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", "bouncy", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_TRAMPOLINE);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", "cuts stuff", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_SAW);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", "clears blocks", false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", COST_STONE_DRILL);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	//{
		//ShopItem@ s = addShopItem(this, "Dirt Drill", "$dirtdrill$", "dirtdrill", "Drills longer and cools faster, but drills only dirt.", false);
		//AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		//AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 300);
	//}

	{
		ShopItem@ s = addShopItem(this, "Chainsaw", "$chainsaw$", "chainsaw", "Mobile saw for cutting wood", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "stone", 50);
	}
	// {
		// ShopItem@ s = addShopItem(this, "Praying Statue", "$statue1$", "statue1", "Praying Statue", false, true);
		// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Angel Statue", "$statue2$", "statue2", "Angel Statue", false, true);
		// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Gollum Statue", "$statue3$", "statue3", "Gollum Statue", false, true);
		// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Bat Statue", "$statue4$", "statue4", "Bat Statue", false, true);
		// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
	// }
	this.set_string("required class", "builder");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item")) {
		this.getSprite().PlaySound( "/ChaChing.ogg" );
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