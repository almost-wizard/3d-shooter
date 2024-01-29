extends CanvasLayer


func _on_weapon_manager_update_ammo(_ammo):
	var CurrentAmmoLabel = $VBoxContainer/HBoxContainer2/CurrentAmmo
	CurrentAmmoLabel.set_text(str(_ammo[0]) + &"/" + str(_ammo[1]))


func _on_weapon_manager_update_weapon_stack(_weapon_stack):
	var WeaponStackLabel = $VBoxContainer/HBoxContainer3/WeaponStack
	WeaponStackLabel.set_text(&"")
	for i in _weapon_stack:
		WeaponStackLabel.text += &"\n" + i


func _on_weapon_manager_weapon_change(_weapon_name):
	var CurrentWeaponLabel = $VBoxContainer/HBoxContainer1/CurrentWeapon
	CurrentWeaponLabel.set_text(_weapon_name)
