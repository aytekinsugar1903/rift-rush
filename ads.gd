extends Node
## AdMob rewarded + interstitial, after UMP (GDPR) and a local KVKK choice.
## Desktop, web, and a missing plugin keep the game playable.
## On Android, a failed or refused ad never grants the reward and never blocks the level.

signal ad_event(kind: String, state: String)

const Cfg = preload("res://ads_config.gd")
const CONSENT_PATH := "user://ads_consent.cfg"
const UMP_UNKNOWN := 0
const UMP_NOT_REQUIRED := 1
const UMP_REQUIRED := 2
const UMP_OBTAINED := 3

var _plugin: Object = null
var _choice := "" # "", "allow", "deny"
var _ump_status := UMP_UNKNOWN
var _ump_can := false
var _busy := false
var _reward_done: Callable = Callable()
var _interstitial_done: Callable = Callable()
var _layer: CanvasLayer
var _toast_layer: CanvasLayer

func _ready() -> void:
	_load_choice()
	call_deferred("_boot")

func _boot() -> void:
	if not Engine.has_singleton("RiftRushAds"):
		return
	_plugin = Engine.get_singleton("RiftRushAds")
	if _plugin == null:
		return
	_plugin.configure(Cfg.REWARDED_UNIT_ID, Cfg.INTERSTITIAL_UNIT_ID)
	_plugin.consent_finished.connect(_on_ump)
	_plugin.rewarded_finished.connect(_on_rewarded)
	_plugin.interstitial_finished.connect(_on_interstitial)
	_plugin.gatherConsent()

func using_test_ids() -> bool:
	return str(Cfg.APP_ID).begins_with("ca-app-pub-3940256099942544")

func show_rewarded(done: Callable) -> void:
	if _busy:
		done.call(false)
		return
	if _plugin == null:
		if OS.has_feature("android"):
			_note("rewarded", "unavailable")
			_toast(_fail_text())
			done.call(false)
		else:
			# No SDK in this build (desktop, web, headless tests).
			_note("rewarded", "fallback")
			done.call(true)
		return
	_reward_done = done
	_with_consent(func(allowed: bool) -> void:
		if not allowed:
			_note("rewarded", "no_consent")
			_finish_reward(false, false)
			return
		_busy = true
		_maybe_init()
		_plugin.showRewarded()
		_arm_timeout("rewarded", 12.0))

func show_interstitial(done: Callable) -> void:
	# Called only between levels. Failure and refusal both continue immediately.
	if _busy or _plugin == null:
		if _plugin == null and not OS.has_feature("android"):
			_note("interstitial", "shown")
		else:
			_note("interstitial", "unavailable")
		done.call()
		return
	if not _ads_allowed():
		done.call()
		return
	_interstitial_done = done
	_busy = true
	_maybe_init()
	_plugin.showInterstitial()
	_arm_timeout("interstitial", 12.0)

func open_consent() -> void:
	_show_choice(func(_allowed: bool) -> void:
		pass)

func consent_label() -> String:
	match _choice:
		"allow":
			return "Reklam izni: AÇIK"
		"deny":
			return "Reklam izni: KAPALI"
		_:
			return "Reklam izni: SOR"

func _ads_allowed() -> bool:
	if _choice == "deny":
		return false
	if _ump_status == UMP_REQUIRED and not _ump_can:
		return false
	if _ump_status == UMP_OBTAINED:
		return _ump_can and _choice != "deny"
	return _choice == "allow"

func _with_consent(then: Callable) -> void:
	if _choice == "deny" or (_ump_status == UMP_REQUIRED and not _ump_can):
		then.call(false)
		return
	if _ads_allowed():
		then.call(true)
		return
	_show_choice(then)

func _show_choice(then: Callable) -> void:
	if _layer and is_instance_valid(_layer):
		_layer.queue_free()
	var tr := OS.get_locale().begins_with("tr")
	_layer = CanvasLayer.new()
	_layer.layer = 40
	add_child(_layer)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.06, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(dim)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -400
	box.offset_right = 400
	box.offset_top = -300
	box.offset_bottom = 300
	box.add_theme_constant_override("separation", 18)
	_layer.add_child(box)
	var title := _text_label("Reklam izni" if tr else "Ad consent", 54)
	box.add_child(title)
	var body := _text_label(_consent_body(tr), 36)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(760, 240)
	box.add_child(body)
	var allow := _choice_button("İzin ver" if tr else "Allow", Color(0.1, 0.62, 0.38))
	var deny := _choice_button("Şimdi değil" if tr else "Not now", Color(0.35, 0.35, 0.45))
	box.add_child(allow)
	box.add_child(deny)
	allow.pressed.connect(func() -> void:
		_set_choice("allow")
		_close_choice()
		_maybe_init()
		then.call(true))
	deny.pressed.connect(func() -> void:
		_set_choice("deny")
		_close_choice()
		then.call(false))

func _consent_body(tr: bool) -> String:
	if tr:
		return "Ödüllü reklam yalnızca sen düğmeye basınca oynar. İlerleyen bölümler arasında seyrek bir tam ekran reklam çıkabilir; oyun sırasında ve ilk bölümlerde çıkmaz. İzin vermezsen oyun aynen sürer. Bu, KVKK ve GDPR için reklam iznidir."
	return "Rewarded ads play only when you tap for them. A short full-screen ad may appear between later levels, never during a run and not in the first levels. If you refuse, the game continues. This is the ads permission for KVKK and GDPR."

func _text_label(txt: String, size: int) -> Label:
	var l := Label.new()
	l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 12)
	return l

func _choice_button(txt: String, color: Color) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(760, 110)
	b.add_theme_font_size_override("font_size", 48)
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(28)
	s.set_border_width_all(6)
	s.border_color = Color(1, 1, 1, 0.9)
	b.add_theme_stylebox_override("normal", s)
	b.add_theme_color_override("font_color", Color.WHITE)
	return b

func _close_choice() -> void:
	if _layer and is_instance_valid(_layer):
		_layer.queue_free()
	_layer = null

func _set_choice(value: String) -> void:
	_choice = value
	var c := ConfigFile.new()
	c.set_value("ads", "choice", value)
	c.save(CONSENT_PATH)
	_note("consent", value)

func _load_choice() -> void:
	var c := ConfigFile.new()
	if c.load(CONSENT_PATH) == OK:
		_choice = str(c.get_value("ads", "choice", ""))

func _on_ump(can_request: int, status: int) -> void:
	_ump_can = can_request == 1
	_ump_status = status
	_note("ump", "%d/%d" % [can_request, status])
	if status == UMP_OBTAINED and _ump_can and _choice != "deny":
		_set_choice("allow")
	elif status == UMP_REQUIRED and not _ump_can and _choice != "allow":
		_set_choice("deny")
	_maybe_init()

func _on_rewarded(earned: int) -> void:
	_note("rewarded", "rewarded" if earned == 1 else "closed")
	_finish_reward(earned == 1)

func _on_interstitial(shown: int) -> void:
	_note("interstitial", "shown" if shown == 1 else "skipped")
	_finish_interstitial()

func _maybe_init() -> void:
	if _plugin and _ads_allowed() and (_ump_can or _ump_status == UMP_NOT_REQUIRED):
		_plugin.initialize()

func _finish_reward(ok: bool, tell := true) -> void:
	if not _busy and not _reward_done.is_valid():
		return
	_busy = false
	if not ok and tell:
		_toast(_fail_text())
	var done := _reward_done
	_reward_done = Callable()
	if done.is_valid():
		done.call(ok)

func _finish_interstitial() -> void:
	if not _interstitial_done.is_valid():
		return
	_busy = false
	var done := _interstitial_done
	_interstitial_done = Callable()
	if done.is_valid():
		done.call()

func _arm_timeout(kind: String, seconds: float) -> void:
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if kind == "rewarded" and _reward_done.is_valid():
			_note("rewarded", "timeout")
			_finish_reward(false)
		elif kind == "interstitial" and _interstitial_done.is_valid():
			_note("interstitial", "timeout")
			_finish_interstitial())

func _fail_text() -> String:
	if OS.get_locale().begins_with("tr"):
		return "Reklam hazır değil. Oyun devam ediyor."
	return "Ad isn't ready. The game continues."

func _toast(msg: String) -> void:
	if _toast_layer and is_instance_valid(_toast_layer):
		_toast_layer.queue_free()
	_toast_layer = CanvasLayer.new()
	_toast_layer.layer = 35
	add_child(_toast_layer)
	var l := _text_label(msg, 40)
	l.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	l.offset_top = -220
	l.offset_bottom = -80
	l.offset_left = 40
	l.offset_right = -40
	_toast_layer.add_child(l)
	var tw := create_tween()
	tw.tween_interval(1.8)
	tw.tween_callback(func() -> void:
		if _toast_layer and is_instance_valid(_toast_layer):
			_toast_layer.queue_free()
		_toast_layer = null)

func _note(kind: String, state: String) -> void:
	print("[Ads] %s %s" % [kind, state])
	ad_event.emit(kind, state)
