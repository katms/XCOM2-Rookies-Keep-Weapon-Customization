// FILE: RWC_CustomizeMenuListener.uc
//
// Update customization changes made via UICustomize_Menu

class RWC_CustomizeMenuListener extends UIScreenListener;

// wait until any changes were submitted
event OnRemoved(UIScreen Screen)
{
	local UICustomize_Menu Menu;
	local XComGameState_Unit Unit;

	if(none == ScreenClass)
	{
		ScreenClass = class'X2DownloadableContentInfo_RookiesKeepWeaponCustomization'.static.DetermineUI(class'UICustomize_Menu');
		if(Screen.class != ScreenClass)
		{
			return;
		}
	}

	Menu = UICustomize_Menu(Screen);

	if(none == Menu)
	{
		return;
	}

	Unit = Menu.GetUnit();

	if(0 == Unit.GetRank())
	{
		class'RookieWeaponCustomization_Utilities'.static.UpdateCustomization(Unit);
	}
}

defaultproperties
{
	ScreenClass = none; //UICustomize_Menu
}