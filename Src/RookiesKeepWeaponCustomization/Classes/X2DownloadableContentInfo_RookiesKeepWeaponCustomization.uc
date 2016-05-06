//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_RookiesKeepWeaponCustomization.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_RookiesKeepWeaponCustomization extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	class'RookieWeaponCustomization_Utilities'.static.CheckAllSoldiers();
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
	class'RookieWeaponCustomization_Utilities'.static.CheckAllSoldiers(StartState);
}


// determine UI class for screen listeners at run time
// probably not the most logical place to put this, but it avoids name conflicts
static function class<UIScreen> DetermineUI(class<UIScreen> ClassType)
{
	local Engine XEng;
	local int i;
	local class<UIScreen> ModClass;

	ModClass = none;

	XEng = `XENGINE;
	i = XEng.ModClassOverrides.find('BaseGameClass', name(string(ClassType)));
	
	// if there exists an override for this UI
	if(i != INDEX_NONE)
	{
		// returns the correct class even if multiple overrides were configured
		ModClass = class<UIScreen>(XEng.GetModReplacementClass(ClassType));
	}

	// if ModClass doesn't exist (returns none or was never reassigned), return the base class
	return (none == ModClass) ? ClassType : ModClass;
}