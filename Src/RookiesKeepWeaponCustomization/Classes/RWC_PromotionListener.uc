// FILE: RWC_PromotionListener.uc
//
// Finds new squaddies and restores weapon customization

class RWC_PromotionListener extends UIScreenListener;


event OnInit(UIScreen Screen)
{
	local UIArmory_Promotion AP;
	local XComGameState_Unit Unit;

	if(none == ScreenClass)
	{
		ScreenClass = class'X2DownloadableContentInfo_RookiesKeepWeaponCustomization'.static.DetermineUI(class'UIArmory_Promotion');
		if(Screen.class != ScreenClass)
		{
			return;
		}
	}

	AP = UIArmory_Promotion(Screen);

	if(none == AP)
	{
		return;
	}

	Unit = AP.GetUnit();

	// new squaddie
	if(1 == Unit.GetRank())
	{
		class'RookieWeaponCustomization_Utilities'.static.RestoreCustomization(Unit);
		// refresh weapon pawn so it displays the new customization
		AP.LoadSoldierEquipment();
	}
}


defaultProperties
{
	ScreenClass = none; // UIArmory_Promotion;
}