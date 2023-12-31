//trap block script for devious builders

#include "Hitters.as"
#include "MapFlags.as"

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed( false );
   // this.getSprite().getConsts().accurateLighting = true;
    this.set_bool("open", false);    
    this.Tag("place norotate");
    this.addCommandID("activate");
    //block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");
	
	this.set_TileType("background tile", CMap::tile_castle_back);

	MakeDamageFrame( this );
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

//TODO: fix flags sync and hitting
/*void onDie( CBlob@ this )
{
	SetSolidFlag(this, false);
}*/

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	if (!isOpen(this))
	{
		MakeDamageFrame( this );
	}
}

void MakeDamageFrame( CBlob@ this )
{
	f32 hp = this.getHealth();
	f32 full_hp = this.getInitialHealth();
	int frame = (hp > full_hp * 0.9f) ? 0 : ( (hp > full_hp * 0.4f) ? 1 : 2);
	this.getSprite().animation.frame = frame;
}

bool isOpen( CBlob@ this )
{
	return !this.getShape().getConsts().collidable;
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton( 29, Vec2f(0.0,0.0), this, this.getCommandID("activate"), "Turn on/off", params );
}
void setOpen( CBlob@ this, bool open )
{
	CSprite@ sprite = this.getSprite();

	if (open)
	{
		sprite.SetZ(-100.0f);
		sprite.animation.frame = 3;
		this.getShape().getConsts().collidable = false;

		// drop boulder on trap blocks
		const uint count = this.getTouchingCount();
		for (uint step = 0; step < count; ++step)
		{
			CBlob@ blob = this.getTouchingByIndex(step);
			blob.getShape().checkCollisionsAgain= true;
		}
	}
	else
	{
		sprite.SetZ(100.0f);
		MakeDamageFrame(this);
		this.getShape().getConsts().collidable = true;
	}

	//TODO: fix flags sync and hitting
	//SetSolidFlag(this, !open);

	if (this.getTouchingCount() <= 1 && openRecursion < 5) {
		SetBlockAbove( this, open );
		openRecursion++;
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.getTeamNum() == this.getTeamNum())
	{
		return !isOpen( this );
	}
	else
	{
		return !opensThis(this,blob) && !isOpen(this);
	}
}

bool opensThis(CBlob@ this, CBlob@ blob)
{
	return (blob.getTeamNum() != this.getTeamNum() &&
			!isOpen(this) && blob.isCollidable() &&
			( blob.hasTag("player") || blob.hasTag("vehicle")));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
    if (blob !is null)
    {
        if ( opensThis(this,blob) )
        {
			openRecursion = 0;
            setOpen(this, true);			
        }
    }
}

void onEndCollision( CBlob@ this, CBlob@ blob )
{
	if (blob !is null)
	{
		bool touching = false;
		const uint count = this.getTouchingCount();
		for (uint step = 0; step < count; ++step)
		{
			CBlob@ blob = this.getTouchingByIndex(step);
			if (blob.isCollidable()) {
				touching = true;
				break;
			}
		}

		if (!touching)
		{
			setOpen(this, false);
		}
	}
}


bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false;
}

void SetBlockAbove( CBlob@ this, const bool open )
{
	//block above
	CBlob@ blobAbove = getMap().getBlobAtPosition( this.getPosition() + Vec2f(0.0f, -8.0f) ) ;
	if (blobAbove !is null && blobAbove.getName() == "trap_block")
	{
		setOpen(blobAbove, open);
	}
}
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("activate"))
	{
		openRecursion = 0;
            setOpen(this, true);
	}
	

}