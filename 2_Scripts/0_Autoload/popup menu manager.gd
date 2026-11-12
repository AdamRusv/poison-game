extends Node

var backgroundRef : PackedScene = preload("res://1_Scenes/1_Objects/0_Popup Menus/0 popup menu background.tscn")

#MENUS:
var creditsMenuRef : PackedScene = preload("res://1_Scenes/1_Objects/0_Popup Menus/credits popup menu.tscn")
#var settingsMenuRef : PackedScene = preload()

var creditsMenu : CreditsMenuManager
#var settingdMenu : SettingsMenuManager

var currentMenu : BasePopupMenu
var allMenus : Array[BasePopupMenu]
var currentBackground : PopupMenuBackground

func _create_menu(newMenuRef : PackedScene) -> BasePopupMenu:
	_create_background()
	
	var newMenu : BasePopupMenu = newMenuRef.instantiate()
	currentMenu = newMenu
	allMenus.append(newMenu)
	
	get_tree().root.add_child(newMenu)
	
	return newMenu

func _close_current_menu():
	if currentMenu == null:
		return
	
	currentMenu.isRemoved = true
	currentMenu.queue_free()
	
	_remove_background()
	
	if _can_clear_allMenus() == true:
		allMenus.clear()

#
func _create_background():
	if allMenus.size() > 0:
		return
	currentBackground = backgroundRef.instantiate()
	
	get_tree().root.add_child(currentBackground)

func _remove_background():
	if _can_remove_background() == false:
		return
	currentBackground.queue_free()

#- - -
func _create_credits_menu() -> CreditsMenuManager:
	creditsMenu = _create_menu(creditsMenuRef)
	return creditsMenu


#--------------
func _can_remove_background() -> bool:
	var hasMenu : bool = false
	for menu in allMenus:
		if menu.isRemoved == false:
			hasMenu = true
	
	if hasMenu == true:
		return false
	else:
		return true

func _can_clear_allMenus() -> bool:
	var hasMenu : bool = false
	for menu in allMenus:
		if menu.isRemoved == false:
			hasMenu = true
	
	if hasMenu == true:
		return false
	else:
		return true
