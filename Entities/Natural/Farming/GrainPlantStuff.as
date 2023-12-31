#include "MakeSeed.as";
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (this.hasTag("has grain"))
		{
			server_DropCoins(this.getPosition(), XORRandom(6) + 4);
			server_MakeSeed(this.getPosition(), "grain_plant", 300, 1, 4);
		}
	}
}

