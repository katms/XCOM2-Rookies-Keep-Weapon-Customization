// FILE: RWC_PreTacticalCleanup.uc
//
// Clean up RWC components after the owner is dismissed
// since there are several strategy UIs soldiers can be dismissed from,
// and cleanup has to be done before the end of the next tactical mission, 
// call it on the last pre-tactical UI
//
// And so I don't have to come up with a new screen listener for this, doubles as an event listener for new crew

class RWC_PreTacticalCleanup extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	if(none == ScreenClass)
	{
		ScreenClass = class'X2DownloadableContentInfo_RookiesKeepWeaponCustomization'.static.DetermineUI(class'UISkyrangerArrives');
		if(Screen.class != ScreenClass)
		{
			return;
		}
	}
	SelfObj = self;
	`XEVENTMGR.RegisterForEvent(selfObj, 'NewCrewNotification', UpdateCrew, ELD_OnStateSubmitted,,,true);

	Cleanup();
}

function Cleanup()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState, UpdatedUnit;
	local XComGameState_Unit_TrackWeaponCustomization Component, UpdatedComponent;
	
	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Cleanup rookie customization");
	foreach History.IterateByClassType(class'XComGameState_Unit_TrackWeaponCustomization', Component,, true)
	{
		if(Component.OwningObjectID > 0)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(Component.OwningObjectID));

			// owner cannot be found
			if(none == UnitState)
			{
				NewGameState.RemoveStateObject(Component.ObjectID);
			}

			// owner is flagged for removal
			else if(UnitState.bRemoved)
			{
				UpdatedUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
				UpdatedComponent = XComGameState_Unit_TrackWeaponCustomization(NewGameState.CreateStateObject(
														class'XComGameState_Unit_TrackWeaponCustomization', Component.ObjectID));

				NewGameState.RemoveStateObject(UpdatedComponent.ObjectID);
				UpdatedUnit.RemoveComponentObject(UpdatedComponent);
				NewGameState.AddStateObject(UpdatedComponent);
				NewGameState.AddStateObject(UpdatedUnit);
			}
		}
	}

	History.AddGameStateToHistory(NewGameState);
}

function EventListenerReturn UpdateCrew(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	class'RookieWeaponCustomization_Utilities'.static.CheckAllSoldiers();
	
	return ELR_NoInterrupt;
}

defaultproperties
{
	ScreenClass = none; //UISkyrangerArrives, which is unlikely to be overridded but whatever
}