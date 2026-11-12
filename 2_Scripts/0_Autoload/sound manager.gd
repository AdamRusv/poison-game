extends Node

##TODO: make music -> enable comments
var menuMusicIntro : AudioStream = preload("res://0_Art/1_Audio/0_Music/0_Menu/Atropa_Menu.wav")
var menuMusicLoop : AudioStream = preload("res://0_Art/1_Audio/0_Music/0_Menu/Atropa_Menu Loop.wav")

const MUSIC_FADE_DURATION : float = 0.5

var playingIntro : bool = false
var playingMenu : bool = false
var currentTrack : AudioStreamPlayer
var swapTween : Tween
var regionTransitionTween : Tween
var requestedRegionMusic : RegionMusic = null
var requestedLayerCount : int = 0

var currentRegionMusic : RegionMusic = null
var stemPlayers : Array[AudioStreamPlayer] = []
var layerTweens : Array[Tween] = []
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
	requestedRegionMusic = music
	requestedLayerCount = layerCount

	if regionTransitionTween != null && regionTransitionTween.is_valid():
		return

	if music != null && music == currentRegionMusic && !playingMenu:
		_set_unlocked_layers(layerCount)
		return

	_cancel_layer_tweens()
	playingMenu = false
	playingIntro = false

	var hasMenuTrack : bool = is_instance_valid(currentTrack)
	if hasMenuTrack:
		if currentTrack.finished.is_connected(currentTrack.queue_free):
			currentTrack.finished.disconnect(currentTrack.queue_free)
		if currentTrack.finished.is_connected(_after_intro_loop_menu):
			currentTrack.finished.disconnect(_after_intro_loop_menu)

	if !hasMenuTrack && stemPlayers.is_empty():
		_finish_region_transition()
		return

	regionTransitionTween = create_tween().set_parallel()
	if hasMenuTrack:
		regionTransitionTween.tween_property(currentTrack, "volume_db", -80, MUSIC_FADE_DURATION)
	for player in stemPlayers:
		regionTransitionTween.tween_property(player, "volume_db", -80, MUSIC_FADE_DURATION)
	regionTransitionTween.chain().tween_callback(_finish_region_transition)

func _finish_region_transition():
	regionTransitionTween = null
	if is_instance_valid(currentTrack):
		currentTrack.stop()
		currentTrack.queue_free()
		currentTrack = null
	_clear_stems()
	currentRegionMusic = null
	unlockedLayers = 0

	if requestedRegionMusic != null:
		_start_region_music(requestedRegionMusic, requestedLayerCount)

func _start_region_music(music : RegionMusic, layerCount : int):
	_clear_stems()
	currentRegionMusic = music
	unlockedLayers = 0
	
	# every stem is created muted, then started together so they stay in sync
	for stem in music.stems:
		stemPlayers.append(_create_player(stem, &"Music", -80))
		layerTweens.append(null)
	for player in stemPlayers:
		player.play()
	
	_set_unlocked_layers(layerCount, false, 0.1) # song start

func _set_unlocked_layers(layerCount : int, onNextSection : bool = true, fadeTime : float = 0.0):
	layerCount = clampi(layerCount, 0, stemPlayers.size())
	var delay : float = 0.0
	if onNextSection == true:
		delay = _get_time_to_next_section()

	var firstChanged : int = mini(unlockedLayers, layerCount)
	var lastChanged : int = maxi(unlockedLayers, layerCount)
	for i in range(firstChanged, lastChanged):
		if layerTweens[i] != null && layerTweens[i].is_valid():
			layerTweens[i].kill()
		var layerTween : Tween = create_tween()
		var targetVolume : float = 0.0 if i < layerCount else -80.0
		layerTween.tween_property(stemPlayers[i], "volume_db", targetVolume, fadeTime).set_delay(delay)
		layerTweens[i] = layerTween
	unlockedLayers = layerCount

func _get_time_to_next_section() -> float:
	if stemPlayers.is_empty() || currentRegionMusic.bpm <= 0:
		return 0.0
	var sectionLength : float = currentRegionMusic._get_section_length()
	var songPosition : float = stemPlayers[0].get_playback_position() + AudioServer.get_time_since_last_mix() #- AudioServer.get_output_latency()
	return sectionLength - fposmod(songPosition, sectionLength)

func _clear_stems():
	_cancel_layer_tweens()
	for player in stemPlayers:
		player.stop()
		player.queue_free()
	stemPlayers.clear()

func _cancel_layer_tweens():
	for layerTween in layerTweens:
		if layerTween != null && layerTween.is_valid():
			layerTween.kill()
	layerTweens.clear()

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
