#include "VehicleCommon.as";

void onInit( CSprite@ this )
 {
	 this.getCurrentScript().runFlags |= Script::tick_hasattached;
 }

void onRender( CSprite@ this )
{
	if (this is null) return; //can happen with bad reload
	
    // draw only for local player
    CBlob@ localBlob = getLocalPlayerBlob();
	CBlob@ blob = this.getBlob();

    if (localBlob is null) {
        return;
    }
	    
	VehicleInfo@ v;
	if (!blob.get( "VehicleInfo", @v )) {
		return;
	}

	AttachmentPoint@ gunner = blob.getAttachments().getAttachmentPointByName("GUNNER");
	if (gunner !is null	&& gunner.getOccupied() is localBlob)
	{
		if (!v.infinite_ammo)
			drawAmmoCount(blob, v);

		//if(blob.getName() == "ballista")
			//drawAngleCount(blob, v);
			//drawChargeBar(blob, v);	
	
			
	
	}
}

void drawAmmoCount(CBlob@ blob, VehicleInfo@ v)
{
	// draw ammo count
	Vec2f pos2d = blob.getScreenPos();
	Vec2f upperleft(pos2d.x - 18, pos2d.y + blob.getHeight()+30);
	Vec2f lowerright(pos2d.x + 18, upperleft.y + 20);

	GUI::DrawRectangle( upperleft, lowerright );

	u16 ammo = v.ammo_stocked;

	string reqsText = " "+ammo;
	GUI::DrawText( reqsText, upperleft, lowerright, color_white, true, true, false );
}

void drawChargeBar(CBlob@ blob, VehicleInfo@ v)
{
	int maxchargetime = 0;//hack TODO: add a max_charge_time variable inside of the VehicleCommon
	if(blob.getName() == "ballista")
		maxchargetime = 80;
	else if(blob.getName() == "catapult")
		maxchargetime = 90;

	u16 charge = v.charge;

	if(charge > 0)
	{
		Vec2f pos2d = blob.getScreenPos() - Vec2f(0, 60);
		Vec2f dim = Vec2f(24,8);
		const f32 y = blob.getHeight()*2.4f;

		f32 percent = charge / float(maxchargetime);

 		GUI::DrawRectangle( Vec2f(pos2d.x - dim.x-2, pos2d.y + y-2), Vec2f(pos2d.x +dim.x+2, pos2d.y + y + dim.y+2) );

 		if(percent <= 0.33f)
			GUI::DrawRectangle( Vec2f(pos2d.x - dim.x+2, pos2d.y + y+2), Vec2f(pos2d.x - dim.x + percent*2.0f*dim.x -2, pos2d.y + y + dim.y-2), SColor(0xff00FF00) );//green
		else if(percent > 0.33f && percent <= 0.66f)
			GUI::DrawRectangle( Vec2f(pos2d.x - dim.x+2, pos2d.y + y+2), Vec2f(pos2d.x - dim.x + percent*2.0f*dim.x -2, pos2d.y + y + dim.y-2), SColor(0xffFFFF00) );//yellow
		else
			GUI::DrawRectangle( Vec2f(pos2d.x - dim.x+2, pos2d.y + y+2), Vec2f(pos2d.x - dim.x + percent*2.0f*dim.x -2, pos2d.y + y + dim.y-2), SColor(0xffFF0000) );//red
	}
}

void drawAngleCount(CBlob@ blob, VehicleInfo@ v)
{
	Vec2f pos2d = blob.getScreenPos() - Vec2f( -48 , 52);
	Vec2f upperleft(pos2d.x - 18, pos2d.y + blob.getHeight()+30);
	Vec2f lowerright(pos2d.x + 18, upperleft.y + 20);

	GUI::DrawRectangle( upperleft, lowerright );

	string reqsText = " "+getAngle(blob, v.charge, v);
	GUI::DrawText( reqsText, upperleft, lowerright, color_white, true, true, false );
}

//stolen from ballista.as and slightly modified
u8 getAngle(CBlob@ this, const u8 charge, VehicleInfo@ v)
{
	const f32 high_angle = 20.0f;
	const f32 low_angle = 60.0f;

    f32 angle = 180.0f; //we'll know if this goes wrong :)
    bool facing_left = this.isFacingLeft();
    AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");

	bool not_found = true;

    if (gunner !is null && gunner.getOccupied() !is null)
    {
        Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

        if ( (!facing_left && aim_vec.x < 0) ||
                ( facing_left && aim_vec.x > 0 ) )
        {
            if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

            angle = (-(aim_vec).getAngle() + 270.0f);
            angle = Maths::Max( high_angle , Maths::Min( angle , low_angle ) );
			//printf("angle " + angle );
			not_found = false;
        }
    }
    
    if(not_found)
    {
		angle = Maths::Abs(Vehicle_getWeaponAngle(this, v)); 
		return (angle);
	}

    return Maths::Abs(Maths::Round(angle));
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge ) {}
bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}
