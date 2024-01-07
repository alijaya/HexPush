extends Node

var bgmPlayer: AudioStreamPlayer
var bgmPosition: Dictionary = {}

func _ready():
	bgmPlayer = AudioStreamPlayer.new()
	get_tree().root.add_child.call_deferred(bgmPlayer)

func playSFX(audioStream: AudioStream):
	if !audioStream: return
	var audioPlayer = AudioStreamPlayer.new()
	audioPlayer.finished.connect(func(): audioPlayer.queue_free())
	audioPlayer.stream = audioStream
	audioPlayer.autoplay = true
	get_tree().current_scene.add_child(audioPlayer)

func playBGM(audioStream: AudioStream):
	if !audioStream:
		bgmPlayer.stop()
		return
	if bgmPlayer.stream != audioStream:
		bgmPosition[bgmPlayer.stream] = bgmPlayer.get_playback_position()
		bgmPlayer.stream = audioStream
		if bgmPosition.has(audioStream):
			bgmPlayer.play.call_deferred(bgmPosition[audioStream])
		else:
			bgmPlayer.play.call_deferred()
