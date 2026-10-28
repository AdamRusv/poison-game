extends Resource

class_name CountryInfo

##country info is always index 0
@export var pages : Array[SinglePage]

@export_group("First Page")
@export var countryTitle : String 
@export_multiline var funInfo : String
