// FILE: RWC_NewCrewListener.uc
// Event listener for NewCrewNotification, for crew added after campaign start/mod installation

class RWC_NewCrewListener extends UIStrategyScreenListener;

event OnInit(UIScreen Screen)
{
	local Object SelfObj;
	// since crew join in the strategy layer
	if(IsInStrategy())
	{
		SelfObj = self;
		`XEVENTMGR.RegisterForEvent(selfObj, 'NewCrewNotification', UpdateCrew, ELD_OnStateSubmitted,,,true);
	}
}

// callback
function EventListenerReturn UpdateCrew(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	class'RookieWeaponCustomization_Utilities'.static.CheckAllSoldiers();
	
	return ELR_NoInterrupt;
}