// Materials
#include "Help.as";
#include "Requirements_Tech.as";
// use this.Tag("do not set materials") to prevent the amount changing.



void onInit( CBlob@ this )
{

	/* bool hasHBomb = hasTech(this, "drop bomb ammo");
	this.set_bool("drop bomb ammo", hasHBomb);
	bool hasMGBomb = hasTech(this, "MG ammo");
	this.set_bool("MG ammo", hasMGBomb);
	bool hasBBomb = hasTech(this, "Bazooka ammo");
	this.set_bool("Bazooka ammo", hasBBomb); */
    int max = 250; // default
    string name = this.getName();
    bool set = false;

	this.Tag("material");

    if (name == "mat_arrows")
    {
        max = 60;
        set = true;
    }
    else if (name == "mat_firearrows") {
        max = 2;
        set = true;		
    }
	else if (name == "mat_waterarrows") {
		max = 2;
		set = true;	
	}
	else if (name == "mat_bombarrows") {
		max = 1;
		set = true;	
	}
	else if (name == "mat_waterbombs") {
		max = 1;
		set = true;	
	}
		else if (name == "mat_bullets")
	{			
	max = 30;
	set = true;
	}

    else if (name == "mat_bombs") {
        max = 1;
		if (getNet().isServer()) // show only on localhost
		{
			SetHelp( this, "help activate", "knight", "$mat_bombs$Light    $KEY_SPACE$", "$mat_bombs$Only KNIGHT can light bombs", 3 ); 
		}
    }
    else if (name == "mat_bolts")
    {
        max = 12;
        set = true;
		SetHelp( this, "help use carried", "", "$mat_bolts$Put in $ballista$    $KEY_E$", "", 3 ); 
		SetHelp( this, "help pickup", "", "$mat_bolts$Pickup    $KEY_C$", "", 3 ); 
    }
    else if (this.getQuantity() == 1) { // hack: fix me!
        set = true;
    }

	if (name == "mat_wood")
	{			
	}
	else if (name == "mat_stone")
	{			
	}
		else if (name == "mat_sack")
	{			
	max = 1;
	set = true;
	}
		else if (name == "mat_heavybomb")
	{			
	max = 1;
	set = true;
	}

		else if (name == "mat_bullets2")
	{			
	max = 120;
	set = true;
	}
   	else if (name == "mat_missile")
	{			
	max = 2;
	set = true;
	}
	
    if (getNet().isServer() && set && !this.hasTag("do not set materials"))
    {
        this.server_SetQuantity( max );
    }

    this.maxQuantity = max;

	this.getShape().getVars().waterDragScale = 20.0f;

    // force frame update
    onQuantityChange( this, -1 );
}

void onQuantityChange( CBlob@ this, int oldQuantity )
{
    UpdateFrame( this.getSprite() );

    if (getNet().isServer())
    {
        int quantity = this.getQuantity();

        // safety, we don't want 0 mats
        if (quantity == 0) {
            this.server_Die();
        }
    }
}

void UpdateFrame( CSprite@ this )
{
    // set the frame according to the material quantity
    Animation@ anim = this.getAnimation("default");

    if (anim !is null)
    {
        u16 max = this.getBlob().maxQuantity;
        int frames = anim.getFramesCount();
        int quantity = this.getBlob().getQuantity();
        f32 div = float(max/4);
        int frame = div < 0.01f ? 0 : Maths::Min( frames-1, int(Maths::Floor( float(quantity) / div )));
        anim.SetFrameIndex( frame );
        CBlob@ blob = this.getBlob();
        blob.SetInventoryIcon( blob.getSprite().getConsts().filename, anim.getFrame(frame), Vec2f(blob.getSprite().getConsts().frameWidth, blob.getSprite().getConsts().frameHeight) );
    }
}

