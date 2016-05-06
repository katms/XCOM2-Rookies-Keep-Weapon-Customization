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

	// if for whatever reason the rookie doesn't have a weapon don't try to read it
	if(none == PrimaryWeapon)
	{
		return;
	}

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

// update saved customization when a weapon is recolored since the component was created
static function UpdateCustomization(XComGameState_Unit Unit)
{
	local XComGameState NewGameState;
	local XComGameState_Unit_TrackWeaponCustomization ComponentState, UpdatedComponent;
	local XComGameState_Item Weapon; // does not need to be submitted

	// not creating a copy of Unit since no changes will be made to it

	if(Unit == none)
	{
		return;
	}

	Weapon = Unit.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if(none == Weapon)
	{
		return;
	}

	ComponentState = XComGameState_Unit_TrackWeaponCustomization(Unit.FindComponentObject(class'XComGameState_Unit_TrackWeaponCustomization'));
	
	// this is the shortest way to initialize the component
	if(none == ComponentState)
	{
		CheckAllSoldiers();
		return;
	}
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating weapon customization");

	
	UpdatedComponent = XComGameState_Unit_TrackWeaponCustomization(NewGameState.CreateStateObject(
						class'XComGameState_Unit_TrackWeaponCustomization', ComponentState.ObjectID));

	UpdatedComponent.SetAppearance(Weapon);

	NewGameState.AddStateObject(UpdatedComponent);
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
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

	//only overwrite if the saved settings aren't blank
	if(TWCComponent.WeaponAppearance.iWeaponTint != INDEX_NONE)
	{
		UpdatedWeapon.WeaponAppearance.iWeaponTint = TWCComponent.WeaponAppearance.iWeaponTint;
	}

	if(TWCComponent.WeaponAppearance.iWeaponDeco != INDEX_NONE)
	{
		UpdatedWeapon.WeaponAppearance.iWeaponDeco = TWCComponent.WeaponAppearance.iWeaponDeco;
	}
	
	if(TWCComponent.WeaponAppearance.nmWeaponPattern != '')
	{
		UpdatedWeapon.WeaponAppearance.nmWeaponPattern = TWCComponent.WeaponAppearance.nmWeaponPattern;
	}

	// get rid of the component, it's not needed anymore
	UpdatedUnit.RemoveComponentObject(UpdatedComponent);

	NewGameState.AddStateObject(UpdatedComponent);
	NewGameState.AddStateObject(UpdatedWeapon);
	NewGameState.AddStateObject(UpdatedUnit);

	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}