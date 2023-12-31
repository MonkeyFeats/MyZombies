#include "VehicleCommon.as"
#include "RulesCore.as";
#include "Requirements_Tech.as";

//const Vec2f arm_offset = Vec2f(-27,5);
const Vec2f arm_offset = Vec2f(-27,5);
//const Vec2f sprite_offset = Vec2f(27,0);
void onInit( CBlob@ this )
{

bool hasMBomb = hasTech(this, "Bazooka ammo");
	this.set_bool("Bazooka ammo", hasMBomb);
   Vehicle_Setup( this,
                   45.0f, // move speed
                   0.19f,  // turn speed
                   Vec2f(0.0f, -5.0f), // jump out velocity
                   false  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
   if(this.get_bool("Bazooka ammo") == false)
			{
    Vehicle_SetupWeapon( this, v,
                         40, // fire delay (ticks)
                         1, // fire bullets amount
                         Vec2f(-6.0f, 2.0f), // fire position offset
                         "mat_missile", // bullet ammo config name
                         "ballista_bolt2", // bullet config name
                         "BazookaShoot", // fire sound
                         "EmptyFire" // empty fire sound
                       );
					   }
					   else{
					    Vehicle_SetupWeapon( this, v,
                         40, // fire delay (ticks)
                         2, // fire bullets amount
                         Vec2f(-6.0f, 2.0f), // fire position offset
                         "mat_missile", // bullet ammo config name
                         "ballista_bolt2", // bullet config name
                         "BazookaShoot", // fire sound
                         "EmptyFire" // empty fire sound
                       );
					   
					   }
    v.charge = 400;
	Vehicle_SetupAirship( this, v, -400.0f );
	this.set_f32("map dmg modifier", 35.0f);
	    this.addCommandID("Reload");
	this.set_s32("lastReloadTime", 0);

    CSprite@ sprite = this.getSprite();

	const string filename = CFileMatcher("/Bazooka.png").getFirst();
  

    CSpriteLayer@ arm = sprite.addSpriteLayer( "arm", filename, 30, 16 );

    if (arm !is null)
    {
        Animation@ anim = arm.addAnimation( "default", 0, false );
		anim.AddFrame(0);
        anim.AddFrame(1);
        arm.SetOffset( arm_offset );
    }


    this.getShape().SetRotationsAllowed( false );
	this.set_string("autograb blob", "mat_missile");

	//sprite.SetZ(-10.0f);
    

	this.getCurrentScript().runFlags |= Script::tick_hasattached;	
 //   this.Tag("medium weight");
	// auto-load on creation
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob( "mat_missile" );
		if (ammo !is null)	{
			if (!this.server_PutInInventory( ammo ))
				ammo.server_Die();
		}
	}
	
	
}

f32 getAimAngle( CBlob@ this, VehicleInfo@ v )
{
    f32 angle = Vehicle_getWeaponAngle(this, v);
    bool facing_left = this.isFacingLeft();
    AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");
    bool failed = true;

    if (gunner !is null && gunner.getOccupied() !is null)
    {
        gunner.offsetZ = -5.0f;
        Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if( this.isAttached() )
		{
			if (facing_left) { aim_vec.x = -aim_vec.x; }
			angle = (-(aim_vec).getAngle() + 180.0f);
		}
		else
		{
			if ( (!facing_left && aim_vec.x < 0) ||
					( facing_left && aim_vec.x > 0 ) )
			{
				if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

				angle = (-(aim_vec).getAngle() + 180.0f);
				angle = Maths::Max( -80.0f , Maths::Min( angle , 80.0f ) );
			}
			//else
			//{
			//	this.SetFacingLeft(!facing_left);
			//}
		}
    }

    return angle;
}

bool hasTech(CBlob@ this, const string &in name)
{
	CBitStream reqs, missing;
	//AddRequirement(reqs, "tech", "drop bomb ammo", "Drop Bomb Ammo");
	//AddRequirement(reqs, "tech", "MG ammo", "MG Ammo");
	AddRequirement(reqs, "tech", "Bazooka ammo", "Bazooka Ammo");
	int thisteam = this.getTeamNum();

	CPlayer@ player;
	for (int i = 0; i < getPlayersCount(); i++)
	{
		@player = getPlayer(i);
		if (player.getTeamNum() == thisteam && player.getBlob() !is null)
			break;
	}

	if (player !is null && player.getBlob() !is null)
	{
		return hasRequirements_Tech(player.getBlob().getInventory(), reqs, missing);
	}
	return false;
}

void onTick( CBlob@ this )
{


	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}

		//set the arm angle based on GUNNER mouse aim, see above ^^^^
		f32 angle = getAimAngle( this, v );
		Vehicle_SetWeaponAngle( this, angle, v );
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ arm = sprite.getSpriteLayer( "arm" );

		if (arm !is null)
		{
			bool facing_left = sprite.isFacingLeft();
			f32 rotation = angle * (facing_left? -1: 1);

			if (v.loaded_ammo > 0) {
				arm.animation.frame = 0;
			}
			else {
				arm.animation.frame = 1;
			}

			arm.ResetTransform( );
			arm.SetFacingLeft(facing_left);
			arm.SetRelativeZ( 1.0f );
			arm.SetOffset( arm_offset );
			arm.RotateBy( rotation, Vec2f(facing_left?-4.0f:4.0f,0.0f) );
		}


		Vehicle_StandardControls( this, v );
	}
	//const int team = this.getTeamNum();
	 //
	 CMap@ map = getMap();
	f32 y = this.getPosition().y;
			if(y < map.tilemapheight)
			{
				if(getGameTime() % 15 == 0)
					this.server_Hit( this, this.getPosition(), Vec2f(0,0), y < 50 ? (y < 0 ? 2.0f : 1.0f) : 0.25f, 0, true );
			}
	s32 currentTime = getGameTime();
	s32 lastReloadTime = this.get_s32("lastReloadTime");
	//const int CountMax = 3 * getTicksASecond();
	//const u8 CoutMax = 10;
		CInventory@ inv = this.getInventory();
	   if (inv.getItemsCount() == 0 && !this.hasTag("tryReload") )
					{
					
					this.set_s32("lastReloadTime", currentTime);
					this.getSprite().PlaySound("/BazookaReload2.ogg");	
					this.Tag("tryReload");
					}

	
			if(this.hasTag("tryReload"))
	{
			
			

			s32 lastReloadTime = this.get_s32("lastReloadTime");
			//print("tryReload Gametime:" + currentTime);
				//if(currentTime - (lastReloadTime + RELOAD_FREQUENCY * getTicksASecond()) > 0)
			if(currentTime > lastReloadTime + 125)
			{
	
				CBlob@ ammo = server_CreateBlob( "mat_missile" );
 
					if (ammo !is null) 
					{
 
						if (!this.server_PutInInventory( ammo )) 
						{
   
						ammo.server_Die();
     
						}
												
					
					}
					this.Untag("tryReload");
	
			}

	}

}

void onHealthChange( CBlob@ this, f32 oldHealth )
{

	f32 hp = this.getHealth();
	f32 max_hp = this.getInitialHealth();
	int damframe = hp < max_hp * 0.4f ? 2 : hp < max_hp * 0.9f ? 1 : 0;
	CSprite@ sprite = this.getSprite();
	sprite.animation.frame = damframe;
	CSpriteLayer@ cage = sprite.getSpriteLayer( "cage" );  
	if (cage !is null)	{
		cage.animation.frame = damframe;
	}
}



bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused )
{
   if (bullet !is null)
    {
		u16 charge = v.charge;
        f32 angle = Vehicle_getWeaponAngle( this, v );
        angle = angle * (this.isFacingLeft() ? -1:1);
        angle += ((XORRandom(512) - 256) / 64.0f) ;
        
        Vec2f vel = Vec2f(charge/45.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
        bullet.setVelocity( vel );
        Vec2f offset = arm_offset;
        offset.RotateBy(angle);
        bullet.setPosition(this.getPosition() + (Vec2f(20,10) * (this.isFacingLeft() ? -1 : 1) ) );
		// set much higher drag than archer arrow
		bullet.getShape().setDrag( bullet.getShape().getDrag() * 2.0f );
		
		//bullet.server_SetTimeToDie( -1 ); // override lock
		//bullet.server_SetTimeToDie( 0.69f );
		bullet.Tag("bow arrow");
    }
}


void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("fire blob"))
	{	  		
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}
		Vehicle_onFire( this, v, blob, charge );
	}
	
}
bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return Vehicle_doesCollideWithBlob_ground( this, blob );
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null) {
		TryToAttachVehicle( this, blob );
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
