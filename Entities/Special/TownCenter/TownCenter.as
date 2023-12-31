#include "Descriptions.as"
#include "ShopCommon.as"
#include "ProductionCommon.as"
#include "Requirements.as"
#include "AddTilesBySector.as"
#include "Costs.as"
#include "MakeFood.as";
#include "TownCenterFires.as";

const Vec2f upgradeButtonPos(-16.0f, 0.0f);

void onInit(CBlob@ this)
{
    this.getShape().getConsts().mapCollisions = false;
    this.getCurrentScript().tickFrequency = 1;
    this.getSprite().SetEmitSound("CampfireSound.ogg");
    this.SetLight(false);
    this.SetLightRadius(164.0f);
    this.SetLightColor(SColor(255, 255, 240, 171));
    this.Tag("fire source");
    this.getSprite().SetZ(-20.0f);
    this.getShape().SetStatic(true);
    this.getShape().getConsts().mapCollisions = false;
    this.set_u8("old_upgrade_level", 100);
    this.set_u8("old_upgrade_level_sprite", 100);    
    this.set_u16("wood", 0);
    this.set_u16("old wood", 0);
    this.set_s16("wood for upgrade", woodForUpgrade(this));   //set up the wood for upgrade property
    this.set_s16("upgrade amount", upgradeAmount(this, this.get_u8("upgrade_level")));


    if (!this.exists("upgrade_level"))
        {this.set_u8("upgrade_level", 0);}
    // these are overwritten in War Rules script
    // !!!
    if (!this.exists("upgrade_1_cost"))
        {this.set_u16("upgrade_1_cost", 300);}

    if (!this.exists("upgrade_2_cost"))
        {this.set_u16("upgrade_2_cost", 800);}

    
    this.addCommandID("upgraded");
    this.addCommandID("workbench menu");
    this.addCommandID("dump wood");

    Vec2f Position = this.getPosition();
    getMap().server_SetTile( Position, CMap::tile_empty);
    getMap().server_SetTile( Vec2f(Position.x-8,Position.y) , CMap::tile_empty);
    getMap().server_SetTile( Vec2f(Position.x+8,Position.y) , CMap::tile_empty);
   // getMap().server_SetTile( Vec2f(Position.x+16,Position.y) , CMap::tile_empty);
}

void onTick(CBlob@ this)
{    
    const int team = this.getTeamNum();
    this.SetFacingLeft(team != 0);   // the sprites are flipped in the sprite sheet
    const int gametime = getGameTime() + team; //!
    const int performance_opt = 14;

    if (getNet().isServer() && (gametime % performance_opt == 7))
    {
        u8 alert = this.get_u8("alert_time");
        int myteam = this.getTeamNum();
        Vec2f pos = this.getPosition();
        CBlob@[] blobs;
        this.getMap().getBlobs(@blobs);

        for (uint blob_step = 0; blob_step < blobs.length; ++blob_step)
        {
            CBlob@ blob = blobs[blob_step];
            int blob_team = blob.getTeamNum();

            if (blob_team != myteam && blob_team < 32 && blob_team >= 0)
            {
                f32 dist = (blob.getPosition() - pos).Length();

                if (dist < 128.0f)
                {
                    alert = 30;
                    break;
                }
            }
        }

        if (alert > 0)
        {
            alert--;
        }

        this.set_u8("alert_time", alert);

    }

    if ((gametime % performance_opt == 0))
    {
        if (getNet().isServer())
        {
            s16 wood_amount = this.get_u16("wood");

            s16 upgrade_1 = this.get_u16("upgrade_1_cost");
            s16 upgrade_2 = this.get_u16("upgrade_2_cost");

            u8 old_level = this.get_u8("upgrade_level");
            u8 upgrade_level = (wood_amount >= upgrade_1 + upgrade_2) ? 2 : (wood_amount >= upgrade_1 ? 1 : 0);

            if (old_level != upgrade_level)
            {
                CBitStream params;
                params.write_u8(upgrade_level);
                params.write_u8(old_level);
                this.SendCommand(this.getCommandID("upgraded"), params);
            }

            this.set_u8("old_upgrade_level", old_level);
            this.set_u8("upgrade_level", upgrade_level);
            this.Sync("upgrade_level", true);

            this.set_s16("wood for upgrade", woodForUpgrade(this));   //set up the wood for upgrade property
            this.set_s16("upgrade amount", upgradeAmount(this, upgrade_level));

        } // server

        this.set_bool("shop available", this.get_u8("upgrade_level") >= 2);
    }


    if (this.isInWater())
    {
        this.getSprite().Gib();
        this.server_Die();
        this.getCurrentScript().runFlags |= Script::remove_after_this;
    }

    bool fireLit = false;

    CInventory@ inv = this.getInventory();
    for (int i = 0; i < inv.getItemsCount(); i++)
    {     
        bool hasWood; 
        CBlob@ invblob = inv.getItem(i);
        if (invblob.getName() == "mat_wood")
        {
            if (!fireLit)
            {
                this.getSprite().getSpriteLayer("fire_animation_large").SetVisible(true);
                this.SetLight(true);
                fireLit = true;
            }            
            Vec2f fireOffset = Vec2f(0,-8);
            makeSmokeParticle(this.getPosition(), -0.15f);
            if (XORRandom(3) == 0)
            {
                this.getSprite().SetEmitSoundPaused(false);
            }
            f32 stack_size = invblob.getQuantity();
            invblob.server_SetQuantity(stack_size-1);
        }
        else 
        {
            fireLit = false;
            this.getSprite().getSpriteLayer("fire_animation_large").SetVisible(false);
            this.SetLight(false);
        }
    }
}

void PutCarriedInInventory(CBlob@ this, const string& in carriedName)
{
    CBlob@ handsBlob = this.getCarriedBlob();

    if (handsBlob !is null && handsBlob.getName() == carriedName)
    {
        this.server_PutInInventory(handsBlob);
    }
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    CBitStream params;
    params.write_u16(caller.getNetworkID());


    if (this.get_u8("upgrade_level") < 2) // upgrade button
    {
        CButton@ button = caller.CreateGenericButton("$mat_wood$", upgradeButtonPos, this, this.getCommandID("dump wood"), "Use wood to upgrade", params);
        if (button !is null)
        {
            button.deleteAfterClick = false;
            button.SetEnabled(hasBlob(caller, "mat_wood"));
        }
    }

    //caller.CreateGenericButton( 12, Vec2f(40, -10), this, this.getCommandID("liftoff"), "Armageddon", params );
}

s16 maxWood(CBlob@ this)
{
    s16 upgrade_1 = this.get_u16("upgrade_1_cost");
    s16 upgrade_2 = this.get_u16("upgrade_2_cost");
    return upgrade_1 + upgrade_2;
}

s16 upgradeAmount(CBlob@ this, int currentlevel)
{
    if (currentlevel == 0)
    {
        return this.get_u16("upgrade_1_cost");
    }
    else if (currentlevel == 1)
    {
        return this.get_u16("upgrade_2_cost");
    }
    else
    {
        return 0;
    }
}

s16 lastUgradeAmount(CBlob@ this, int currentlevel)
{
    s16 amount = 0;

    while (currentlevel > 0)
    {
        amount += upgradeAmount(this, --currentlevel);
    }

    return amount;
}

s16 woodForUpgrade(CBlob@ this)
{
    u8 upgrade_level = this.get_u8("upgrade_level");
    s16 wood_amount = this.get_u16("wood");
    s16 last = lastUgradeAmount(this, upgrade_level);
    return wood_amount - last;
}

s16 woodTilUpgrade(CBlob@ this)
{
    u8 upgrade_level = this.get_u8("upgrade_level");
    s16 wood_amount = this.get_u16("wood") - lastUgradeAmount(this, upgrade_level);
    return upgradeAmount(this, upgrade_level) - wood_amount;
}

//this should be an include...
bool hasBlob(CBlob@ this, const string& in name)
{
    CBlob@ handsBlob = this.getCarriedBlob();

    if (handsBlob !is null && handsBlob.getName() == name)
    {
        return true;
    }

    return this.getInventory().getCount(name) > 0;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
    if (blob !is null)
    {
        if (blob.getName() == "fishy")
        {
            blob.getSprite().PlaySound("SparkleShort.ogg");
            server_MakeFood(blob.getPosition(), "Cooked Fish", 1);
            blob.server_Die();
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    bool isServer = getNet().isServer();
    //printf("base cmd " + cmd );

    if (cmd == this.getCommandID("dump wood"))
    {
        CBlob@ caller = getBlobByNetworkID(params.read_u16());
        CInventory@ inv = caller.getInventory();

        if (inv !is null)
        {
            if (isServer)
            {
                PutCarriedInInventory(caller, "mat_wood");   // put carried wood in inventory before dumping so its easier to do if you dont have it in inv
                int wood_count = Maths::Min(woodTilUpgrade(this), Maths::Min(100, inv.getCount("mat_wood")));

                if (wood_count > 0)
                {
                    inv.server_RemoveItems("mat_wood", wood_count);
                    this.set_u16("wood", this.get_u16("wood") + wood_count);
                    this.Sync("wood", true);
                }
            }

            // disable button if used up wood or upgrade level full
            if (inv.getCount("mat_wood") == 0)
            {
                CButton@ button = getHUD().getButtonWithCommandID(cmd);

                if (button !is null)
                {
                    button.SetEnabled(false);    // FIXME: this function is broken
                }
            }
        }
    }
}

void onInit(CSprite@ this)
{
    this.SetZ(-50); //background
    CBlob@ blob = this.getBlob();
    const string filename = CFileMatcher("/TownCenter.png").getFirst();
    const int blob_team = blob.getTeamNum();
    const int blob_skin = blob.getSkinNum();

    //init flame layer
    CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large", "Entities/Special/ZombieTown/TownCenterFire.png", 32, 16, -1, -1);

    if (fire !is null)
    {
        fire.SetRelativeZ(100);
        {
            Animation@ anim = fire.addAnimation("bigfire", 6, true);
            anim.AddFrame(1);
            anim.AddFrame(2);
            anim.AddFrame(3);
            anim.AddFrame(4);
            anim.AddFrame(5);
            anim.AddFrame(6);
        }
        fire.SetVisible(false);
        fire.SetOffset(Vec2f(0, -4));
    }

        //upgrade sprites
    {
        Vec2f tunnel_offset(64, -8);
        Vec2f bench_offset(32, -8);

        CSpriteLayer@ tunnel = this.addSpriteLayer("tunnel", filename , 24, 24, blob_team, blob_skin);

        if (tunnel !is null)
        {
            Animation@ anim = tunnel.addAnimation("default", 0, false);
            anim.AddFrame(49);

            tunnel.SetOffset(tunnel_offset);
            tunnel.SetVisible(false);
        }

        CSpriteLayer@ upgrade_table = this.addSpriteLayer("upgrade_table", filename , 32, 32, blob_team, blob_skin);

        if (upgrade_table !is null)
        {
            Animation@ anim = upgrade_table.addAnimation("default", 0, false);
            anim.AddFrame(15);

            upgrade_table.SetVisible(true);

            upgrade_table.SetOffset(bench_offset);
        }
    }
    //tower sprites
    //{
    //    CSpriteLayer@ tower_cap = this.addSpriteLayer("tower_cap", filename , 32, 32, blob_team, blob_skin);
//
    //    if (tower_cap !is null)
    //    {
    //        Animation@ anim = tower_cap.addAnimation("default", 0, false);
    //        anim.AddFrame(16);
    //        anim.AddFrame(24);
    //        tower_cap.SetVisible(false);
    //    }
//
    //    CSpriteLayer@ tower = this.addSpriteLayer("tower", filename , 32, 32, blob_team, blob_skin);
//
    //    if (tower !is null)
    //    {
    //        Animation@ anim = tower.addAnimation("default", 0, false);
    //        anim.AddFrame(17);
    //        anim.AddFrame(18);
    //        anim.AddFrame(25);
    //        anim.AddFrame(26);
    //        tower.SetVisible(false);
    //    }
//
    //    CSpriteLayer@ tower_flagpole = this.addSpriteLayer("tower_flagpole", "Entities/Special/CTF/CTF_Flag.png" , 16, 32, blob_team, blob_skin);
//
    //    if (tower_flagpole !is null)
    //    {
    //        Animation@ anim = tower_flagpole.addAnimation("default", 0, false);
    //        anim.AddFrame(3);
    //    }
//
    //    CSpriteLayer@ tower_flag = this.addSpriteLayer("tower_flag", "Entities/Special/CTF/CTF_Flag.png" , 32, 16, blob_team, blob_skin);
//
    //    if (tower_flag !is null)
    //    {
    //        Animation@ anim = tower_flag.addAnimation("default", 3, true);
    //        anim.AddFrame(0);
    //        anim.AddFrame(2);
    //        anim.AddFrame(4);
    //        anim.AddFrame(6);
    //        tower_flag.SetVisible(false);
    //    }
    //}
    ////barracks sprites
    //{
    //    Vec2f barracks_offset = Vec2f(88, 0);
    //    CSpriteLayer@ barracks_unbuilt = this.addSpriteLayer("barracks_unbuilt", filename , 96, 16, blob_team, blob_skin);
//
    //    if (barracks_unbuilt !is null)
    //    {
    //        Animation@ anim = barracks_unbuilt.addAnimation("default", 0, false);
    //        anim.AddFrame(13);
    //        barracks_unbuilt.SetVisible(true);
    //        barracks_unbuilt.SetOffset(barracks_offset + Vec2f(0.0f, 16.0f));
    //        barracks_unbuilt.SetRelativeZ(-50.0);
    //    }
//
    //    CSpriteLayer@ barracks = this.addSpriteLayer("barracks", filename , 96, 48, blob_team, blob_skin);
//
    //    if (barracks !is null)
    //    {
    //        Animation@ anim = barracks.addAnimation("default", 0, false);
    //        anim.AddFrame(1);
    //        anim.AddFrame(3);
    //        barracks.SetVisible(false);
    //        barracks.SetOffset(barracks_offset + Vec2f(0.0f, 0.0f));
    //        barracks.SetRelativeZ(-50.0);
    //    }
//
    //    CSpriteLayer@ barracks_weapons = this.addSpriteLayer("barracks_weapons", filename, 32, 32, blob_team, blob_skin);
//
    //    if (barracks_weapons !is null)
    //    {
    //        Animation@ anim = barracks_weapons.addAnimation("default", 0, false);
    //        anim.AddFrame(6);
    //        barracks_weapons.SetVisible(false);
    //        barracks_weapons.SetOffset(barracks_offset + Vec2f(-3.0f, 9.0f));
    //        barracks_weapons.SetRelativeZ(-50.0);
    //    }
//
    //    CSpriteLayer@ barracks_bench = this.addSpriteLayer("barracks_bench", filename , 32, 32, blob_team, blob_skin);
//
    //    if (barracks_bench !is null)
    //    {
    //        Animation@ anim = barracks_bench.addAnimation("default", 0, false);
    //        anim.AddFrame(14);
    //        barracks_bench.SetVisible(false);
    //        barracks_bench.SetOffset(barracks_offset + Vec2f(24.0f, 8.0f));
    //        barracks_bench.SetRelativeZ(-50.0);
    //    }
   // }
    blob.set_u8("old_upgrade_level", 100); //hack, makes client sync frames
    onTick(this);   //update to get offsets etc working
}

void onTick(CSprite@ this)
{
    int gametime = getGameTime();
    this.SetZ(-50.0f);   // push to background

    //tower anim

    if ((gametime) % 10 == 0)
    {
        CBlob@ blob = this.getBlob();
        u8 old_upgrade_level = blob.get_u8("old_upgrade_level_sprite");
        u8 upgrade_level = blob.get_u8("upgrade_level");

        if (upgrade_level != old_upgrade_level)
        {
            blob.set_u8("old_upgrade_level_sprite", upgrade_level);
            SetupLayers(this, upgrade_level, false);
        }
        else
        {
            f32 health = blob.getHealth();
            f32 oldhealth = blob.get_f32("warbase old health"); //prevent potential collisions
            f32 defaulthp = blob.getInitialHealth();

            if (health != oldhealth)
            {
                if (health < defaulthp * 0.6f)
                {
                    SetupLayers(this, upgrade_level, true);
                }
                else
                {
                    SetupLayers(this, upgrade_level, false);
                }

                blob.set_f32("warbase old health", health);
            }

            if (upgrade_level < 2)
            {
                SetupUpgradeTable(this);
            }
        }
    }
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    CBlob@ localBlob = getLocalPlayerBlob();
    Vec2f upgradePos(blob.isFacingLeft() ? -upgradeButtonPos.x : upgradeButtonPos.x, upgradeButtonPos.y);
    upgradePos += blob.getPosition();

    if (localBlob !is null && (
                ((localBlob.getPosition() - upgradePos).Length() < localBlob.getRadius() + 64.0f) &&
                (getHUD().hasButtons() && !getHUD().hasMenus())))
    {
        Vec2f pos2d = blob.getScreenPos();
        const uint level = blob.get_u8("upgrade_level");
        CCamera@ camera = getCamera();
        f32 zoom = camera.targetDistance;
        int top = pos2d.y + zoom * blob.getHeight() + 160.0f;
        const uint margin = 7;
        Vec2f dim;
        string label = "Level 10000";
        GUI::SetFont("menu");
        GUI::GetTextDimensions(label , dim);
        dim.x += 2.0f * margin;
        dim.y += 2.0f * margin;
        dim.y *= 2.0f;
        f32 leftX = -dim.x;
        int current = 0, max = 0;

        // DRAW UPGRADE LEVELS

        if (level == 0)
        {
            current = blob.get_u16("wood");
            max = blob.get_u16("upgrade_1_cost");
        }
        else if (level == 1)
        {
            current = blob.get_u16("wood") - blob.get_u16("upgrade_1_cost");
            max = blob.get_u16("upgrade_2_cost");
        }

        if (level < 2)
        {
            for (uint i = 0; i < 3; i++)
            {
                label = "Level " + (i + 1);
                Vec2f upperleft(pos2d.x - dim.x / 2 + leftX, top - 2 * dim.y);
                Vec2f lowerright(pos2d.x + dim.x / 2 + leftX, top - dim.y);
                bool isNextLevel = (i == level + 1);
                f32 progress = 0.0f;

                if (i == 0)
                {
                    progress = 1.0f;
                }
                else if (isNextLevel)
                {
                    progress = float(current) / float(max);
                }
                else if (i <= level)
                {
                    progress = 1.0f;
                }

                GUI::DrawProgressBar(upperleft, lowerright, progress);
                int base_frame = 10 + i;
                GUI::DrawIcon("Rules/WAR/WarGUI.png", base_frame, Vec2f(48, 32), upperleft + Vec2f(0, 0), 1.0f, blob.getTeamNum());
                GUI::DrawText(label, Vec2f(upperleft.x + margin, upperleft.y + margin), level == i ? SColor(255, 255, 255, 255) : SColor(255, 120, 120, 120));

                if (isNextLevel)
                {
                    GUI::DrawText("" + current + " / " + max, Vec2f(upperleft.x + margin, upperleft.y + dim.y / 2.0f + margin), color_white);
                }

                leftX += dim.x + 2.0f;
            }
        }

    }  // E
}

void SetupLayers(CSprite@ this, u8 upgrade_level, bool damaged)
{
    Vec2f cap_offset = Vec2f(0, -24);
    CSpriteLayer@ tower_cap = this.getSpriteLayer("tower_cap");

    if (tower_cap !is null)
    {
        tower_cap.SetOffset(cap_offset + Vec2f(0.0f, (-16.0f * upgrade_level)));
        tower_cap.SetRelativeZ(-10.0);
        tower_cap.animation.frame = damaged ? 1 : 0;
    }

    Vec2f flag_offset = Vec2f(-4, -16 + (-8 * s32(upgrade_level)));
    CSpriteLayer@ tower_flagpole = this.getSpriteLayer("tower_flagpole");

    if (tower_flagpole !is null)
    {
        tower_flagpole.SetOffset(cap_offset + flag_offset + Vec2f(16.0f, (-16.0f * upgrade_level)));
        tower_flagpole.SetRelativeZ(-10.0);
    }

    CSpriteLayer@ tower_flag = this.getSpriteLayer("tower_flag");

    if (tower_flag !is null)
    {
        tower_flag.SetOffset(cap_offset + flag_offset + Vec2f(28.0f, -4 + (-16.0f * upgrade_level)));
        tower_flag.SetRelativeZ(-11.0);
    }

    CSpriteLayer@ tower = this.getSpriteLayer("tower");

    if (tower !is null)
    {
        if (upgrade_level > 0)
        {
            tower.SetVisible(true);
            tower.SetOffset(cap_offset + Vec2f(0.0f, 32.0f + (-16.0f * upgrade_level)));
            tower.SetRelativeZ(-10.0);
            tower.animation.frame = (upgrade_level - 1) + (damaged ? 2 : 0);
        }
        else
        {
            tower.SetVisible(false);
        }
    }

    //barracks anim
    {
        CSpriteLayer@ barracks_unbuilt = this.getSpriteLayer("barracks_unbuilt");

        if (barracks_unbuilt !is null)
        {
            if (upgrade_level == 0)
            {
                barracks_unbuilt.SetVisible(true);
            }
            else
            {
                barracks_unbuilt.SetVisible(false);
            }
        }

        CSpriteLayer@ barracks = this.getSpriteLayer("barracks");

        if (barracks !is null)
        {
            if (upgrade_level > 0)
            {
                barracks.SetVisible(true);
                barracks.animation.frame = damaged ? 1 : 0;
            }
            else
            {
                barracks.SetVisible(false);
            }
        }

        CSpriteLayer@ barracks_weapons = this.getSpriteLayer("barracks_weapons");

        if (barracks_weapons !is null)
        {
            if (upgrade_level > 0)
            {
                barracks_weapons.SetVisible(true);
            }
            else
            {
                barracks_weapons.SetVisible(false);
            }
        }

        CSpriteLayer@ barracks_bench = this.getSpriteLayer("barracks_bench");

        if (barracks_bench !is null)
        {
            if (upgrade_level > 1)
            {
                barracks_bench.SetVisible(true);
            }
            else
            {
                barracks_bench.SetVisible(false);
            }
        }
    }

    //upgrade table anim
    if (upgrade_level < 2)
    {
        SetupUpgradeTable(this);
    }

}

void SetupUpgradeTable(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    u8 upgrade_level = blob.get_u8("upgrade_level");

    u16 wood = blob.get_u16("wood");
    u16 oldwood = blob.get_u16("old wood");

    if (oldwood != wood)
    {
        f32 wood_amount = woodForUpgrade(blob);
        f32 upgrade_amount = upgradeAmount(blob, upgrade_level);

        CSpriteLayer@ table = this.getSpriteLayer("upgrade_table");
        if (table !is null)
        {
            if (wood_amount > 0)
            {
                table.SetVisible(true);
                table.animation.frame = Maths::Floor(wood_amount / upgrade_amount * 2.9f);
            }
            else
            {
                table.SetVisible(false);
            }
        }

        blob.set_u16("old wood", wood);
    }
}