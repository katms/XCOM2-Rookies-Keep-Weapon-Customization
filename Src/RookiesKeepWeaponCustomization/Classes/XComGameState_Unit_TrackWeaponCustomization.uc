//  FILE:   XComGameState_Unit_TrackWeaponCustomization.uc                                    
//           
//	Stores weapon customization so it won't be lost when rookies gain a class that doesn't carry an assault rifle by default
//  Attached to the soldier, not the weapon, so we don't have to worry about where the old item ends up


class XComGameState_Unit_TrackWeaponCustomization extends XComGameState_BaseObject;

var TWeaponAppearance WeaponAppearance;
/*
var int iWeaponTint;
var int iWeaponDeco;
var name nmWeaponPattern;
*/

// set appearance
function SetAppearance(XComGameState_Item PrimaryWeapon)
{
	WeaponAppearance.iWeaponTint = PrimaryWeapon.WeaponAppearance.iWeaponTint;
	WeaponAppearance.iWeaponDeco = PrimaryWeapon.WeaponAppearance.iWeaponDeco;
	WeaponAppearance.nmWeaponPattern = PrimaryWeapon.WeaponAppearance.nmWeaponPattern;
}