#include "VehicleCommon.as"
#include "Hitters.as"
// Boat logic

void onInit(CBlob@ this )
{
	Vehicle_Setup( this,
                   124.0f, // move speed
                   0.19f,  // turn speed
                   Vec2f(0.0f, -5.0f), // jump out velocity
                   false  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_SetupAirship( this, v, -400.0f );
    
	//Vec2f pos_off(0,0);
	this.set_f32("map dmg modifier", 35.0f);
                           
    //this.getShape().SetOffset(Vec2f(-6,16));  
   // this.getShape().getConsts().bullet = true;
	//this.getShape().getConsts().transports = true;

	


}

void onTick( CBlob@ this )
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}

		Vehicle_StandardControls( this, v );

		
	}
	CMap@ map = getMap();
	f32 y = this.getPosition().y;
			if(y < map.tilemapheight)
			{
				if(getGameTime() % 15 == 0)
					this.server_Hit( this, this.getPosition(), Vec2f(0,0), y < 50 ? (y < 0 ? 2.0f : 1.0f) : 0.25f, 0, true );
			}
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge ) {}
bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return Vehicle_doesCollideWithBlob_boat( this, blob );
}			 

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

// SPRITE

void onInit( CSprite@ this )
{
}

void onTick( CSprite@ this )
{
	this.SetZ(-50.0f);
	CBlob@ blob = this.getBlob();
	this.animation.setFrameFromRatio(1.0f - (blob.getHealth()/blob.getInitialHealth()));		// OPT: in warboat too
}
void onDie(CBlob@ this)
{
	if(this.exists("bowid"))
	{
		CBlob@ bow = getBlobByNetworkID(this.get_u16("bowid"));
		if(bow !is null)
		{
			bow.server_Die();
		}
	}
}
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onAttach(this, v, attached, attachedPoint);
}