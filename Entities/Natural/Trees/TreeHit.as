#include "Hitters.as";
#include "TreeCommon.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{

	if (damage > 0.05f) //sound for all damage
	{
		if (this.get_f32("tree_fall_angle") == 0)
		{
			this.getSprite().PlayRandomSound("TreeChop");
			makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle()+180, 2.0f + damage, 45.0f) + Vec2f(0.0f, -2.0f),
			                0, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);

			for (int i = 0; i < 1+XORRandom(10); i++)
			{
				Vec2f TreePos = worldPoint+Vec2f(-12.0f+XORRandom(24),-48.0f+XORRandom(32));

				ParticleBlood(TreePos, getRandomVelocity((this.getPosition() - TreePos).getAngle(), -(1.8f + damage), 135), SColor(255,51,100+XORRandom(80),13));
			}
		}		
	}

	if (customData == Hitters::sword)
	{
		damage *= 0.5f;
	}

	return damage;
}

