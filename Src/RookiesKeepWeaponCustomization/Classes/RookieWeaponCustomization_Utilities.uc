// FILE: RookieWeaponCustomization_Utilities.uc
//
// Handler for adding and removing the component

class RookieWeaponCustomization_Utilities extends Object;

// make sure every rookie has a component
static function CheckAllSoldiers()
{
	local XComGameState_HeadquartersXCom XHQ;
	local array<XComGameState_Unit> Soldiers;
	local XComGameState_Unit Unit;
	local XComGameState NewGameState;

	XHQ = `XCOMHQ;
	Soldiers = XHQ.GetSoldiers();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Saving weapon customization");

	foreach Soldiers(Unit)
	{
		// we only care about rookies
		if(0 == Unit.GetRank())
		{
			AttachToUnit(Unit, NewGameState);
		}
	}
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}

// initializes the component to store weapon customization
static function AttachToUnit(XComGameState_Unit Unit, XComGameState NewGameState)
{
	local XComGameState_Item PrimaryWeapon;
	local XComGameState_Unit_TrackWeaponCustomization TWC;
	local XComGameState_Unit UpdatedUnit;

	PrimaryWeapon = Unit.GetItemInSlot(eInvSlot_PrimaryWeapon);
			
	TWC = XComGameState_Unit_TrackWeaponCustomization(Unit.FindComponentObject(class'XComGameState_Unit_TrackWeaponCustomization'));
	
	// we are only interested in soldiers that don't already have this
	if(none != TWC)
	{
		return;
	}

	TWC = XComGameState_Unit_TrackWeaponCustomization(NewGameState.CreateStateObject(class'XComGameState_Unit_TrackWeaponCustomization'));
	TWC.SetAppearance(PrimaryWeapon);
	UpdatedUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));

	UpdatedUnit.AddComponentObject(TWC);
	NewGameState.AddStateObject(UpdatedUnit);
	NewGameState.AddStateObject(TWC);

}


static function RestoreCustomization(XComGameState_Unit Unit)
{
	local XComGameState NewGameState;
	local XComGameState_Item PrimaryWeapon, UpdatedWeapon;
	local XComGameState_Unit_TrackWeaponCustomization TWCComponent, UpdatedComponent;
	local XComGameState_Unit UpdatedUnit;

	TWCComponent = XComGameState_Unit_TrackWeaponCustomization(Unit.FindComponentObject(class'XComGameState_Unit_TrackWeaponCustomization'));
	
	// no saved customization
	if(none == TWCComponent)
	{
		return;
	}

	PrimaryWeapon = Unit.GetItemInSlot(eInvSlot_PrimaryWeapon);
	
	// sanity check
	if(none == PrimaryWeapon)
	{
		return;
	}

	// create updated state objects
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Restoring weapon customization");

	UpdatedUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
	
	UpdatedWeapon = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', PrimaryWeapon.ObjectID));
	
	UpdatedComponent = XComGameState_Unit_TrackWeaponCustomization(NewGameState.CreateStateObject(
						class'XComGameState_Unit_TrackWeaponCustomization', TWCComponent.ObjectID));

	UpdatedWeapon.WeaponAppearance.iWeaponTint = TWCComponent.WeaponAppearance.iWeaponTint;
	UpdatedWeapon.WeaponAppearance.iWeaponDeco = TWCComponent.WeaponAppearance.iWeaponDeco;
	UpdatedWeapon.WeaponAppearance.nmWeaponPattern = TWCComponent.WeaponAppearance.nmWeaponPattern;

	// get rid of the component, it's not needed anymore
	UpdatedUnit.RemoveComponentObject(UpdatedComponent);

	NewGameState.AddStateObject(UpdatedComponent);
	NewGameState.AddStateObject(UpdatedWeapon);
	NewGameState.AddStateObject(UpdatedUnit);

	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}