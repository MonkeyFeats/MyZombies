// Vehicle Workshop

#include "Requirements.as";
#include "Requirements_Tech.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const s32 cost_catapult = 80;
const s32 cost_ballista = 150;
const s32 cost_ballista_ammo = 30;
const s32 cost_ballista_ammo_upgrade_gold = 60;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$vehicleshop_upgradebolts$", "BallistaBolt.png", Vec2f(32, 8), 1);
AddIconToken("$vehicleshop_upgradebomber$", "HeavyBomb.png", Vec2f(32, 16), 1);
AddIconToken("$vehicleshop_upgradebazooka$", "Bazooka.png", Vec2f(32, 16), 1);
AddIconToken("$vehicleshop_upgrademg$", "Bullet.png", Vec2f(32, 16), 1);
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 9));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + "flings stuff", false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_catapult);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + "s spawn", false, true);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_ballista);
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + "ballista ammo", false, false);
		s.crate_icon = 5;
		AddRequirement(s.requirements, "coin", "", "Coins", cost_ballista_ammo);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Bolt Upgrade", "$vehicleshop_upgradebolts$", "upgradebolts", "For Ballista\nTurns its piercing bolts into a shaped explosive charge.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", cost_ballista_ammo_upgrade_gold);
		AddRequirement(s.requirements, "not tech", "bomb ammo", "Bomb Bolt", 1);
	}
	
	{
		ShopItem@ s = addShopItem(this, "MG Upgrade", "$vehicleshop_upgrademg$", "upgradeMG", "-50% reloading time", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 2000);
		AddRequirement(s.requirements, "not tech", "MG ammo", "Machine Gun Upgrade", 1);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Bazooka Upgrade", "$vehicleshop_upgradebazooka$", "upgradeBazooka", "For Bazooka\nImplementing a 2-stage firing system which enables the bazooka to fire 2 missiles simultaniously.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 3000);
		AddRequirement(s.requirements, "not tech", "Bazooka ammo", "Bazooka Upgrade", 1);
	}
	
	{
		ShopItem@ s = addShopItem(this, "Bomber Upgrade", "$vehicleshop_upgradebomber$", "upgradeBomber", "For Bomber\n-50% reloading time", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 4000);
		AddRequirement(s.requirements, "not tech", "drop bomb ammo", "Bomber Upgrade", 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		bool isServer = (getNet().isServer());
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		
		CRules@ rules = getRules();
		
		int team = this.getTeamNum();

		string myTeamName = (team < rules.getTeamsCount() ? rules.getTeam(team).getName() + " have" : "");

		string name = params.read_string();
		{
			if (name == "upgradebolts")
			{
				GiveFakeTech(getRules(), "bomb ammo", this.getTeamNum());
			}
			if (name == "upgradeMG")
			{
				GiveFakeTech(getRules(), "MG ammo", this.getTeamNum());
				Sound::Play("/ResearchComplete.ogg");
				client_AddToChat(myTeamName + " the Machine Gun Upgrade");
			
			//	client_AddToChat( myTeamName + "Have the Machine Gun Upgrade");
			}
			if (name == "upgradeBazooka")
			{
				GiveFakeTech(getRules(), "Bazooka ammo", this.getTeamNum());
				Sound::Play("/ResearchComplete.ogg");
				client_AddToChat(myTeamName + " the Bazooka Upgrade" );
				//client_AddToChat( myTeamName + "Have the Bazooka Upgrade");
			}
			if (name == "upgradeBomber")
			{
				GiveFakeTech(getRules(), "drop bomb ammo", this.getTeamNum());
				Sound::Play("/ResearchComplete.ogg");
				client_AddToChat(myTeamName + " the Bomber Gun Upgrade " );
				//client_AddToChat( myTeamName + "Have the Bomber Upgrade");
			}
		}
	}
}