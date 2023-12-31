#include "RunnerMovement.as"
 int ju4 = 0;
void onTick( CBlob@ blob )
{
 //CBlob@ blob = this.getBlob();
 RunnerMoveVars@ moveVars;
    if (!blob.get( "moveVars", @moveVars )) {
        return;
    }
	const bool up		= blob.isKeyPressed(key_up);
		const bool onground = blob.isOnGround() || blob.isOnLadder();
	if(ju4 == 0)
				{
					if (moveVars.jumpCount > 7 && blob.isKeyPressed(key_up))
					{
					blob.AddForce(Vec2f(0,-220));
					 ju4 = 1;
					}
						
				}
				if (onground)
						{
						ju4 = 0;
						}
	
}
 






