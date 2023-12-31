//spawning a generic fire particle

void makeFireParticle(Vec2f pos, int smokeRandom = 1)
{
	string texture;

	switch (0)
	{
		case 0: texture = "Entities/Special/ZombieTown/TownCenterFire.png"; break;

	}

	ParticleAnimated(texture, pos, Vec2f(0, 0), 0.0f, 1.0f, 5, -0.4, true);
}

void makeSmokeParticle(Vec2f pos, f32 gravity = -0.04)
{
	string texture;

	switch (XORRandom(2))
	{
		case 0: texture = "Entities/Effects/Sprites/MediumSteam.png"; break;

		case 1: texture = "Entities/Effects/Sprites/MediumSteam.png"; break;
	}

	ParticleAnimated(texture, pos+Vec2f(-6+XORRandom(12),-11), Vec2f(0, 0), 0.0f, 1.0f, 3, gravity, false);
}