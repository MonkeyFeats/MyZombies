// Barracks

#include "ProductionCommon.as";
#include "WARCosts.as";

#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";
const string req_class = "required class";
const string req_class2 = "required class2";

const int sacks = 10;

void onInit( CBlob@ this )
{
	InitClasses( this );
	InitRespawnCommand( this );
	this.set_TileType("background tile", CMap::tile_castle_back);					
	this.Tag("change class store inventory");		
}

 
// leave a pile of stone	after death
void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob( "mat_stone", this.getTeamNum(), this.getPosition() );
		if (blob !is null)
		{
			blob.server_SetQuantity( COST_STONE_BARRACKS/2 );
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	AddIconToken( "$spearman_class_icon$", "GUI/MenuItems.png", Vec2f(32,32), 15 );
	AddIconToken( "$inquisitor_class_icon$", "GUI/MenuItems.png", Vec2f(32,32), 17 );
	
	if(!this.exists(req_class) || !this.exists(req_class2))
		return;
	
	string cfg = this.get_string(req_class);
	string cfg2 = this.get_string(req_class2);
	
	const u16 sacksCount = caller.getBlobCount("mat_HundredCoins");


    if (canChangeClass(this,caller) && caller.getName() != cfg && sacksCount >= sacks ) {
        CBitStream params;
        write_classchange(params, caller.getNetworkID(), cfg);
        caller.CreateGenericButton( "$spearman_class_icon$", Vec2f(-12,0), this, SpawnCmd::changeClass, "Attack from distance.", params );
    }
    else if (canChangeClass(this,caller) && caller.getName() != cfg) {
        CButton@ button = caller.CreateGenericButton( "$spearman_class_icon$", Vec2f(-12,0), this, 0, "You need more sacks with coins." );
		if (button !is null) button.SetEnabled( false );
    }
	
	
	
	if (canChangeClass(this,caller) && caller.getName() != cfg2 && sacksCount >= sacks) {
        CBitStream params;
        write_classchange(params, caller.getNetworkID(), cfg2);
        caller.CreateGenericButton( "$inquisitor_class_icon$", Vec2f(12,0), this, SpawnCmd::changeClass, "My new invention: The Musket!", params );
    }
    else if (canChangeClass(this,caller) && caller.getName() != cfg2) {
        CButton@ button = caller.CreateGenericButton( "$inquisitor_class_icon$", Vec2f(12,0), this, 0, "You need more sacks with coins." );
		if (button !is null) button.SetEnabled( false );
    }
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	{
		onRespawnCommand( this, cmd, params );
	}
}

//sprite - bed?
void onInit(CSprite@ this)
{
	this.SetZ(-50); //background
	
	CBlob@ blob = this.getBlob();
	/*CSpriteLayer@ front = this.addSpriteLayer( "front layer", this.getFilename() , this.getFrameWidth(), this.getFrameHeight(), blob.getTeamNum(), blob.getSkinNum() );

    if (front !is null)
    {
        Animation@ anim = front.addAnimation( "default", 0, false );
        anim.AddFrame(0);
        anim.AddFrame(1);
        anim.AddFrame(2);
        front.SetRelativeZ( 1000 );
    }*/
}
