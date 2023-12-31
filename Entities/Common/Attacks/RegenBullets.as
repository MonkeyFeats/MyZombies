#define SERVER_ONLY

// regen hp back to 

void onInit( CBlob@ this )
{
	
	this.getCurrentScript().tickFrequency = 90;	
	this.addCommandID("Reload");
}

void onTick( CBlob@ this )
{
//bool CanReload = !CanReload;
CanReload(this, true);
		
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
if(this.hasTag(Reload))
{}
CButton@ button = this.CreateGenericButton("$mat_bullets$",  Vec2f(0, 0), this, this.getCommandID("Reload"), "Reload", params);
	

}


void CanReload (CBlob@ this, bool on)
{
if (!on)
	{
	this.Tag("No Reload");
	this.Untag("Reload");
	}
	else
	{
	this.Tag("Reload");
	this.Untag("No Reload")
	}
}
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
if (cmd == this.getCommandID("Reload"))
	{
		CanReload(this, false);
		CBlob@ ammo = server_CreateBlob( "mat_bullets" );
		if (ammo !is null)	{
			if (!this.server_PutInInventory( ammo ))
				ammo.server_Die();
	
	
							}
	}

}