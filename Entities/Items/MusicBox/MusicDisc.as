// A script by TFlippy, and used by Char. thanks TFlippy!

const string[] names =
{
	"We Come Together",
	"Bad Kingdom",
	"Clubbed To Death",
	"Kiss From A Rose",
	"Skeleton",
	"Uprocking Beats",
	"Untrust Us",
	"Show Yourself",
	"Iron",
	"Until The World Goes Cold",
	"Tarantula",
	"Gooey",
	"None Shall Pass",
	"Lone Digger",
	"blank"

};

void onInit(CBlob@ this)
{
	this.addCommandID("set");
	this.set_u8("trackID", XORRandom(14)); // Temporary 
	
	SetTrack(this, this.get_u8("trackID"));
}

void SetTrack(CBlob@ this, u8 inIndex)
{
	if (inIndex > names.length - 1) return;

	this.set_u8("trackID", inIndex);
	this.getSprite().SetAnimation("track" + inIndex);
	this.setInventoryName("Gramophone Record (" + names[inIndex] + ")");
	
	// print("Current: " + this.getSprite().animation.name + "; Should be: " + "track" + inIndex);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	// print("cmd");

	if (getNet().isClient())
	{
		if (cmd == this.getCommandID("set"))
		{
			// print("set");
			SetTrack(this, params.read_u8());
		}
	}
}