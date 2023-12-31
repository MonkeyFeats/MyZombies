
#include "Hitters.as"
#include "CustomBlocks.as";

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.1f && (hitterBlob !is this || customData == Hitters::crush))  //sound for anything actually painful
	{
		f32 capped_damage = Maths::Min(damage, 2.0f);

		//set this false if we whouldn't show blood effects for this hit
		bool showblood = true;

		//read customdata for hitter
		switch (customData)
		{
			case Hitters::drown:
			case Hitters::burn:
			case Hitters::fire:
				showblood = false;
				break;

			case Hitters::sword:
				Sound::Play("SwordKill", this.getPosition());
				break;

			case Hitters::stab:
				if (this.getHealth() > 0.0f && damage > 2.0f)
				{
					this.Tag("cutthroat");
				}
				break;

			default:
				if (customData != Hitters::bite)
					Sound::Play("FleshHit.ogg", this.getPosition());
				break;
		}

		worldPoint.y -= this.getRadius() * 0.5f;
	    if(!CustomEmitEffectExists("Bloodcollide"))
	    { 
	        SetupCustomEmitEffect( "Bloodcollide", "FleshHitEffects.as", "BloodTiles", 10, 0, 120);
	        //SetupCustomEmitEffect( name, scriptfile, scriptfunction, u8 hard_freq, u8 chance_freq, u16 timeout )
	    }
	     u8 emiteffect = GetCustomEmitEffectID("Bloodcollide");
		{
			if (capped_damage > 1.0f)
			{
				ParticleBloodSplat(worldPoint, true);
			}

			if (capped_damage > 0.25f)
			{
				for (f32 count = 0.0f ; count < capped_damage; count += 0.5f)
				{
					ParticleBloodSplat(worldPoint + getRandomVelocity(0, 0.75f + capped_damage * 2.0f * XORRandom(2), 360.0f), false);
				}
			}

			if (capped_damage > 0.01f)
			{
				f32 angle = (velocity).Angle();

				for (f32 count = 0.0f ; count < capped_damage + 0.6f; count += 0.1f)
				{
					Vec2f vel = getRandomVelocity(angle, 1.0f + 0.3f * capped_damage * 0.1f * XORRandom(40), 60.0f);
					vel.y -= 1.5f * capped_damage;
 
					
					CParticle@ b1     = ParticleBlood(worldPoint, vel * 1.7f, SColor(255, 126, 0, 0));

				    if(b1 !is null)
				    {
				    	//b1.diesoncollide = true;
				    	b1.effectoncollide = emiteffect;
				    	//b1.emiteffect

				    }

				    CParticle@ b2     = ParticleBlood(worldPoint, vel * -1.0f, SColor(255, 126, 0, 0));

				    if(b2 !is null)
				    {
				    	//b2.diesoncollide = true;
				    	b2.effectoncollide = emiteffect;
				    }

				}
			}
		}
	}

	return damage;
}

void BloodTiles(CParticle@ p)
{
	print("now");
	Vec2f tilepos = p.position;
	CMap@ map = getMap();
	TileType tile = map.getTile( tilepos ).type;
	Vec2f tilespace = map.getTileSpacePosition(tilepos);
	int offset = map.getTileOffsetFromTileSpace(tilespace);
	if (map.isTileGrass(tile))
	{
		map.server_SetTile(tilepos, CMap::tile_bloodgrass);

		map.RemoveTileFlag( offset, Tile::SOLID | Tile::COLLISION );
		map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES );
	}
 	if (map.isTileGroundStuff(tile))
 	{
 		getMap().server_SetTile(tilepos, CMap::tile_bloodground);				 		
		map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
		map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION );
 	}
}

