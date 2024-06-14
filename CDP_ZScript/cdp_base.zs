class JGP_ClassDependentPickup : Inventory
{
	string ClassPairs;
	property ClassPairs : ClassPairs;
	
	protected array<string> classPairsList;
	
	static JGP_ClassDependentPickup Create(vector3 pos, string pairs)
	{
		
		let cdp = JGP_ClassDependentPickup(Actor.Spawn("JGP_ClassDependentPickup", pos));
		if (cdp)
		{
			cdp.ClassPairs = pairs;
		}
		return cdp;
	}
	
	bool FillClassPairs(string list)
	{
		array<string> pairs;
		list.Split(pairs, "|", TOK_SKIPEMPTY);
		if (pairs.Size() < 1)
		{
			console.printf("\cgCDP error:\c- \cd%s\c- is not a valid list of class pairs.\nThe correct format is \cd\"FirstPlayerClass:FirstItemClass|SecondPlayerClass:SecondItemClass|ThirdPlayerClass:ThirdItemClass\"\c-\nand so on", list);
			return false;
		}
		
		for (int i = 0; i < pairs.Size(); i++)
		{
			array<string> str;
			pairs[i].Split(str, ":", TOK_SKIPEMPTY);
			if (str.Size() != 2)
			{
				console.printf("\cgCDP error:\c- \cd%s\c- is not a valid class pair.\nUse \cd\"PlayerClassName:ItemClassName\"\c- to pair player classes and item classes", pairs[i]);
				continue;
			}
			classPairsList.Push(pairs[i]);
		}
		return (classPairsList.Size() >= 1);
	}
	
	class<Inventory> GetItemByClass(name pclsname)
	{
		if (classPairsList.Size() <= 0)
			return null;
			
		for (int i = 0; i < classPairsList.Size(); i++)
		{
			array<string> str;
			classPairsList[i].Split(str, ":", TOK_SKIPEMPTY);
			if (str.Size() != 2)
				continue;
			
			if (pclsname != str[0])
				continue;
			
			class<Inventory> itm = str[1];
			if (!itm)
			{
				console.printf("\cgCDP error:\c- \cd%s\c- is not a valid Inventory class", str[1]);
				return null;
				break;
			}
			
			return itm;
		}
		return null;
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		
		if (classPairsList.Size() <= 0)
		{
			if (ClassPairs == "")
			{
				console.printf("\cgCDP error:\c- Cannot spawn a class-based pickup without a defined list of class pairs");
				Destroy();
				return;
			}
			
			if (!FillClassPairs(ClassPairs))
			{
				Destroy();
				return;
			}
		}
	}
	
	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		
		class<Inventory> itmcls = GetItemByClass(players[consoleplayer].mo.GetClassName());
		if (itmcls)
		{			
			let def = GetDefaultByType(itmcls);
			sprite = def.SpawnState.sprite;
			frame = def.SpawnState.frame;
			scale = def.scale;
			spriteOffset = def.spriteOffset;
			spriteRotation = def.spriteRotation;
			bFloatBob = def.bFloatBob;
			floatBobPhase = def.floatBobPhase;
			A_SetRenderstyle(def.alpha, def.GetRenderstyle());
		}
	}

	Inventory SpawnClassPickup(Actor toucher)
	{
		class<Inventory> itmcls = GetItemByClass(toucher.GetClassName());
		if (!itmcls) return null;
		
		let itm = Inventory(Spawn(itmcls, toucher.pos));
		if (!itm) return null;
			
		itm.SpawnAngle = SpawnAngle;
		itm.Angle		= Angle;
		itm.Pitch		= Pitch;
		itm.Roll		= Roll;
		itm.SpawnPoint = SpawnPoint;
		itm.special    = special;
		itm.args[0]    = args[0];
		itm.args[1]    = args[1];
		itm.args[2]    = args[2];
		itm.args[3]    = args[3];
		itm.args[4]    = args[4];
		itm.special1   = special1;
		itm.special2   = special2;
		itm.SpawnFlags = SpawnFlags & ~MTF_SECRET;
		itm.HandleSpawnFlags();
		itm.SpawnFlags = SpawnFlags;
		itm.bCountSecret = SpawnFlags & MTF_SECRET;
		itm.ChangeTid(tid);
		itm.Vel	= Vel;
		itm.master = master;
		itm.target = target;
		itm.tracer = tracer;
		return itm;
	}

	override void Touch(Actor toucher)
	{
		if (!toucher || !toucher.player)
			return;

		let itm = SpawnClassPickup(toucher);
		if (!itm)
		{
			return;
		}

		itm.Touch(toucher);
		if (!itm || itm.bNoSector || itm.owner)
		{
			GoAwayAndDie();
		}
		else
		{
			itm.Destroy();
		}
	}
	
	override bool TryPickup (in out Actor toucher)
	{
		if (!toucher)
			return false;

		let itm = SpawnClassPickup(toucher);
		if (!itm)
		{
			Destroy();
			return false;
		}

		bool picked = itm.CallTryPickup(toucher);
		if (!picked && itm && !itm.bNoSector && !itm.owner)
		{
			itm.Destroy();
		}
		Destroy();
		return false;
	}
	
	States {
	Spawn:
		TNT1 A -1;
		stop;
	}
}