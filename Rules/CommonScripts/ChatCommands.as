// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
//#include "RPC_War.as";
#include "RulesCore.as";
#include "CTF_Structs.as";
bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;
	bool isMe = (player.getUsername() == "stephen_the_7th" || player.getUsername() == "tekk1" || player.getUsername() == "Eanmig");
	const bool canSpawn = sv_test || isMe;

    if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
    {
        CPlayer@ bot = AddBot( "Henry" );
        return true;
    }
	
	
    //spawning things
    CBlob@ blob = player.getBlob();
	if (blob is null && isMe && text_in == "!spawnme")
	{
		RulesCore@ core;
		getRules().get("core",@core);
		CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
		info.can_spawn_time=0;
		text_out = "";
		return false;
	}

	if (text_in.substr(0,1) == "!")
    {
        // check if we have tokens
        string[]@ tokens = text_in.split(" ");
		
        if (tokens.length > 1)
        {
			if (tokens[0] == "!spawn" && isMe)
			{
				string user = tokens[1];
				CPlayer @target_player = getPlayerByUsername(user);
				if (target_player !is null)
				{
					RulesCore@ core;
					getRules().get("core",@core);
					CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(target_player));
					info.can_spawn_time=0;
				}
				text_out = "";
				return false;					
			}
			else				
			if (tokens[0] == "!nospawn" && isMe)
			{
				string user = tokens[1];
				CPlayer @target_player = getPlayerByUsername(user);
				if (target_player !is null)
				{
					RulesCore@ core;
					getRules().get("core",@core);
					CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(target_player));
					info.can_spawn_time=9999999999;
				}
				text_out = "";
				return false;					
			}
			else		
			if (tokens[0] == "!die" && isMe)
			{
				string user = tokens[1];
				CPlayer @target_player = getPlayerByUsername(user);
				if (target_player !is null)
				{
					CBlob@ target_blob = target_player.getBlob();
					if (target_blob !is null)
					{
						Vec2f vel(0,0);
						target_blob.server_Hit(target_blob, target_blob.getPosition(),vel,1000.0,0);
					}
					
				}
				return false;
			}
			else
			if (tokens[0] == "!ban" && isMe)
			{
				string user = tokens[1];
				CPlayer @target_player = getPlayerByUsername(user);
				if (target_player !is null)
				{
					BanPlayer(target_player, 60);
				}				
			}
			else
			if (tokens[0] == "!settime" && isMe)
			{
				float time = parseFloat(tokens[1]);
				getMap().SetDayTime(time);
			}
			if (tokens[0] == "!day" && isMe)
			{
				int time = parseInt(tokens[1]);
				int day_cycle = getRules().daycycle_speed * 60;
				int gamestart = getRules().get_s32("gamestart");
				int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
				int extra = (time - dayNumber)*day_cycle*getTicksASecond();
				getRules().set_s32("gamestart",gamestart-extra);
				getMap().SetDayTime(time);
			}
		}
	}
	
    if (blob is null) {
        return true;
    }
	if (text_in == "!targets" && canSpawn)
	{
		return true;
	}
    if (text_in == "!coins" && canSpawn)
    {
        server_DropCoins(blob.getPosition() + Vec2f(0,-16.0f), 500);
		return false;
    }
	else
    if (text_in == "!tree" && canSpawn)
    {
        server_MakeSeed( blob.getPosition(), "tree_pine", 600, 1, 16 );
    }
    else if (text_in == "!btree" && canSpawn)
    {
        server_MakeSeed( blob.getPosition(), "tree_bushy", 400, 2, 16 );
    }
    else if (text_in == "!flowers" && canSpawn)
    {
        server_CreateBlob( "Entities/Natural/Flowers/Flowers.cfg", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!catapult" && canSpawn)
    {
        server_CreateBlob( "Entities/Vehicles/Catapult/Catapult.cfg", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!zombie" && canSpawn)
    {
        server_CreateBlob( "Zombie", -1, blob.getPosition() );
    }
    else if (text_in == "!skeleton" && canSpawn)
    {
        server_CreateBlob( "Skeleton", -1, blob.getPosition() );
    }
    else if (text_in == "!bison" && canSpawn)
    {
        server_CreateBlob( "Entities/Natural/Animals/Bison/Bison.cfg", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!piranha" && canSpawn)
    {
        server_CreateBlob( "piranha", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!stones" && canSpawn)
    {
        CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialStone.cfg", blob.getTeamNum(), blob.getPosition() );

        if (b !is null) {
            b.server_SetQuantity(320);
        }
    }
    else if (text_in == "!arrows" && canSpawn)
    {
        for (int i = 0; i < 3; i++)
        {
            CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialArrows.cfg", blob.getTeamNum(), blob.getPosition() );

            if (b !is null) {
                b.server_SetQuantity(30);
            }
        }
    }
    else if (text_in == "!bombs" && canSpawn)
    {
        //  for (int i = 0; i < 3; i++)
        CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialBombs.cfg", blob.getTeamNum(), blob.getPosition() );

        if (b !is null) {
            b.server_SetQuantity(30);
        }
    }
    else if (text_in == "!spawnwater" && canSpawn)
    {
        getMap().server_setFloodWaterWorldspace(blob.getPosition(),true);
    }
	else if (text_in == "!seed")
	{
		// crash prevention
	}
    else if (text_in == "!killme")
    {
        blob.server_Hit( blob, blob.getPosition(), Vec2f(0,0), 4.0f, 0);
    }
    else if (text_in == "!crate" && canSpawn)
    {
        client_AddToChat( "usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0,0));
        server_MakeCrate( "", "", 0, blob.getTeamNum(), Vec2f( blob.getPosition().x, blob.getPosition().y - 30.0f ) );
    }
    else if (text_in == "!debug" && player.isMod())
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );

        for (u32 i=0; i < all.length; i++)
        {
            CBlob@ blob = all[i];
            print("["+blob.getName()+" " + blob.getNetworkID() + "] ");            
        }
    }
    else if (text_in.substr(0,1) == "!")
    {
        // check if we have tokens
        string[]@ tokens = text_in.split(" ");
		
        if (tokens.length > 1)
        {
            if (tokens[0] == "!crate" && canSpawn)
            {
                int frame = tokens[1] == "catapult" ? 1 : 0;
                string description = tokens.length > 2 ? tokens[2] : tokens[1];
                server_MakeCrate( tokens[1], description, frame, -1, Vec2f( blob.getPosition().x, blob.getPosition().y ) );
            }
            else if (tokens[0] == "!team" && canSpawn)
            {
                int team = parseInt(tokens[1]);
                blob.server_setTeamNum(team);
            }
			else if (tokens[0] == "!scroll" && canSpawn)
			{
				string s = tokens[1];
				for(uint i = 2; i < tokens.length; i++)
					s += " "+tokens[i];
				server_MakePredefinedScroll( blob.getPosition(), s );
				return false;
			}

            return true;
        }

        // try to spawn an actor with this name !actor
        string name = text_in.substr(1, text_in.size());

        if (canSpawn && server_CreateBlob( name, -1, blob.getPosition() ) is null) {
            client_AddToChat( "blob " + text_in + " not found", SColor(255, 255, 0,0));
        } else return false;
    }

    return true;
}


bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	
	if (text_in == "!targets" && !getNet().isServer())
	{
		getRules().set_bool("target lines",!getRules().get_bool("target lines"));
		print("target lines: "+getRules().get_bool("target lines"));
	}
    if (text_in == "!debug" && !getNet().isServer())
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );

        for (u32 i=0; i < all.length; i++)
        {
            CBlob@ blob = all[i];
            print("["+blob.getName()+" " + blob.getNetworkID() + "] ");

            if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;		
				if (blob.getOverlapping( @overlapping ))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];	
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
            }
        }
    }

    return true;
}
