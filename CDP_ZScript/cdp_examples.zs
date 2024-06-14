
// Example pickup:

class TestCDP : JGP_ClassDependentPickup
{
	Default
	{
		JGP_ClassDependentPickup.ClassPairs "DoomPlayerTest1:Shotgun|DoomPlayerTest2:Chaingun";
	}
}

// Example player classes:
class DoomPlayerTest1 : DoomPlayer
{
	Default
	{
		yscale 0.65;
		Player.ViewHeight 30;
		Player.AttackZOffset 0;
		Player.DisplayName "Shortie";
	}
}

class DoomPlayerTest2 : DoomPlayer
{
	Default
	{
		yscale 1.2;
		Player.ViewHeight 52;
		Player.AttackZOffset 20;
		Player.DisplayName "Beanpole";
	}
}