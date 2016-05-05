// FILE: RWC_ArmoryMainMenuListener.uc
//
// Clean up RWC components after the owner is dismissed

class RWC_ArmoryMainMenuListener extends UIScreenListener;

event OnRemoved(UIScreen Screen)
{
	if(none == ScreenClass)
	{
		ScreenClass = class'X2DownloadableContentInfo_RookiesKeepWeaponCustomization'.static.DetermineUI(class'UIArmory_MainMenu');
		if(Screen.class != ScreenClass)
		{
			return;
		}
	}

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

defaultproperties
{
	ScreenClass = none; //UIArmory_MainMenu
}