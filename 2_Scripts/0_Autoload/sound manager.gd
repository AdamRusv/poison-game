extends Node

##TODO: make music -> enable comments
var menuMusicIntro : AudioStream = preload("res://0_Art/1_Audio/0_Music/0_Menu/Atropa_Menu.wav")
var menuMusicLoop : AudioStream = preload("res://0_Art/1_Audio/0_Music/0_Menu/Atropa_Menu Loop.wav")

var playingIntro : bool = false
var playingMenu : bool = false
var currentTrack : AudioStreamPlayer
var swapTween : Tween

var currentRegionMusic : RegionMusic = null
var stemPlayers : Array[AudioStreamPlayer] = []
var unlockedLayers : int = 0

func _ready() -> void:
	_intro_music()
	playingIntro = true
	playingMenu = true

#- menu music
func _intro_music():
	var audioPlayer : AudioStreamPlayer = _create_player(null, &"Music")
	audioPlayer.stream = menuMusicIntro
	currentTrack = audioPlayer
	
	audioPlayer.finished.connect(audioPlayer.queue_free)
	audioPlayer.finished.connect(_after_intro_loop_menu)
	audioPlayer.play()

func _after_intro_loop_menu():
	if playingMenu == false:
		return
	currentTrack = _loop_menu()

func _loop_menu() -> AudioStreamPlayer:
	playingMenu = true
	var audioPlayer : AudioStreamPlayer = _create_player(null, &"Music")
	audioPlayer.stream = menuMusicLoop
	audioPlayer.play()
	return audioPlayer

func _fade_out_menu_music():
	if is_instance_valid(currentTrack) == false:
		return
	playingMenu = false
	playingIntro = false
	var menuTrack : AudioStreamPlayer = currentTrack
	currentTrack = null
	var fadeTween : Tween = create_tween()
	fadeTween.tween_property(menuTrack, "volume_db", -80, 2)
	fadeTween.tween_callback(menuTrack.queue_free)

func _swap_to_menu():
	if playingMenu == false: # swap to menu
		if playingIntro == true:
				return
		playingMenu = true
		_swap_music(_loop_menu())

func _swap_music(track : AudioStreamPlayer):
	playingIntro = false
	var oldTrack : AudioStreamPlayer = currentTrack
	track.volume_db = -80
	
	if swapTween != null && swapTween.is_valid():
		swapTween.kill()
	swapTween = create_tween().set_parallel()
	swapTween.tween_property(track, "volume_db", 0, 2)
	if is_instance_valid(oldTrack):
		swapTween.tween_property(oldTrack, "volume_db", -80, 2)
	await swapTween.finished
	currentTrack = track
	if is_instance_valid(oldTrack):
		oldTrack.queue_free()

#- region music
func _set_region_music(music : RegionMusic, layerCount : int):
	_fade_out_menu_music()
	if music == null:
		_clear_stems()
		currentRegionMusic = null
		unlockedLayers = 0
		return
	if music == currentRegionMusic: # same song after a scene reload, only add stems
		_set_unlocked_layers(layerCount)
		return
	_fade_out_menu_music()
	_start_region_music(music, layerCount)

func _start_region_music(music : RegionMusic, layerCount : int):
	_clear_stems()
	currentRegionMusic = music
	unlockedLayers = 0
	
	# every stem is created muted, then started together so they stay in sync
	for stem in music.stems:
		stemPlayers.append(_create_player(stem, &"Music", -80))
	for player in stemPlayers:
		player.play()
	
	_set_unlocked_layers(layerCount, false, 0.0) # song start, no waiting for a section

func _set_unlocked_layers(layerCount : int, onNextSection : bool = true, fadeTime : float = 0.11):
	layerCount = clampi(layerCount, 0, stemPlayers.size())
	var delay : float = 0.0
	if onNextSection == true:
		delay = _get_time_to_next_section()
	for i in range(unlockedLayers, layerCount):
		var layerTween : Tween = create_tween()
		layerTween.tween_property(stemPlayers[i], "volume_db", 0, fadeTime).set_delay(delay)
	unlockedLayers = maxi(unlockedLayers, layerCount)

func _get_time_to_next_section() -> float:
	if stemPlayers.is_empty() || currentRegionMusic.bpm <= 0:
		return 0.0
	var sectionLength : float = currentRegionMusic._get_section_length()
	var songPosition : float = stemPlayers[0].get_playback_position() + AudioServer.get_time_since_last_mix() #- AudioServer.get_output_latency()
	return sectionLength - fposmod(songPosition, sectionLength)

func _clear_stems():
	for player in stemPlayers:
		player.queue_free()
	stemPlayers.clear()

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
	var audioPlayer : AudioStreamPlayer = _create_player(soundSFX, &"SFX", innateVolume)
	audioPlayer.finished.connect(audioPlayer.queue_free)
	audioPlayer.play()

func _create_player(stream : AudioStream, bus : StringName, volume : float = 0) -> AudioStreamPlayer:
	var audioPlayer : AudioStreamPlayer = AudioStreamPlayer.new()
	audioPlayer.stream = stream
	audioPlayer.volume_db = volume
	audioPlayer.bus = bus
	add_child(audioPlayer)
	return audioPlayer
