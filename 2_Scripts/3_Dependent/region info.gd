extends Resource

class_name RegionInfo

@export var totalEncounters : int = 4

@export var traitSheet : PaperInfo
@export var characterSheets : Array[EncounterInfo]
##starts at first country, ends at given number (example: 3 -> 3 countries, Hollyberry/Schloozyville/Sandshell)
@export var maxCountryCount : int = 0

@export var noteSheet : bool = true

@export_group("Timeline Counter")
@export var increaseRegion : bool = false

##orders the encounters as they are listed in the Array. 0 is first
#@export var linearEncounters : bool = false
