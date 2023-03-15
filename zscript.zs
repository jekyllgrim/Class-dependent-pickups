version "4.5.0"

/*
	This item appears as different items for different classes. They will actually pick different items when they pick this up.
	The appearance (scale, sprite, frame), as well as pickupmessage and pickupsound are local. The actual items are synced,
	so this is multiplayer-compatible. Of course, when one player picks it up, it'll disappear for everyone.
	
	Two arrays are used to match player classes with items. The arrays MUST BE THE SAME SIZE (so, if you want the same items for
	different classes, you'll have to duplicate the entries in CBP_items[]).
*/

Class ClassBasedPickup : Inventory {
	protected Class<Inventory> finalPickup;
	
	//fill this array with player class names:
	static const Class<PlayerPawn> CBP_classes[] = {
		'DoomPlayerTest1',
		'DoomPlayerTest2'
	};
	
	//fill this array with item class names:
	static const Class<Inventory> CBP_items[] = {
		'Shell',
		'Shotgun'
	};
	
	override void PostBeginPlay() {
		super.PostBeginPlay();
		let pclass = players[consoleplayer].mo.GetClassName();
		if (CBP_classes.Size() != CBP_items.Size()) {
			destroy();
			return;
		}
		for (int i = 0; i < CBP_classes.Size(); i++) {
			if (pclass != CBP_classes[i])
				continue;
			let def = GetDefaultByType(CBP_items[i]);
			pickupsound = def.pickupsound;
			sprite = def.SpawnState.sprite;
			frame = def.SpawnState.frame;
			scale = def.scale;
			A_SetRenderstyle(def.alpha, def.GetRenderstyle());
			break;
		}
	}	
	
	override string PickupMessage () {
		if(finalPickup) 
			return GetDefaultByType(finalPickup).PickupMsg;
		return "";
	}
	
	override bool TryPickup (in out Actor toucher) {
		if (!toucher || !(toucher is "PlayerPawn"))
			return false;
		let pclass = toucher.GetClassName();
		for (int i = 0; i < CBP_classes.Size(); i++) {
			if (pclass != CBP_classes[i])
				continue;
			finalPickup = CBP_items[i];
			let itm = Inventory(Spawn(finalPickup, toucher.pos));
			if (itm && itm.CallTryPickup(toucher)) {
				GoAwayAndDie();
				return true;
				break;
			}
		}
		return false;
	}
	
	States {
	Spawn:
		#### # -1;
		stop;
	}
}

//test player classes:

Class DoomPlayerTest1 : DoomPlayer {
	Default {
		yscale 0.65;
		Player.ViewHeight 30;
		Player.AttackZOffset 0;
		Player.DisplayName "Shortie";
	}
}

Class DoomPlayerTest2 : DoomPlayer {
	Default {
		yscale 1.2;
		Player.ViewHeight 52;
		Player.AttackZOffset 20;
		Player.DisplayName "Beanpole";
	}
}