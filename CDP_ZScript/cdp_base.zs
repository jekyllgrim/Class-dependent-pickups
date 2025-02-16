class JGP_ItemClassPair play
{
	class<Actor> toucherClass;
	class<Inventory> itemClass;

	static JGP_ItemClassPair Create(Name toucherClassName, Name itemClassName)
	{
		class<Actor> tcls = toucherClassName;
		class<Inventory> icls = itemClassName;
		if (!tcls || !icls)
		{
			return null;
		}
		let data = new('JGP_ItemClassPair');
		if (data)
		{
			data.toucherClass = tcls;
			data.itemClass = icls;
		}
		return data;
	}
}

class JGP_ClassDependentPickup : Inventory
{
	string ClassPairs;
	property ClassPairs : ClassPairs;
	protected array<JGP_ItemClassPair> classPairsData;
	protected array<Inventory> spawnedItems;

	Default
	{
		+SYNCHRONIZED
		+DONTBLAST
		FloatBobPhase 0;
	}
	
	static JGP_ClassDependentPickup Create(vector3 pos, string pairs)
	{
		
		let cdp = JGP_ClassDependentPickup(Actor.Spawn("JGP_ClassDependentPickup", pos));
		if (cdp)
		{
			cdp.ClassPairs = pairs;
		}
		return cdp;
	}
	
	void FillClassPairs()
	{
		if (classPairsData.Size() > 0)
			return;

		if (ClassPairs == "")
		{
			ThrowAbortException("\cgCDP error:\c- Cannot spawn a class-based pickup without a defined list of class pairs");
			return;
		}

		array<string> pairs;
		ClassPairs.Split(pairs, "|", TOK_SKIPEMPTY);
		if (pairs.Size() < 1)
		{
			ThrowAbortException("\cgCDP error:\c- \cd%s\c- is not a valid list of class pairs.\nThe correct format is \cd\"FirstPlayerClass:FirstItemClass|SecondPlayerClass:SecondItemClass|ThirdPlayerClass:ThirdItemClass\"\c-\nand so on", ClassPairs);
			return;
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
			let data = JGP_ItemClassPair.Create(str[0], str[1]);
			if (data)
			{
				classPairsData.Push(data);
			}
		}
	}
	
	class<Inventory> GetItemByClass(class<Actor> toucherClass)
	{
		foreach (data : classPairsData)
		{
			if (data && data.toucherClass == toucherClass)
			{
				return data.itemClass;
			}
		}
		return null;
	}
	
	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		FillClassPairs();
		foreach (data : classPairsData)
		{
			let itm = SpawnClassPickup(data.toucherClass);
			if (itm)
			{
				itm.bSPECIAL = false;
				if (data.toucherClass != players[consoleplayer].mo.GetClass())
				{
					itm.renderRequired = -1;
				}
				spawnedItems.Push(itm);
			}
		}
	}

	Inventory SpawnClassPickup(class<Actor> toucherClass)
	{
		class<Inventory> itmcls = GetItemByClass(toucherClass);
		if (!itmcls) return null;
		
		let itm = Inventory(Spawn(itmcls, pos));
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
		itm.bNEVERRESPAWN = true;
		return itm;
	}

	override void Touch(Actor toucher)
	{
		if (!toucher)
			return;
		
		class<Inventory> clsToGive = GetItemByClass(toucher.GetClass());
		if (!clsToGive)
			return;
		
		bool picked;
		// Check if any of the defined player classes
		// match this item class:
		foreach(itm : spawnedItems)
		{
			// If so, try picking it up:
			if (itm.GetClass() == clsToGive)
			{
				itm.bSpecial = true;
				itm.Touch(toucher);
				picked = !itm || itm.bNoSector || itm.owner;
				// Picked successfully - remove the given item
				// from the array and prepare to destroy this pickup:
				if (picked)
				{
					let id = spawnedItems.Find(itm);
					if (id < spawnedItems.Size())
					{
						spawnedItems.Delete(id);
					}
					GoAwayAndDie();
				}
				// Otherwise unset bSpecial on the item again:
				else
				{
					itm.bSpecial = false;
				}
				break;
			}
		}
		// If picked up successfully, destroy all other items:
		if (picked)
		{
			foreach (itm : spawnedItems)
			{
				if (itm)
				{
					itm.Destroy();
				}
			}
		}
	}
	
	// This is only used for direct giving,
	// since Touch() never calls this:
	override bool TryPickup (in out Actor toucher)
	{
		if (!toucher)
			return false;
		
		FillClassPairs();
		class<Inventory> clsToGive = GetItemByClass(toucher.GetClass());
		if (!clsToGive)
			return false;
		
		let itm = Inventory(Spawn(clsToGive));
		if (itm)
		{
			if (itm.CallTryPickup(toucher))
			{
				Destroy();
				return true;
			}
			else
			{
				itm.Destroy();
			}
		}
		return false;
	}
	
	States {
	Spawn:
		TNT1 A -1;
		stop;
	}
}