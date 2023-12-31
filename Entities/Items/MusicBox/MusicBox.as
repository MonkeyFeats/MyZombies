// A script by TFlippy, and used by Char. thanks TFlippy!

const string[] musicNames =
{
	"Disc_WeComeTogether_Goldfish.ogg",//0
	"Disc_BadKingdom_Moderat.ogg",//1
	"Disc_ClubbedToDeath_Matrix.ogg",//2
	"Disc_KissFromARose_Seal.ogg",//3
 	"Disc_Skeleton_BlockParty.ogg",//4
	"Disc_UprockingBeats_BombfunkMCs.ogg",//5
	"Disc_UntrustUs_CryatalCastles.ogg",//6
	"Disc_ShowYourself_Mastodon.ogg",//7
	"Disc_Iron_Woodkid.ogg",//8
 	"Disc_UntilTheWorldGoesCold_Trivium.ogg",//9
	"Disc_Tarantula_Pendulum.ogg",//10
	"Disc_Gooey_GlassAnimals.ogg",//11
	"Disc_NoneShallPass_AesopRock.ogg",//12
	"Disc_LoneDigger_CaravanPalace.ogg",//13
};

const f32[] TrackLengths =
{
	//seconds
	137.35f,//0
	94.3f,//1
	125.35f,//2
	85.92f,//3
	54.55f,//4
	126.75f,//5
	133.23f,//6
	75.0f,//7
	133.40f,//8
	101.85f,//9
	147.23f,//10
	165.10f,//11
	116.25f,//12
	115.0f,//13
};

const string[] buttonNames =
{
	"Backwards",
	"Stop",
	"Play",
	"Pause",
	"Forwards",
	"Loop",
	"Shuffle",
};

void onInit(CBlob@ this)
{
	this.server_setTeamNum(XORRandom(8));

	this.set_u8("trackID", 0);
	this.set_bool("isPlaying", false);
	this.set_bool("isShuffling", false);
	this.set_bool("isLooping", false);
	
	this.addCommandID("open");

	this.addCommandID("Backwards");
	this.addCommandID("Forwards");
	this.addCommandID("Play");
	this.addCommandID("Pause");
	this.addCommandID("Stop");
	this.addCommandID("Shuffle");
	this.addCommandID("Loop");

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(7,1));	
	this.set_string("shop description", "DJ");
	this.set_u8("shop icon", 10);
	//this.set_bool("menuisopen", false);

	AddIconToken( "$Backwards$", "MusicBox.png", Vec2f(16,16), 8 );
	AddIconToken( "$Stop$", "MusicBox.png", Vec2f(16,16), 9 );
	AddIconToken( "$Play$", "MusicBox.png", Vec2f(16,16), 10 );
	AddIconToken( "$Pause$", "MusicBox.png", Vec2f(16,16), 11 );
	AddIconToken( "$Forwards$", "MusicBox.png", Vec2f(16,16), 12 );
	AddIconToken( "$Loop$", "MusicBox.png", Vec2f(16,16), 13 );
	AddIconToken( "$Shuffle$", "MusicBox.png", Vec2f(16,16), 14 );
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	f32 speed = sprite.getEmitSoundSpeed();
	u8 trackID = this.get_u8("trackID");
	f32 tracktimer = this.get_u32("tracktimer");

	if (trackID <= TrackLengths.length && speed > 0)
	{
		f32 ticksSinceTrackStart = (getGameTime()-tracktimer)/getTicksASecond();
		if (ticksSinceTrackStart >= TrackLengths[trackID])
		{
			CBitStream stream;
			this.SendCommand(this.getCommandID("Forwards"), stream);
		}
	}

	if (this.get_bool("isPlaying") && getGameTime()% 20 == 0)
	{
		MakeNoteParticle(this);
	}
}


void MakeNoteParticle(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	f32 angle = 90;
	f32 spread = 60.0f;
	int framex = 6;
	int framey = 6;

	switch (XORRandom(4)) // random frame column and row
	{
		case 0: framex =6; framey =6; 	break;
		case 1: framex =7; framey =6; 	break;
		case 2: framex =6; framey =7; 	break;
		case 3: framex =7; framey =7; 	break;

		default: break;
	}

	CParticle@ Note = 
	makeGibParticle("MusicBox.png", pos+( Vec2f( XORRandom(2)== 0 ? -8:8 , 0).RotateBy(this.getAngleDegrees())),
								 	getRandomVelocity(angle, 10.0f + XORRandom(3.0f), spread),
								 	framex, framey,
								 	Vec2f(8, 8), 1.0f, 0, "", 0);

	if (Note !is null)
	{
		Note.scale = 1.5f;
		Note.rotates = false;
		Note.timeout = 5 + XORRandom(20);
		Note.growth = -0.05f;
		Note.damping = 0.84f;
	}
}

void OpenMenu(CBlob@ this)
{
//	CGridMenu @gridmenu;
	if (musicNames.length == 0)
	{
		return;
	}
	this.ClearGridMenusExceptInventory();
	CGridMenu@ menu = CreateGridMenu(this.getScreenPos()+Vec2f(0,-32), this, Vec2f(7,1), getTranslatedString("Ogg Player"));

	if (menu !is null)
	{
		bool playing = this.get_bool("isPlaying");
		bool shuffling = this.get_bool("isShuffling");
		bool looping = this.get_bool("isLooping");
		menu.deleteAfterClick = true; //close and reopen the menu on cmd

		for (uint i = 0; i < 7; i++)
		{
			string buttonname = buttonNames[i];
			CGridButton @button = menu.AddButton("$"+buttonname+"$", buttonname, this.getCommandID(buttonname));

			if (button !is null)
			{
				button.selectOneOnClick = true;

				if (buttonname == "Play" && playing)
				{
					button.SetSelected(2);
				}
				else if (buttonname == "Pause" && !playing)
				{
					button.SetSelected(2);
				}

				if (buttonname == "Loop" && looping && !shuffling)
				{
					button.SetSelected(2);
				}
				else if (buttonname == "Shuffle" && shuffling && !looping)
				{
					button.SetSelected(2);
				}
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
    CBitStream params;
    params.write_u16( caller.getNetworkID() );
   
 //if (!this.get_bool("menuisopen"))
    {
    	CButton@ button = caller.CreateGenericButton( "", Vec2f(0, 0), this, this.getCommandID("open"), "Music Player", params );
    	button.radius = 8.0f;
		button.enableRadius = 20.0f;	
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool shufflemode = this.get_bool("isShuffling");
	bool loopmode = this.get_bool("isLooping");

	if(getNet().isClient())
	{
		if (cmd == this.getCommandID("open"))
		{
			OpenMenu(this);
			//this.set_bool("menuisopen", true);			
		}

		else if (cmd == this.getCommandID("Backwards"))
		{
			u8 trackID = this.get_u8("trackID");			
					
			this.set_bool("isPlaying", true);
			this.set_u32("tracktimer", getGameTime());
		
			CSprite@ sprite = this.getSprite();

			if (loopmode || this.get_u32("tracktimer") - getGameTime()+120 < 0 )
			{
				sprite.RewindEmitSound();
			}
			else
			{
				u8 trackID = (shufflemode == true ? XORRandom(13) : (this.get_u8("trackID")-1));
				if (trackID == 255) {trackID = 13;}

				this.set_u8("trackID", trackID);
				sprite.RewindEmitSound();
				sprite.SetEmitSound(musicNames[trackID]);
				sprite.SetEmitSoundPaused(false);
			}
			OpenMenu(this);			
		}
		else if (cmd == this.getCommandID("Stop"))
		{
			//Nobody caaan stop the music!
			OpenMenu(this);
		}

		else if (cmd == this.getCommandID("Play"))
		{
			u8 trackID = this.get_u8("trackID");			
					
			this.set_bool("isPlaying", true);
			this.set_u32("tracktimer", getGameTime());
		
			CSprite@ sprite = this.getSprite();
			//sprite.RewindEmitSound();
			sprite.SetEmitSound(musicNames[trackID]);
			sprite.SetEmitSoundPaused(false);
			sprite.SetAnimation("playing");

			OpenMenu(this);			
		}
		else if (cmd == this.getCommandID("Pause"))
		{
			u8 trackID = this.get_u8("trackID");
					
			this.set_bool("isPlaying", false);
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSoundPaused(true);
			sprite.SetAnimation("default");

			OpenMenu(this);			
		}
		else if (cmd == this.getCommandID("Loop"))
		{			
			if (loopmode == true)
			{
				this.set_bool("isLooping", false);
			}
			else
			{				
				this.set_bool("isShuffling", false);
				this.set_bool("isLooping", true);
			}
			OpenMenu(this);
		}		
		else if (cmd == this.getCommandID("Shuffle"))
		{			
			if (shufflemode == true)
			{
				this.set_bool("isShuffling", false);
			}
			else
			{
				this.set_bool("isLooping", false);
				this.set_bool("isShuffling", true);
			}
			OpenMenu(this);
		}
		else if (cmd == this.getCommandID("Forwards"))
		{		
			CSprite@ sprite = this.getSprite();
			if (loopmode)
			{
				sprite.RewindEmitSound();
			}
			else
			{
				u8 trackID = (shufflemode == true ? XORRandom(13) : (this.get_u8("trackID")+1));
				if (trackID >= musicNames.length)
				{
					trackID = 0;
				}
				
				this.set_u8("trackID", trackID);
				this.set_u32("tracktimer", getGameTime());

				sprite.SetEmitSound(musicNames[trackID]);
				sprite.SetEmitSoundPaused(false);
			}

			OpenMenu(this);	
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
}