
//Zombies gamemode logic script
//Modded by Eanmig
#define SERVER_ONLY
//#include "TDM_Structs.as";
#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "zombies_Technology.as";  
//#include "ZombiePortal.as"


//simple config function - edit the variables below to change the basics

void Config(ZombiesCore@ this)
{

    string configstr = "/zombies_vars.cfg";
	if (getRules().exists("Zombiesconfig")) {
	   configstr = getRules().get_string("Zombiesconfig");
	}
	ConfigFile cfg = ConfigFile( configstr );
	
	//how long for the game to play out?
    s32 gameDurationMinutes = cfg.read_s32("game_time",-1);
    if (gameDurationMinutes <= 0)
    {
		this.gameDuration = 0;
		getRules().set_bool("no timer", true);
	}
    else
    {
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}
	
    bool destroy_dirt = cfg.read_bool("destroy_dirt",true); // for explosions
	getRules().set_bool("destroy_dirt", destroy_dirt);
	bool gold_structures = cfg.read_bool("gold_structures",false);
	bool scrolls_spawn = cfg.read_bool("scrolls_spawn",false);
	bool techstuff_spawn = cfg.read_bool("techstuff_spawn",false);
	warn("GS SERVER: "+ gold_structures);
	getRules().set_bool("gold_structures", gold_structures);
	
	s32 max_zombies = cfg.read_s32("game_time",125);
	if (max_zombies<100) max_zombies=100;
	getRules().set_s32("max_zombies", max_zombies);
	getRules().set_bool("scrolls_spawn", scrolls_spawn);
	getRules().set_bool("techstuff_spawn", techstuff_spawn);

    //spawn after death time 
    this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 30));
	
}

//Zombies spawn system

const s32 spawnspam_limit_time = 10;

shared class ZombiesSpawns : RespawnSystem
{
    ZombiesCore@ Zombies_core;

    bool force;
    s32 limit;
	
	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Zombies_core = cast<ZombiesCore@>(core);
		
		limit = spawnspam_limit_time;
		getRules().set_bool("everyones_dead",false);
	}

    void Update()
    {
		
		int everyone_dead=0;
		int total_count=Zombies_core.players.length;
        for (uint team_num = 0; team_num < Zombies_core.teams.length; ++team_num )
        {
            CTFTeamInfo@ team = cast<CTFTeamInfo@>( Zombies_core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info, i);
				if ( info !is null )
				{
					if (info.can_spawn_time>0) everyone_dead++;
					//total_count++;
				}
                DoSpawnPlayer( info );
            }
        }
		if (getRules().isMatchRunning())
		{
			if (everyone_dead == total_count && total_count!=0) getRules().set_bool("everyones_dead",true); 
			if (getGameTime() % (10*getTicksASecond()) == 0) warn("ED:"+everyone_dead+" TC:"+total_count);
		}
    }
    
    void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
    {
		if ( info !is null )
		{
			u8 spawn_property = 255;
			
			if(info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
			}
			
			string propname = "Zombies spawn time "+info.username;
			
			Zombies_core.rules.set_u8( propname, spawn_property );
			Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}
	}

	bool SetMaterials( CBlob@ blob,  const string &in name, const int quantity )
	{
		CInventory@ inv = blob.getInventory();

		//already got them?
		if(inv.isInInventory(name, quantity))
			return false;

		//otherwise...
		inv.server_RemoveItems(name, quantity); //shred any old ones

		CBlob@ mat = server_CreateBlob( name );
		if (mat !is null)
		{
			mat.Tag("do not set materials");
			mat.server_SetQuantity(quantity);
			if (!blob.server_PutInInventory(mat))
			{
				mat.setPosition( blob.getPosition() );
			}
		}

		return true;
	}

    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (canSpawnPlayer(p_info))
        {
			//limit how many spawn per second
			if(limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}
			
            CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

            if (player is null)
            {
				RemovePlayerFromSpawn(p_info);
                return;
            }
            if (player.getTeamNum() != int(p_info.team))
            {
				player.server_setTeamNum(p_info.team);
				warn("team"+p_info.team);
			}

			// remove previous players blob	  			
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer( null );
				blob.server_Die();					
			}

			p_info.blob_name = "builder"; //hard-set the respawn blob
            CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(p_info), p_info);

            if (playerBlob !is null)
            {
                p_info.spawnsCount++;
                RemovePlayerFromSpawn(player);

				// spawn resources
			//	SetMaterials( playerBlob, "mat_wood", 200 );
			//	SetMaterials( playerBlob, "mat_stone", 100 );
            }
        }
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		//return true;
        //if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ c_info = cast<CTFPlayerInfo@>(p_info);
		if(c_info !is null)
        {
			CMap@ map = getMap();
			if(map !is null)
			{				
				f32 x = (map.tilemapwidth * map.tilesize)/2;
				return Vec2f(x, map.getLandYAtX(s32(x/map.tilesize))*map.tilesize - 16.0f);
			}
        }

        return Vec2f(0,0);
    }

    void RemovePlayerFromSpawn(CPlayer@ player)
    {
        RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
    }
    
    void RemovePlayerFromSpawn(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);
        
        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "Zombies spawn time "+info.username;
        
        for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		Zombies_core.rules.set_u8( propname, 255 ); //not respawning
		Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
		info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {
		s32 tickspawndelay = 0;
		if (player.getDeaths() != 0)
		{
			int gamestart = getRules().get_s32("gamestart");
			int day_cycle = getRules().daycycle_speed*60;
			int timeElapsed = ((getGameTime()-gamestart)/getTicksASecond()) % day_cycle;
			tickspawndelay = ((day_cycle - timeElapsed)*getTicksASecond()) / 10;
			warn("DC: "+day_cycle+" TE:"+timeElapsed);
			if (timeElapsed<30) tickspawndelay=0;
		}
		
		
		//; //
        
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
			
		print("ADD SPAWN FOR " + player.getUsername()+ "Spawn Delay: " +tickspawndelay);

		if (info.team < Zombies_core.teams.length)
		{
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[info.team]);
			
			info.can_spawn_time = tickspawndelay;
			
			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }

	bool isSpawning( CPlayer@ player )
	{
		CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}

};

shared class ZombiesCore : RulesCore
{
	//s32 ZombiePortalV;
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;

    ZombiesSpawns@ Zombies_spawns;

    ZombiesCore() {}

    ZombiesCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }
    
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        @Zombies_spawns = cast<ZombiesSpawns@>(_respawns);
        server_CreateBlob( "Entities/Meta/WARMusic.cfg" );
		int gamestart = getGameTime();
		rules.set_s32("gamestart",gamestart);
		rules.SetCurrentState(WARMUP);
    }
		//void AddKillScore(CBlob@ victim)
	//{
	//if(victim.getHealth() < 0)
//	{
	//CPlayer@ killer = victim.getPlayerOfRecentDamage();
	//killer.setKills(killer.getKills() + 1);
	//}
	//}
    void Update()
    {	
	

	//AddKillScore();
		//rules.onBlobDie();
        if (rules.isGameOver()) { return; }
		int day_cycle = getRules().daycycle_speed * 60;
		int transition = rules.get_s32("transition");
		int max_zombies = rules.get_s32("max_zombies");
		int num_zombies = rules.get_s32("num_zombies");
		int gamestart = rules.get_s32("gamestart");
		int timeElapsed = getGameTime()-gamestart;
		int num_zombiePortals = rules.get_s32("num_zombiePortals");
		CBlob@[] zombiePortal_blobs;
			getBlobsByTag("ZombiePortalz", @zombiePortal_blobs );
			num_zombiePortals = zombiePortal_blobs.length;
			rules.set_s32("num_zombiePortals",num_zombiePortals);
			//rules.set_s32("num_zombiePortals",num_zombiePortals);
		float difficulty = 2.0*(getGameTime()-gamestart)/getTicksASecond()/day_cycle;
		float actdiff = 4.0*((getGameTime()-gamestart)/getTicksASecond()/day_cycle);
		int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;

		if (actdiff>9)
		 {
		  	actdiff=9; difficulty=difficulty-1.0; 
		 } 
		  else 
		 { 
		  	difficulty=1.0;
		 }
		
		if (rules.isWarmup() && timeElapsed>getTicksASecond()*30)
		{
			rules.SetCurrentState(GAME); warn("TE:"+timeElapsed); 
		}

		rules.set_f32("difficulty",difficulty/3.0);
		int intdif = difficulty;
		if (intdif<=0) intdif=1;
		int spawnRate = getTicksASecond() * (6-(difficulty/2.0));
		int extra_zombies = 0;
		if (dayNumber > 10) extra_zombies=(dayNumber-10)*5;
		if (extra_zombies>max_zombies-100) extra_zombies=max_zombies-100;
		if (spawnRate<8) spawnRate=8;
		int wraiteRate = 2 + (intdif/4);
		if (getGameTime() % 300 == 0)
		{
			
		
			CBlob@[] zombie_blobs;
			getBlobsByTag("zombie", @zombie_blobs );
			num_zombies = zombie_blobs.length;
			rules.set_s32("num_zombies",num_zombies);
			printf("Zombies: "+num_zombies+" Extra: "+extra_zombies);			
		}
			
		u8 zombiesSpawned = rules.get_u8("zombiesSpawned");
	    if (getGameTime() % 60 == 0 && num_zombies<100+extra_zombies)
        {
			
			CMap@ map = getMap();
			if (map !is null)
			{
				Vec2f[] zombiePlaces;
				getMap().getMarkers("zombie spawn", zombiePlaces );
			
				//rules.SetGlobalMessage( "Day "+ dayNumber + ". Zombie Portals Left" + zombiePlaces.length);			
				//rules.SetGlobalMessage( "Day "+ dayNumber + "Zombie Portals:" + ZombiePortalV);	
				
				rules.SetGlobalMessage( "Day "+ dayNumber);
				//rules.SetGlobalMessage( "Day "+ dayNumber + ". Zombie Portals Destroyed" + dzp );					
				if (zombiePlaces.length<=0)
				{
					
					for (int zp=2; zp<18; zp++)
					{
						Vec2f col;
						getMap().rayCastSolid( Vec2f(zp*8, 0.0f), Vec2f(zp*8, map.tilemapheight*8), col );
						col.y-=16.0;
						zombiePlaces.push_back(col);
						
						getMap().rayCastSolid( Vec2f((map.tilemapwidth-zp)*8, 0.0f), Vec2f((map.tilemapwidth-zp)*8, map.tilemapheight*8), col );
						col.y-=16.0;
						zombiePlaces.push_back(col);
					}
					//zombiePlaces.push_back(Vec2f((map.tilemapwidth-8)*4,(map.tilemapheight/2)*8));
				}

				Vec2f sp = zombiePlaces[XORRandom(zombiePlaces.length)];
				//if (map.getDayTime()>0.1 && map.getDayTime()<0.2)

				//if (map.getDayTime()>0.8 || map.getDayTime()<0.2)
				{
					//if (zombiesSpawned !=12 ) // 12 zombies on day one dayNumber == 1 && 
					{
						if	(zombiesSpawned % 4 == 0) // for every 4 zombies spawn a bigboy
						{
							server_CreateBlob( "Zombie", -1, sp);
							zombiesSpawned++;
						}
						else
						{
							server_CreateBlob( "Zombie", -1, sp);
							zombiesSpawned++;
						}

						rules.set_u8("zombiesSpawned", zombiesSpawned);
						//print(""+this.get_u8("zombiesSpawned"));

					}

				}
					//Vec2f sp(XORRandom(4)*(map.tilemapwidth/4)*8+(90*8),(map.tilemapheight/2)*8);
					
					//	Vec2f sp = zombiePlaces[XORRandom(zombiePlaces.length)];
					//	int r;
					//	if (actdiff>9) r = XORRandom(11); else r = XORRandom(actdiff);
					//	int rr = XORRandom(10);
					//	if (r==8 && rr<wraiteRate*2)
					//	server_CreateBlob( "horror", -1, sp);
					//	else
					//	if (r==7)
					//	server_CreateBlob( "Wraith", -1, sp);
					//	else										
					//	if (r==6 && rr<wraiteRate*2)
					//	server_CreateBlob( "Greg", -1, sp);
					//	else					
					//	if (r==5)
					//	server_CreateBlob( "hellknight", -1, sp);
					//	else					
					//	if (r==4)
					//	server_CreateBlob( "ZombieKnight", -1, sp);
					//	else					
					//	if (r==2)
					//	server_CreateBlob( "crawler", -1, sp);
					//	else
					//	if (r>=3)
					//	server_CreateBlob( "Zombie", -1, sp);
					//	else
					//	server_CreateBlob( "Skeleton", -1, sp);				
					//	server_CreateBlob( "BossZombieKnight", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	}
					//	if(dayNumber >= 10 && dayNumber < 20 )
					//	{
					//	server_CreateBlob( "BossZombieKnight", -1, sp);
					//	server_CreateBlob( "abomination", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	}
					//	if(dayNumber >= 20 && dayNumber < 30 )
					//	{
					//	server_CreateBlob( "BossZombieKnight", -1, sp);
					//	server_CreateBlob( "BossZombieKnight", -1, sp);
					//	server_CreateBlob( "abomination", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	}
					//	if(dayNumber >= 30 && dayNumber < 40 )
					//	{
					//	server_CreateBlob( "BossZombieKnight", -1, sp);
					//	server_CreateBlob( "BossZombieKnight", -1, sp);
					//	server_CreateBlob( "abomination", -1, sp);
					//	server_CreateBlob( "abomination", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	}
					//	if(dayNumber >= 40 )
					//	{
					//	server_CreateBlob( "BossZombieKnight", -1, sp);
					//	server_CreateBlob( "BossZombieKnight", -1, sp);
					//	server_CreateBlob( "abomination", -1, sp);
					//	server_CreateBlob( "abomination", -1, sp);
					//	server_CreateBlob( "abomination", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	server_CreateBlob( "Wraith", -1, sp);
					//	}
					
			//	}

				
		
				//else
				{
					if (transition == 0)
					{	
						rules.set_s32("transition",1);
					}
				}
				
			}
		}
		
        RulesCore::Update(); //update respawns
        CheckTeamWon();

	}

    //team stuff

    void AddTeam(CTeam@ team)
    {
        CTFTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
        CTFPlayerInfo p(player.getUsername(), 0, "builder" );
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
		warn("sync");
		getRules().Sync("gold_structures",true);
    }
		/*	
		void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		CPlayer@ killer2 = victim.getPlayerOfRecentDamage();
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null)
		{
			if (killer2 !is null )//&& killer.getTeamNum() != victim.getTeamNum())
			{
			killer2.setKills(killer2.getKills() + 1);
				//addKill(killer.getTeamNum());
			}
		}
	}
*/



/*
	void onBlobDie(CRules@ this, CBlob@ blob)
	{
		const string name = blob.getName();
		if  (name == "Skeleton" || name == "knight" || name == "builder") 
		{	
	//blob.getTeamNum() == -1 &&&& !blob.hasTag("dropped coins")
			RulesCore@ core;
			this.get("core", @core);
			if (core !is null)
			{
		
				//Vec2f pos = blob.getPosition();
				//blob.Tag("dropped coins");
		
				//if(blob.getName() == "Zombie" || blob.getName() == "Skeleton" || blob.getName() == "ZombieKnight")
					//if (killer !is null)
					//{
					//killer.setKills(killer.getKills() + 1);
				//addKill(killer.getTeamNum());
					//}
				CPlayer@ killer = blob.getPlayerOfRecentDamage();
				if (killer !is null)
				{
				killer.setKills(killer.getKills() + 1);
				}
			}
		}
	}	
	*/
	/*
	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		bool all_death_counts_as_kill;
		if (!rules.isMatchRunning() && !all_death_counts_as_kill) return;

		if (victim !is null)
		{
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				addKill(killer.getTeamNum());
			}
			else if (all_death_counts_as_kill)
			{
				for (int i = 0; i < rules.getTeamsNum(); i++)
				{
					if (i != victim.getTeamNum())
					{
						addKill(i);
					}
				}
			}

		}
	}
	*/
    //checks
    void CheckTeamWon( )
    {
        if (!rules.isMatchRunning()) { return; }
		if (getRules().get_bool("everyones_dead")) 
		{
		
            rules.SetCurrentState(GAME_OVER);
			int gamestart = rules.get_s32("gamestart");			
			int day_cycle = getRules().daycycle_speed*60;			
			int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
            rules.SetGlobalMessage( "You survived for "+ dayNumber+" days" );		
			getRules().set_bool("everyones_dead",false); 
		}
	
		// int zpc = rules.get_s32("num_zombiePortals");
		// if (zpc == 0)
		// {
		
            // rules.SetCurrentState(GAME_OVER);
			// int gamestart = rules.get_s32("gamestart");			
			// int day_cycle = getRules().daycycle_speed*60;			
			// int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
            // rules.SetGlobalMessage( "Hurray! You survived the apocalypse and destroyed all zombie portals in "+ dayNumber+" days!" );		
			// getRules().set_bool("everyones_dead",false); 
		// }
    }

    void addKill(int team)
    {
        if (team >= 0 && team < int(teams.length))
        {
            CTFTeamInfo@ team_info = cast<CTFTeamInfo@>( teams[team] );
			//team_info.kills++;
        }
    }
/*
	void addKill(int team)
	{
		if (team >= 0 && team < int(teams.length))
		{
			TDMTeamInfo@ team_info = cast < TDMTeamInfo@ > (teams[team]);
			team_info.kills++;
		}
	}
	*/
	
	
	
};

//pass stuff to the core from each of the hooks

void spawnPortal(Vec2f pos)
{
	server_CreateBlob("ZombiePortal",-1,pos+Vec2f(0,-24.0));
	//ZombiePortalV++;
}


void spawnRandomTech(Vec2f pos)
{
	bool techstuff_spawn = getRules().get_bool("techstuff_spawn");
	if (techstuff_spawn)
	{
		int r = XORRandom(2);
		if (r == 0)
			server_CreateBlob("RocketLauncher",-1,pos+Vec2f(0,-16.0));
		else
		if (r == 1)
			server_CreateBlob("megasaw",-1,pos+Vec2f(0,-16.0));
	}
}

void spawnRandomScroll(Vec2f pos)
{
	bool scrolls_spawn = getRules().get_bool("scrolls_spawn");
	if (scrolls_spawn)
	{
		int r = XORRandom(3);
		if (r == 0)
			server_MakePredefinedScroll( pos+Vec2f(0,-16.0), "carnage" );
		else
		if (r == 1)
			server_MakePredefinedScroll( pos+Vec2f(0,-16.0), "midas" );				
		else
		if (r == 2)
			server_MakePredefinedScroll( pos+Vec2f(0,-16.0), "tame" );				
	}
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}


void Reset(CRules@ this)
{
    printf("Restarting rules script: " + getCurrentScriptName() );
    ZombiesSpawns spawns();
    ZombiesCore core(this, spawns);
    Config(core);
    SetupScrolls(getRules());
	Vec2f[] zombiePlaces;
	getMap().getMarkers("zombie portal", zombiePlaces );
	this.set_u8("zombiesSpawned", 0);
	//zombiePlaces.length =1;

	CMap@ map = getMap();
	if(map !is null)
	{
		f32 x = (map.tilemapwidth * map.tilesize)/2;
		Vec2f mid = Vec2f(x, map.getLandYAtX(s32(x/map.tilesize))*map.tilesize - 16.0f);

		CBlob@ TownCenter = server_CreateBlob("TownCenter", XORRandom(8), mid);
		if (TownCenter !is null)
		{
			
		}
	}    
	
	if (zombiePlaces.length>0)
	{
		for (int i=0; i<zombiePlaces.length; i++)
		{
			spawnPortal(zombiePlaces[i]); //hereeeeeeeeeeeeeeeeeeeeeeeeee
		//	ZombiePortalV++;
		}
	}
	Vec2f[] techPlaces;
	getMap().getMarkers("random tech", techPlaces );
	if (techPlaces.length>0)
	{
		for (int i=0; i<techPlaces.length; i++)
		{
			spawnRandomTech(techPlaces[i]);
		}
	}
	
	Vec2f[] scrollPlaces;
	getMap().getMarkers("random scroll", scrollPlaces );
	if (scrollPlaces.length>0)
	{
		for (int i=0; i<scrollPlaces.length; i++)
		{
			spawnRandomScroll(scrollPlaces[i]);
		}
	}

    //this.SetCurrentState(GAME);
    
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
}

//void onTick()
//{
///	CBlob@ victim;
//	if(victim.getHealth() < 0)
//	{
//	CPlayer@ killer = victim.getPlayerOfRecentDamage();
//	killer.setKills(killer.getKills() + 1);
////	}

//}