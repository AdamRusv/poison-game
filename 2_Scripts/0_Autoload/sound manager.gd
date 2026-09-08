extends Node

##TODO: make music -> enable comments
#var menuMusicIntro : AudioStream = preload("")
#var menuMusicLoop : AudioStream = preload("")
#var gameplayMusic : AudioStream = preload("")

var playingIntro : bool = false
var playingMenu : bool = false
var currentTrack : AudioStreamPlayer
var introTrack : AudioStreamPlayer
func _ready() -> void:
	_intro_music()
	playingIntro = true
	playingMenu = true
func _intro_music():
	var audioPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
	#audioPlayer.stream = menuMusicIntro
	audioPlayer.volume_db = 0
	audioPlayer.bus = &"Music"
	currentTrack = audioPlayer
	introTrack = audioPlayer
	
	
	add_child(audioPlayer)
	audioPlayer.finished.connect(audioPlayer.queue_free)
	audioPlayer.finished.connect(_after_intro_loop_menu)
	audioPlayer.play()
func _after_intro_loop_menu() -> AudioStreamPlayer:
	playingMenu = true
	var audioPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
	#audioPlayer.stream = menuMusicLoop
	audioPlayer.volume_db = 0
	audioPlayer.bus = &"Music"
	currentTrack = audioPlayer
	
	add_child(audioPlayer)
	audioPlayer.play()
	return audioPlayer

func _loop_menu() -> AudioStreamPlayer:
	playingMenu = true
	var audioPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
	#audioPlayer.stream = menuMusicLoop
	audioPlayer.volume_db = 0
	audioPlayer.bus = &"Music"
	
	add_child(audioPlayer)
	audioPlayer.play()
	return audioPlayer
func _loop_gameplay() -> AudioStreamPlayer:
	playingMenu = false
	var audioPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
	#audioPlayer.stream = gameplayMusic
	audioPlayer.volume_db = 0
	audioPlayer.bus = &"Music"
	
	add_child(audioPlayer)
	audioPlayer.play()
	return audioPlayer

func _swap_to_gameplay():
	if playingMenu == true: # swap to gameplay
		playingMenu = false
		_swap_music(_loop_gameplay())

func _swap_to_menu():
	if playingMenu == false: # swap to menu
		if playingIntro == true:
				return
		playingMenu = true
		_swap_music(_loop_menu())

func _swap_music(track : AudioStreamPlayer):
	playingIntro = false
	var newTrack : AudioStreamPlayer = track
	newTrack.volume_db = -80
	
	var swapTween : Tween = create_tween().set_parallel()
	swapTween.tween_property(newTrack, "volume_db", 0, 2)
	swapTween.tween_property(currentTrack, "volume_db", -80, 2)
	await swapTween.finished
	currentTrack = newTrack
	if introTrack != null:
		introTrack.queue_free()

#-
func _set_bus_volume(busName : String, newVolume : int):
	Settings.settingsJSON._save_settings()
	var busIndex : int = AudioServer.get_bus_index(busName)
	var linearVolume : float = newVolume / 5.0
	if newVolume == 0:
		AudioServer.set_bus_mute(busIndex, true)
		return
	AudioServer.set_bus_mute(busIndex, false)
	var volume : float = linear_to_db(linearVolume) + -5
	AudioServer.set_bus_volume_db(busIndex, volume)

func _create_sfx(soundSFX : AudioStream, innateVolume : float = 0):
	var audioPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
	audioPlayer.stream = soundSFX
	audioPlayer.volume_db = innateVolume
	audioPlayer.bus = &"SFX"
	
	add_child(audioPlayer)
	audioPlayer.finished.connect(audioPlayer.queue_free)
	audioPlayer.play()
