// FILE: RWC_WeaponUpgradeListener.uc
//
// Update stored customization with changes made via UIArmory_WeaponUpgrade

class RWC_WeaponUpgradeListener extends UIScreenListener;

// trigger after any customization changes were submitted
event OnRemoved(UIScreen Screen)
{
	local UIArmory_WeaponUpgrade UpgradeScreen;
	local XComGameStateHistory History;
	local XComGameState_Item Weapon;
	local XComGameState_Unit WeaponOwner;

	if(none == ScreenClass)
	{
		ScreenClass = class'X2DownloadableContentInfo_RookiesKeepWeaponCustomization'.static.DetermineUI(class'UIArmory_WeaponUpgrade');
		if(Screen.class != ScreenClass)
		{
			return;
		}
	}

	UpgradeScreen = UIArmory_WeaponUpgrade(Screen);

	if(none == UpgradeScreen)
	{
		return;
	}

	History = `XCOMHISTORY;
	Weapon = XComGameState_Item(History.GetGameStateForObjectID(UpgradeScreen.WeaponRef.ObjectID));
	WeaponOwner = XComGameState_Unit(History.GetGameStateForObjectID(Weapon.OwnerStateObject.ObjectID));

	if(WeaponOwner.GetRank() == 0)
	{
		class'RookieWeaponCustomization_Utilities'.static.UpdateCustomization(WeaponOwner);
	}
}


defaultproperties
{
	ScreenClass = none; // UIArmory_WeaponUpgrade;
}