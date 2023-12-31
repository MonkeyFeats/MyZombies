// scroll script that makes enemies insta gib within some radius

#include "Hitters.as";
void onInit( CBlob@ this )
{
	this.addCommandID( "heal" );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton( 11, Vec2f_zero, this, this.getCommandID("heal"), "Use this to heal all nearby players.", params );
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("heal"))
	{

		ParticleZombieLightning( this.getPosition() );

		CBlob@ caller = getBlobByNetworkID( params.read_u16() );
		if (caller !is null)
		{
			const int team = caller.getTeamNum();
			CBlob@[] blobsInRadius;	   
			if (this.getMap().getBlobsInRadius( this.getPosition(), 500.0f, @blobsInRadius )) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob @b = blobsInRadius[i];
					if ((b.getHealth() < b.getInitialHealth()) && b.getTeamNum() == team && b.hasTag("flesh") )
					{
					CBlob@ food = server_CreateBlob("food", -1, b.getPosition());
					}
				}
			}
		}
	this.server_Die();
	Sound::Play( "SuddenGib.ogg" );
	}
}

