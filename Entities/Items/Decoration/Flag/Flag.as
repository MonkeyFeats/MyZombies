// Flag logic

#include "CTF_FlagCommon.as"
#include "CTF_Structs.as"


void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 5;

	

}



//sprite

void onInit(CSprite@ this)
{
	this.SetZ(-10.0f);
	CSpriteLayer@ flag = this.addSpriteLayer("flag_layer", "/Flag.png", 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (flag !is null)
	{
		flag.SetOffset(Vec2f(15, -11));
		flag.SetRelativeZ(1.0f);
		Animation@ anim = flag.addAnimation("default", XORRandom(3) + 3, true);
		anim.AddFrame(0);
		anim.AddFrame(2);
		anim.AddFrame(4);
		anim.AddFrame(6);
	}

	
		this.getBlob().SetFacingLeft(true);
	
}

// alert and capture progress bar






