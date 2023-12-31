// Keg logic
#include "Hitters.as";
#include "TeamStructureNear.as";


void onInit( CBlob@ this )
{ 
    
    this.Tag("projectile");
    this.Tag("bomberman_style");
	this.set_f32("map_bomberman_width", 2.0f);
    this.set_f32("explosive_radius", 14.0f);
    this.set_f32("explosive_damage",1.5f);
    this.set_u8("custom_hitter", Hitters::arrow);
    this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
    this.set_f32("map_damage_radius", 8.0f);
    this.set_f32("map_damage_ratio", 0.2f);
    this.set_bool("map_damage_raycast", true);
	this.set_f32("keg_time", 50.0f);  // 180.0f
    this.SetLight( true );
    this.SetLightRadius( 34.0f );
    this.SetLightColor( SColor(255, 255, 240, 171 ) );

    
    this.set_u16("_keg_carrier_id", 0xffff);


}

//sprite update

void onTick( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    
    this.animation.frame = (this.animation.getFramesCount()) * (1.0f - (blob.getHealth() / blob.getInitialHealth()));
    
    s32 timer = blob.get_s32("explosion_timer") - getGameTime();

    if (timer < 0) {
        return;
    }
    
 
    
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    if(getNet().isServer())
    {
        this.set_u16("_keg_carrier_id", attached.getNetworkID());
    }
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if(getNet().isServer() &&
        !isExplosionHitter(customData) &&
        (hitterBlob is null || hitterBlob.getTeamNum() != this.getTeamNum()) )
    {
        u16 id = this.get_u16("_keg_carrier_id");
        if(id != 0xffff)
        {
            CBlob@ carrier = getBlobByNetworkID(id);
            if(carrier !is null)
            {
                this.server_DetachFrom( carrier );
            }
        }
    }

	
	
    switch(customData)
    {
        case Hitters::sword:
        case Hitters::arrow:
            damage *= 0.25f; //quarter damage from these
            break;
        default:
            damage *= 0.5f; //half damage from everything else
    }

    return damage;
}


