extends Node3D
## Rift Rush - v8 (3D gorunum, cok asamali bolumler). Tum sahne kodla kuruluyor.

const LANE := 4.4
const BASE_Z := -38.0
const SEC_LEN := 52.0
const MAXP := 1500
const MAXE := 400
const PSPEED := 7.0
const CYAN := Color(0.15, 0.95, 1.0)
const ENEMY := Color(1.0, 0.38, 0.12)
const PURPLE := Color(0.65, 0.2, 1.0)
const HP_MULT := [1.0, 1.0, 0.9, 0.85, 0.85, 0.85]
var maxp := 900
var last_us := 0
var wave_t := 0.0
var kill_acc := 0
var ammo_pop_t := 0.0
var ammo_bar: ProgressBar
var kale_coins := 0
var last_csf := -1.0
var is_low := false

# gate: [z, x, genislik, islem, hareket_genligi]
const LEVELS := [
	{"ammo": 190, "time": 120.0, "sections": [
		{"hp": 150, "spawn": 3.4, "brute": 0.0, "gates": [[-10.0, -2.4, 3.6, "x2", 0.0], [-10.0, 2.4, 3.6, "+10", 0.0], [-23.0, 0.0, 3.4, "x3", 2.4]]},
		{"hp": 330, "spawn": 2.6, "brute": 0.0, "gates": [[-9.0, -2.4, 3.6, "x2", 0.0], [-9.0, 2.4, 3.6, "-5", 0.0], [-18.0, 0.0, 3.0, "+10", 2.2], [-27.0, 0.0, 3.4, "x3", 1.8]]}]},
	{"ammo": 170, "time": 120.0, "sections": [
		{"hp": 200, "spawn": 1.9, "brute": 0.05, "gates": [[-9.0, -2.2, 4.0, "x2", 0.0], [-9.0, 2.2, 4.0, "-5", 0.0], [-20.0, 0.0, 3.4, "x3", 1.8]]},
		{"hp": 535, "spawn": 1.5, "brute": 0.1, "gates": [[-8.0, -2.2, 4.0, "x3", 0.0], [-8.0, 2.2, 4.0, "-5", 0.0], [-17.0, 0.0, 3.2, "+10", 2.2], [-27.0, -2.3, 3.6, "x2", 0.0], [-27.0, 2.3, 3.6, "kalkan", 0.0]]}]},
	{"ammo": 192, "time": 120.0, "sections": [
		{"hp": 220, "spawn": 1.4, "brute": 0.15, "gates": [[-8.0, -2.2, 4.0, "x2", 0.0], [-8.0, 2.2, 4.0, "x3", 0.0], [-18.0, 0.0, 3.6, "dev", 1.6], [-27.0, -2.2, 4.0, "okcu", 0.0], [-27.0, 2.2, 4.0, "-5", 0.0]]},
		{"hp": 480, "spawn": 1.1, "brute": 0.2, "gates": [[-8.0, 0.0, 3.2, "x3", 2.4], [-17.0, -2.2, 4.0, "kalkan", 0.0], [-17.0, 2.2, 4.0, "x2", 0.0], [-26.0, -2.8, 2.8, "dev", 0.0], [-26.0, 0.0, 2.8, "-5", 0.0], [-26.0, 2.8, 2.8, "x2", 0.0]]}]},
	{"ammo": 110, "time": 130.0, "sections": [
		{"hp": 260, "spawn": 1.3, "brute": 0.12, "gates": [[-8.0, 0.0, 3.0, "-5", 2.6], [-15.0, -2.2, 4.0, "x2", 0.0], [-15.0, 2.2, 4.0, "okcu", 0.0], [-25.0, 0.0, 3.0, "x3", 2.4]]},
		{"hp": 450, "spawn": 1.0, "brute": 0.2, "gates": [[-8.0, -2.2, 4.0, "x3", 0.0], [-8.0, 2.2, 4.0, "-5", 0.0], [-18.0, 0.0, 3.0, "kalkan", 2.6], [-27.0, -2.2, 4.0, "dev", 0.0], [-27.0, 2.2, 4.0, "x2", 0.0]]},
		{"hp": 800, "spawn": 0.8, "brute": 0.25, "gates": [[-8.0, -2.2, 4.0, "x2", 0.0], [-8.0, 2.2, 4.0, "x2", 0.0], [-18.0, 0.0, 3.2, "x3", 2.4], [-27.0, -2.8, 2.8, "okcu", 0.0], [-27.0, 0.0, 2.8, "dev", 0.0], [-27.0, 2.8, 2.8, "-5", 0.0]]}]},
	{"ammo": 120, "time": 140.0, "sections": [
		{"hp": 300, "spawn": 1.2, "brute": 0.15, "gates": [[-8.0, -2.8, 2.8, "x2", 0.0], [-8.0, 0.0, 2.8, "-5", 0.0], [-8.0, 2.8, 2.8, "x3", 0.0], [-18.0, 0.0, 3.0, "kalkan", 2.4], [-27.0, 0.0, 3.0, "dev", 2.0]]},
		{"hp": 550, "spawn": 0.9, "brute": 0.22, "gates": [[-8.0, 0.0, 3.0, "x3", 2.6], [-17.0, -2.2, 4.0, "okcu", 0.0], [-17.0, 2.2, 4.0, "-5", 0.0], [-26.0, -2.2, 4.0, "x2", 0.0], [-26.0, 2.2, 4.0, "kalkan", 0.0]]},
		{"hp": 950, "spawn": 0.75, "brute": 0.3, "gates": [[-8.0, -2.2, 4.0, "x2", 0.0], [-8.0, 2.2, 4.0, "+10", 0.0], [-17.0, 0.0, 3.0, "x3", 2.6], [-26.0, -2.8, 2.8, "dev", 0.0], [-26.0, 0.0, 2.8, "okcu", 1.0], [-26.0, 2.8, 2.8, "-5", 0.0]]}]},
	{"ammo": 130, "time": 150.0, "sections": [
		{"hp": 350, "spawn": 1.0, "brute": 0.2, "gates": [[-8.0, 0.0, 3.0, "-5", 2.8], [-14.0, -2.2, 4.0, "x3", 0.0], [-14.0, 2.2, 4.0, "kalkan", 0.0], [-24.0, 0.0, 3.0, "dev", 2.2]]},
		{"hp": 650, "spawn": 0.8, "brute": 0.25, "gates": [[-8.0, -2.2, 4.0, "x2", 0.0], [-8.0, 2.2, 4.0, "okcu", 0.0], [-17.0, 0.0, 3.0, "x3", 2.6], [-26.0, -2.8, 2.8, "-5", 0.0], [-26.0, 0.0, 2.8, "kalkan", 0.0], [-26.0, 2.8, 2.8, "x2", 0.0]]},
		{"hp": 1200, "spawn": 0.65, "brute": 0.32, "gates": [[-8.0, 0.0, 3.0, "x2", 2.6], [-16.0, -2.2, 4.0, "x3", 0.0], [-16.0, 2.2, 4.0, "-5", 0.0], [-25.0, -2.2, 4.0, "dev", 0.0], [-25.0, 2.2, 4.0, "okcu", 0.0]]}]},
]
const CARD_NAMES := ["Savaşçı", "Okçu", "Dev", "Büyücü"]
const CARD_REQ := [0, 3, 4, 6]       # gereken 'unlocked' (2. bolum bitince unlocked=3)
const CARD_COST := [0, 100, 200, 350]
const CARD_SPEED := [7.0, 6.0, 4.5, 6.5]
const API := "https://riftrush-demo.aytekinsugar1903.workers.dev/api"


const PORTAL_SHADER := """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float a = atan(p.y, p.x);
	float sw = sin(a * 5.0 + TIME * 3.0 - r * 14.0) * 0.5 + 0.5;
	float sw2 = sin(a * 3.0 - TIME * 2.0 + r * 9.0) * 0.5 + 0.5;
	float ring = smoothstep(0.6, 0.76, r) * (1.0 - smoothstep(0.84, 1.0, r));
	float inner = (1.0 - smoothstep(0.0, 0.78, r)) * (0.25 + 0.45 * sw * sw2);
	vec3 c = mix(vec3(0.45, 0.1, 1.0), vec3(1.0, 0.5, 1.0), sw);
	ALBEDO = c * (ring * (1.3 + sw) + inner);
}
"""

const UNIT_SHADER := """
shader_type spatial;
uniform vec3 col;
uniform float emit = 0.5;
uniform float speed = 13.0;
void vertex() {
	float ph = float(INSTANCE_ID) * 1.73;
	float s = sin(TIME * speed + ph);
	VERTEX.y += abs(s) * 0.16;
	VERTEX.x += s * 0.06 * VERTEX.y;
	VERTEX.z += cos(TIME * speed + ph) * 0.05 * VERTEX.y;
}
void fragment() {
	vec3 a = COLOR.rgb * col;
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.5);
	ALBEDO = a;
	ROUGHNESS = 0.35;
	EMISSION = a * emit + col * rim * 1.4;
}
"""

var px := PackedFloat32Array()
var pz := PackedFloat32Array()
var pdx := PackedFloat32Array()
var pmask := PackedInt32Array()
var ex := PackedFloat32Array()
var ez := PackedFloat32Array()
var ehp := PackedInt32Array()
var esc := PackedFloat32Array()
var pbuf := PackedFloat32Array()
var ebuf := PackedFloat32Array()
var pmm: MultiMesh
var emm: MultiMesh
var buckets: Array = []
var dead := PackedByteArray()

var gates: Array = []
var bases: Array = []
var level := 0
var sec := 0
var sec_off := 0.0
var playing := false
var advancing := false
var ammo := 0
var time_left := 0.0
var base_hp := 0
var base_max := 1
var spawn_t := 0.0
var fire_acc := 0.0
var holding := false
var cannon_x := 0.0
var trauma := 0.0
var t := 0.0
var pop_t := 0.0
var end_grace := 0.0
var earned := 0
var doubled := false
var front := 0.0
var cam_push := 0.0
var flash_t := 0.0
var hint_seen := false
var drag_sum := 0.0
var hint_fire_t := 0.0
var hint_t := 0.0
var test_run := false
var posts_sent := 0
var res_btns: Array = []
var res_lock_id := 0
var ammo_pop: Label3D = null
var ammo_pop_n := 0
var ammo_pop_tw: Tween = null

var coins := 0
var unlocked := 1
var rate_lv := 0

var cam: Camera3D
var cannon: Node3D
var barrel: Node3D
var flash: MeshInstance3D
var flash_light: OmniLight3D
var ring: MeshInstance3D
var parts: Array = []
var chunks: Array = []
var part_i := 0
var chunk_i := 0
var level_root: Node3D
var crystals: Array = []

var hud: Control
var lbl_level: Label
var lbl_time: Label
var lbl_ammo: Label
var lbl_units: Label
var sec_box: HBoxContainer
var sec_bars: Array = []
var hint: Control
var hand: Control
var menu: Control
var lbl_coins: Label
var lvl_btns: Array = []
var up_btn: Button
var result: Control
var res_title: Label
var res_info: Label
var btn_double: Button
var btn_next: Button

var cur_L: Dictionary = {}
var daily := false
var daily_day := ""
var shots_fired := 0
var revived := false
var ptype := PackedInt32Array()
var php := PackedInt32Array()
var pcd := PackedFloat32Array()
var blasts: Array = []
var owned := [true, false, false, false]
var card_lv := [0, 0, 0, 0]
var slots := [0, 0, 0]
var levels_since_ad := 0
var nickname := ""
var daily_best: Dictionary = {}
var type_mm: Array = []
var type_buf: Array = []
var type_frames: Array = []
var type_scale := [1.0, 1.0, 1.0, 1.0]
var arrows: Array = []
var arrow_i := 0
var loadout: Control
var slot_btns: Array = []
var card_rows: VBoxContainer
var lo_level := 0
var dailyp: Control
var daily_info: Label
var daily_list: Label
var nick_edit: LineEdit
var btn_revive: Button
var lb_http: HTTPRequest
var post_http: HTTPRequest
var bench := false
var bench_len := 12.0
var bench_shots: Array = []
var ft: Array = []
var max_units := 0
var cpu_us: Array = []
var biome := 0
var music_menu: AudioStreamPlayer
var music_battle: AudioStreamPlayer
var cur_music := 0
var opt := {"sfx": true, "music": true, "vib": true, "shadows": true}
var stars_best: Dictionary = {}
var sun: DirectionalLight3D
var envr: Environment
var sea_mat: ShaderMaterial
var clouds: MultiMeshInstance3D
var birds: Array = []
var rays: Array = []
var amb_parts: CPUParticles3D
var fader: ColorRect
var mapp: Control
var map_nodes: Array = []
var map_coins: Label
var settingsp: Control
var set_btns: Dictionary = {}
var logo: Control
var res_stars: Array = []
var stars_box: HBoxContainer
var hud_coin: Label
var ui_layer: CanvasLayer
var menu_mode := false
var start_ammo := 1
var giants_n := 0
var wind_sh: Shader
var flag_sh: Shader
var fire_mesh: QuadMesh
var ft_res: Array = []
var wind_mats: Array = []
var icon_mode := false
var win_lines := ""

func _ready() -> void:
	opt["shadows"] = not (OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"))
	_load()
	is_low = OS.has_feature("web") or OS.has_feature("mobile") or OS.get_environment("LOWEND") == "1"
	if is_low:
		opt["shadows"] = false
		maxp = 520
	bold = FontVariation.new()
	bold.base_font = ThemeDB.fallback_font
	bold.variation_embolden = 1.1
	await _bake_units()
	_build_world()
	_build_ui()
	for i in 46:
		buckets.append(PackedInt32Array())
	var args := OS.get_cmdline_user_args()
	test_run = args.size() > 0  # bench/autoplay/flowtest/*shot: asla skor gonderme
	if args.size() > 0 and args[0] == "bench":
		bench = true
		hint_seen = OS.get_environment("BENCH_HINT") != "1"
		if args.size() > 1: bench_len = float(args[1])
		for k in range(2, args.size() - 1, 2):
			bench_shots.append([float(args[k]), args[k + 1]])
		owned = [true, true, true, true]
		slots = [0, 1, 2]
		icon_mode = OS.get_environment("ICON") == "1"
		if icon_mode: slots = [0, 0, 2]
		start_level(int(OS.get_environment("BENCH_LEVEL")) if OS.get_environment("BENCH_LEVEL") != "" else 2)
		ammo = 99999
		rate_lv = 30
		var mb := InputEventMouseButton.new()
		mb.button_index = MOUSE_BUTTON_LEFT
		mb.pressed = true
		mb.position = Vector2(540, 1200)
		Input.parse_input_event(mb)
	elif args.size() > 1 and args[0] == "loadoutshot":
		coins = 420; unlocked = 4; owned = [true, true, false, false]; slots = [0, 0, 1]
		_show_loadout(3)
		await get_tree().create_timer(1.5).timeout
		get_viewport().get_texture().get_image().save_png(args[1])
		get_tree().quit()
	elif args.size() > 1 and args[0] == "dailyshot":
		nickname = "aytekin"
		_show_daily()
		await get_tree().create_timer(4.0).timeout
		get_viewport().get_texture().get_image().save_png(args[1])
		get_tree().quit()
	elif args.size() > 1 and args[0] == "menushot":
		_enter_menu()
		await get_tree().create_timer(3.5).timeout
		get_viewport().get_texture().get_image().save_png(args[1])
		get_tree().quit()
	elif args.size() > 1 and args[0] == "mapshot":
		_enter_menu()
		unlocked = 4; stars_best = {0: 3, 1: 2, 2: 1}; coins = 640
		_show_map()
		await get_tree().create_timer(2.5).timeout
		get_viewport().get_texture().get_image().save_png(args[1])
		get_tree().quit()
	elif args.size() > 3 and args[0] == "hintshot":
		hint_seen = false
		start_level(0)
		await get_tree().create_timer(0.3).timeout
		var hp0 := hand.get_global_rect().get_center()
		var cp0 := cam.unproject_position(barrel.global_position + Vector3(0, 0.5, 0))
		get_viewport().get_texture().get_image().save_png(args[1])
		await get_tree().create_timer(1.6).timeout
		get_viewport().get_texture().get_image().save_png(args[2])
		holding = true
		await get_tree().create_timer(1.0).timeout
		var vis_1s := hint.visible
		await get_tree().create_timer(1.5).timeout
		print("HINTSHOT knob_center=%s cannon_screen=%s visible_after_1s_fire=%s visible_after_2.5s_fire=%s fire_t=%.2f drag=%.0f" % [hp0, cp0, vis_1s, hint.visible, hint_fire_t, drag_sum])
		get_viewport().get_texture().get_image().save_png(args[3])
		get_tree().quit()
	elif args.size() > 2 and args[0] == "popshot":
		hint_seen = true
		rate_lv = 0; card_lv = [0, 0, 0, 0]
		start_level(1)
		holding = true
		await get_tree().create_timer(3.0).timeout
		for k in 9:
			_reward(-1.6 + k * 0.1, -9.0 - k * 0.2, false)
			await get_tree().create_timer(0.06).timeout
		print("POPSHOT text=%s" % (ammo_pop.text if is_instance_valid(ammo_pop) else "-"))
		get_viewport().get_texture().get_image().save_png(args[1])
		await get_tree().create_timer(5.0).timeout
		get_viewport().get_texture().get_image().save_png(args[2])
		get_tree().quit()
	elif args.size() > 2 and args[0] == "winshot":
		hint_seen = true
		start_level(0)
		await get_tree().create_timer(0.8).timeout
		ammo = 60; time_left = 70.0
		_win()
		await get_tree().create_timer(1.15).timeout
		var r0 := btn_next.get_global_rect()
		var d0 := btn_double.get_global_rect()
		var lk := btn_next.mouse_filter == Control.MOUSE_FILTER_IGNORE
		get_viewport().get_texture().get_image().save_png(args[1])
		await get_tree().create_timer(3.0).timeout
		print("WINSHOT next_mid=%s next_end=%s double_mid=%s double_end=%s locked_mid=%s locked_end=%s" % [r0, btn_next.get_global_rect(), d0, btn_double.get_global_rect(), lk, btn_next.mouse_filter == Control.MOUSE_FILTER_IGNORE])
		get_viewport().get_texture().get_image().save_png(args[2])
		get_tree().quit()
	elif args.size() > 0 and args[0] == "autoplay":
		_autoplay(int(args[1]) if args.size() > 1 else 0)
	elif args.size() > 0 and args[0] == "flowtest":
		_enter_menu()
		_flowtest(args[1] if args.size() > 1 else "")
	else:
		_enter_menu()

# ---------------- yardimcilar ----------------
func _mat(c: Color, emit := 0.6, alpha := 1.0, metal := 0.0, rough := 0.5) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c.r, c.g, c.b, alpha)
	m.metallic = metal
	m.roughness = rough
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emit
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

func _mesh(m: Mesh, pos: Vector3, mat: Material, parent: Node, rot := Vector3.ZERO, shadow := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = m
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	if not shadow: mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

func _box(size: Vector3, pos: Vector3, m: Material, parent: Node = self, shadow := true) -> MeshInstance3D:
	var b := BoxMesh.new()
	b.size = size
	return _mesh(b, pos, m, parent, Vector3.ZERO, shadow)

func _cyl(r_top: float, r_bot: float, h: float, pos: Vector3, m: Material, parent: Node, segs := 12, rot := Vector3.ZERO) -> MeshInstance3D:
	var c := CylinderMesh.new()
	c.top_radius = r_top
	c.bottom_radius = r_bot
	c.height = h
	c.radial_segments = segs
	c.rings = 1
	return _mesh(c, pos, m, parent, rot)

func _add_part(st: SurfaceTool, m: PrimitiveMesh, xf: Transform3D, c: Color) -> void:
	var a := m.get_mesh_arrays()
	var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
	var n: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
	var idx: PackedInt32Array = a[Mesh.ARRAY_INDEX]
	for i in idx:
		st.set_color(c)
		st.set_normal((xf.basis * n[i]).normalized())
		st.add_vertex(xf * v[i])

func _unit_mesh(col: Color) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var body := CapsuleMesh.new(); body.radius = 0.27; body.height = 0.85; body.radial_segments = 6; body.rings = 1
	_add_part(st, body, Transform3D(Basis(), Vector3(0, 0.45, 0)), Color.WHITE)
	var head := SphereMesh.new(); head.radius = 0.25; head.height = 0.5; head.radial_segments = 6; head.rings = 3
	_add_part(st, head, Transform3D(Basis(), Vector3(0, 1.05, 0)), Color.WHITE)
	var visor := BoxMesh.new(); visor.size = Vector3(0.38, 0.11, 0.1)
	_add_part(st, visor, Transform3D(Basis(), Vector3(0, 1.07, -0.21)), Color(0.08, 0.08, 0.12))
	var arm := BoxMesh.new(); arm.size = Vector3(0.13, 0.45, 0.15)
	for s in [-1, 1]:
		_add_part(st, arm, Transform3D(Basis(Vector3(0, 0, 1), s * 0.35), Vector3(s * 0.33, 0.55, 0)), Color(0.75, 0.75, 0.8))
	var leg := BoxMesh.new(); leg.size = Vector3(0.14, 0.25, 0.16)
	for s in [-1, 1]:
		_add_part(st, leg, Transform3D(Basis(), Vector3(s * 0.12, 0.1, 0)), Color(0.5, 0.5, 0.6))
	var mesh := st.commit()
	var sm := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = UNIT_SHADER
	sm.shader = sh
	sm.set_shader_parameter("col", Vector3(col.r, col.g, col.b))
	mesh.surface_set_material(0, sm)
	return mesh

func _particles(mesh: Mesh, amount: int, life: float, vmin: float, vmax: float, grav: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.emitting = false
	p.one_shot = true
	p.amount = amount
	p.lifetime = life
	p.explosiveness = 1.0
	p.mesh = mesh
	p.direction = Vector3(0, 1, 0)
	p.spread = 70
	p.initial_velocity_min = vmin
	p.initial_velocity_max = vmax
	p.gravity = Vector3(0, grav, 0)
	p.angular_velocity_min = -400
	p.angular_velocity_max = 400
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.5
	add_child(p)
	return p

# ---------------- varlik yardimcilari (Kenney CC0) ----------------
const NF := 6
var unit_frames: Array = []
var unit_mat: Material
var pmms: Array = []
var emms: Array = []
var pbufs: Array = []
var ebufs: Array = []
var mesh_cache: Dictionary = {}

func _glb(path: String) -> Node3D:
	return (load(path) as PackedScene).instantiate() as Node3D

func _flatten(root: Node3D, bake := false) -> ArrayMesh:
	var out := ArrayMesh.new()
	var inv := root.global_transform.affine_inverse()
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var m: Mesh = mi.mesh
		if bake and mi.skin != null:
			m = mi.bake_mesh_from_current_skeleton_pose()
		var xf := inv * mi.global_transform
		for s in m.get_surface_count():
			var st := SurfaceTool.new()
			st.append_from(m, s, xf)
			if absf(xf.basis.determinant() - 1.0) > 0.05:
				st.generate_normals()
			st.commit(out)
			out.surface_set_material(out.get_surface_count() - 1, mi.get_active_material(s))
	return out

func _asset_mesh(path: String) -> ArrayMesh:
	if mesh_cache.has(path): return mesh_cache[path]
	var n := _glb(path)
	add_child(n)
	var m := _flatten(n)
	n.queue_free()
	if path.contains("/nature/"):
		var sway := 0.0
		if path.contains("tree_pine"): sway = 0.035
		elif path.contains("tree_"): sway = 0.05
		elif path.contains("grass") or path.contains("flower") or path.contains("plant"): sway = 0.2
		for si in m.get_surface_count():
			var sm := m.surface_get_material(si)
			if sm is StandardMaterial3D:
				var c: Color = (sm as StandardMaterial3D).albedo_color
				if c.b > c.r and c.g > c.r:
					c = Color.from_hsv(0.27, clampf(c.s * 1.1, 0.5, 0.8), c.v)
				m.surface_set_material(si, _wind_mat(c, sway))
	mesh_cache[path] = m
	return m

var frames_p: Array = []
var frames_e: Array = []
var frames_b: Array = []
var soldier_raw: Array = []
var soldier_kinds: Array = []
var us := 1.0
var bs := 1.0
var bold: FontVariation
var sfx_players: Array = []
var sfx_streams: Dictionary = {}
var sfx_last: Dictionary = {}
var sfx_i := 0
var dust: Array = []
var dust_i := 0
var dust_t := 0.0
var pa := PackedFloat32Array()
var fly := PackedFloat32Array()  # x,y,z,vx,vy,vz,life,team (8'li)
var fly_mm: Array = []
var fly_buf: Array = []
var brute_mm: MultiMesh
var brute_buf := PackedFloat32Array()
var spark_n := 0

func _bake_units() -> void:
	# Kenney Mini Arena 'character-soldier' (kask/zirh) + kilic + kalkan; sprint animasyonu NF kareye pisirilir
	var ch := _glb("res://assets/arena/character-soldier.glb")
	add_child(ch)
	var sk: Skeleton3D = ch.find_child("Skeleton3D", true, false)
	var ap: AnimationPlayer = ch.find_child("AnimationPlayer", true, false)
	ap.play("sprint")
	ap.speed_scale = 0.0
	var L := ap.current_animation_length
	var sw := _glb("res://assets/arena/weapon-sword.glb")
	add_child(sw)
	var swm: Array = sw.find_children("*", "MeshInstance3D", true, false)
	var sword_mi: MeshInstance3D = sw as MeshInstance3D if sw is MeshInstance3D else swm[0]
	var shield := CylinderMesh.new()
	shield.top_radius = 0.085; shield.bottom_radius = 0.085; shield.height = 0.03; shield.radial_segments = 10; shield.rings = 1
	var ra := sk.find_bone("arm-right")
	var la := sk.find_bone("arm-left")
	var hb := sk.find_bone("head")
	for f in NF:
		ap.seek(L * f / NF, true)
		await get_tree().process_frame
		var inv := ch.global_transform.affine_inverse()
		var skx := inv * sk.global_transform
		var out := ArrayMesh.new()
		var kinds: Array = []
		for mi: MeshInstance3D in ch.find_children("*", "MeshInstance3D", true, false):
			var m: Mesh = mi.bake_mesh_from_current_skeleton_pose() if mi.skin != null else mi.mesh
			var xf := inv * mi.global_transform
			var kind := "head" if String(mi.name).begins_with("head") else "body"
			if kind == "head":
				var h: Vector3 = skx * sk.get_bone_global_pose(hb).origin
				xf = Transform3D(Basis(), h) * Transform3D(Basis().scaled(Vector3.ONE * 0.82), Vector3.ZERO) * Transform3D(Basis(), -h) * xf
			for si in m.get_surface_count():
				var st := SurfaceTool.new(); st.append_from(m, si, xf); st.commit(out)
				out.surface_set_material(out.get_surface_count() - 1, mi.get_active_material(si))
				kinds.append(kind)
		var rp: Transform3D = skx * sk.get_bone_global_pose(ra)
		var sxf := rp * Transform3D(Basis(Vector3.RIGHT, PI * 0.75).scaled(Vector3.ONE * 0.3), Vector3(-0.02, -0.1, -0.02))
		var st2 := SurfaceTool.new(); st2.append_from(sword_mi.mesh, 0, sxf); st2.commit(out)
		out.surface_set_material(out.get_surface_count() - 1, sword_mi.get_active_material(0)); kinds.append("prop")
		var lp: Transform3D = skx * sk.get_bone_global_pose(la)
		var st3 := SurfaceTool.new(); st3.append_from(shield, 0, lp * Transform3D(Basis(Vector3.BACK, PI * 0.5), Vector3(0.05, -0.08, 0.0))); st3.commit(out)
		kinds.append("shield")
		soldier_raw.append(out)
		soldier_kinds = kinds
	unit_mat = (soldier_raw[0] as ArrayMesh).surface_get_material(0)
	us = 1.15 / maxf(0.1, (soldier_raw[0] as ArrayMesh).get_aabb().size.y)
	ch.queue_free()
	sw.queue_free()
	# brute: Kenney Blocky Characters (farkli, iri model)
	frames_b = _team_frames(Color(0.8, 0.12, 0.06), Color(0.25, 0.2, 0.2))
	bs = us * 1.9
	var fa: Array = await _bake_frames("res://assets/blocky/character-a.glb", Color(0.55, 1.0, 0.6), "bow")
	var fm: Array = await _bake_frames("res://assets/chars/character-male-b.glb", Color(0.85, 0.6, 1.0), "staff")
	var fb: Array = _team_frames(Color(0.15, 0.4, 1.0), Color(1.0, 0.8, 0.2))
	type_frames = [[], fa, fb, fm]
	type_scale = [1.0, 1.1 / maxf(0.1, (fa[0] as ArrayMesh).get_aabb().size.y), us * 1.9, 1.2 / maxf(0.1, (fm[0] as ArrayMesh).get_aabb().size.y)]

const TEAM_SHADER := """
shader_type spatial;
uniform sampler2D tex : source_color, filter_nearest;
uniform vec3 team : source_color;
void fragment() {
	vec3 c = texture(tex, UV).rgb;
	float mx = max(c.r, max(c.g, c.b));
	float mn = min(c.r, min(c.g, c.b));
	float sat = (mx - mn) / max(mx, 0.001);
	float warm = (c.r >= c.g && c.g >= c.b) ? smoothstep(0.45, 0.65, sat) : 0.0;
	ALBEDO = mix(c, team * (0.35 + mx * 0.9), warm);
	ROUGHNESS = 0.55;
	RIM = 0.3;
	RIM_TINT = 0.3;
}
"""

func _bake_frames(path: String, tint: Color, prop: String) -> Array:
	var ch := _glb(path)
	add_child(ch)
	var ap: AnimationPlayer = ch.find_child("AnimationPlayer", true, false)
	ap.play("sprint")
	ap.speed_scale = 0.0
	var L := ap.current_animation_length
	var res: Array = []
	var body_m: StandardMaterial3D = null
	for f in NF:
		ap.seek(L * f / NF, true)
		await get_tree().process_frame
		var m := _flatten(ch, true)
		if path.contains("blocky"):
			var m2 := ArrayMesh.new()
			for si in m.get_surface_count():
				var stn := SurfaceTool.new()
				stn.create_from(m, si)
				stn.deindex()
				stn.set_smooth_group(-1)
				stn.generate_normals()
				stn.commit(m2)
			m = m2
		var ab := m.get_aabb()
		var h := ab.size.y
		if body_m == null:
			var om := m.surface_get_material(0)
			body_m = (om as StandardMaterial3D).duplicate() if om is StandardMaterial3D else StandardMaterial3D.new()
			body_m.albedo_color = tint
			if path.contains("blocky"):
				body_m.albedo_texture = null
				body_m.albedo_color = tint.darkened(0.25)
			body_m.rim_enabled = true
			body_m.rim = 0.3
		for si in m.get_surface_count():
			m.surface_set_material(si, body_m)
		if prop == "bow":
			var tor := TorusMesh.new(); tor.inner_radius = 0.27 * h; tor.outer_radius = 0.3 * h; tor.rings = 12; tor.ring_segments = 4
			var st := SurfaceTool.new()
			st.append_from(tor, 0, Transform3D(Basis(Vector3.BACK, PI * 0.5).scaled(Vector3(1, 1, 0.35)), Vector3(ab.position.x - 0.02 * h, h * 0.5, 0.05 * h)))
			st.commit(m)
			m.surface_set_material(m.get_surface_count() - 1, _mat(Color(0.55, 0.32, 0.15), 0.0))
		elif prop == "staff":
			var cy := CylinderMesh.new(); cy.top_radius = 0.025 * h; cy.bottom_radius = 0.03 * h; cy.height = 1.0 * h; cy.radial_segments = 6; cy.rings = 1
			var st2 := SurfaceTool.new()
			st2.append_from(cy, 0, Transform3D(Basis(), Vector3(ab.end.x + 0.03 * h, h * 0.5, 0.0)))
			st2.commit(m)
			m.surface_set_material(m.get_surface_count() - 1, _mat(Color(0.45, 0.28, 0.15), 0.0))
			var sp := SphereMesh.new(); sp.radius = 0.09 * h; sp.height = 0.18 * h; sp.radial_segments = 8; sp.rings = 4
			var st3 := SurfaceTool.new()
			st3.append_from(sp, 0, Transform3D(Basis(), Vector3(ab.end.x + 0.03 * h, h * 1.02, 0.0)))
			st3.commit(m)
			m.surface_set_material(m.get_surface_count() - 1, _mat(Color(0.8, 0.4, 1.0), 3.0))
		res.append(m)
	ch.queue_free()
	return res

func _team_frames(tint: Color, shield_col: Color) -> Array:
	var body := ShaderMaterial.new()
	var tsh := Shader.new()
	tsh.code = TEAM_SHADER
	body.shader = tsh
	if unit_mat is StandardMaterial3D:
		body.set_shader_parameter("tex", (unit_mat as StandardMaterial3D).albedo_texture)
	body.set_shader_parameter("team", tint)
	var sh := _mat(shield_col, 0.25, 1.0, 0.5, 0.3)
	var hm := body
	var res: Array = []
	for raw: ArrayMesh in soldier_raw:
		var m := ArrayMesh.new()
		for si in raw.get_surface_count():
			m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, raw.surface_get_arrays(si))
			m.surface_set_material(si, raw.surface_get_material(si))
		for si in m.get_surface_count():
			match soldier_kinds[si]:
				"body": m.surface_set_material(si, body)
				"head": m.surface_set_material(si, hm)
				"shield": m.surface_set_material(si, sh)
		res.append(m)
	return res

func _team_mat(tint: Color, glow: Color, ge := 0.3) -> Material:
	var m: StandardMaterial3D
	if unit_mat is StandardMaterial3D:
		m = (unit_mat as StandardMaterial3D).duplicate()
	else:
		m = StandardMaterial3D.new()
	m.albedo_color = tint
	m.emission_enabled = true
	m.emission = glow
	m.emission_energy_multiplier = ge
	m.rim_enabled = true
	m.rim = 0.3
	m.rim_tint = 0.2
	return m

func _scatter(path: String, xfs: Array, parent: Node, mat: Material = null) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _asset_mesh(path)
	mm.instance_count = xfs.size()
	for i in xfs.size():
		mm.set_instance_transform(i, xfs[i])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	if mat: mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mi)

func _place(path: String, pos: Vector3, s: float, rot_y: float, parent: Node) -> Node3D:
	var n := _glb(path)
	n.position = pos
	n.scale = Vector3.ONE * s
	n.rotation.y = rot_y
	parent.add_child(n)
	return n

var shadows_on := false

# ---------------- dunya ----------------
func _build_world() -> void:
	shadows_on = OS.get_environment("SHADOWS") == "1" or not (OS.has_feature("web") or OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.get_environment("SHADOWS") == "0")
	envr = Environment.new()
	var env := envr
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color(0.22, 0.5, 0.95)
	psm.sky_horizon_color = Color(0.72, 0.86, 1.0)
	psm.ground_horizon_color = Color(0.72, 0.86, 1.0)
	psm.ground_bottom_color = Color(0.3, 0.55, 0.85)
	psm.sun_angle_max = 20.0
	sky.sky_material = psm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.95, 0.85)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.2
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.05
	env.tonemap_white = 3.0
	env.glow_enabled = true
	env.glow_intensity = 0.35
	env.glow_hdr_threshold = 1.6
	env.fog_enabled = true
	env.fog_light_color = Color(0.92, 0.94, 1.0)
	env.fog_density = 0.0012
	env.fog_sky_affect = 0.3
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -40, 0)
	sun.light_energy = 1.0
	sun.light_color = Color(1.0, 0.92, 0.78)
	sun.shadow_enabled = opt["shadows"]
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 50.0
	add_child(sun)

	cam = Camera3D.new()
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	cam.fov = 64
	cam.far = 260
	add_child(cam)

	level_root = Node3D.new()
	add_child(level_root)

	# deniz + bulutlar (kalici)
	var sea := PlaneMesh.new()
	sea.size = Vector2(600, 600)
	sea_mat = ShaderMaterial.new()
	var ssh := Shader.new()
	ssh.code = SEA_SHADER
	sea_mat.shader = ssh
	_mesh(sea, Vector3(0, -5.2, -80), sea_mat, self, Vector3.ZERO, false)
	var cl := SphereMesh.new(); cl.radial_segments = 10; cl.rings = 6
	var clm := _mat(Color(1, 1, 1), 0.25, 1.0, 0.0, 1.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var cx: Array = []
	for i in 46:
		var s := -1.0 if i % 2 == 0 else 1.0
		var c := Vector3(s * rng.randf_range(24, 60), rng.randf_range(-7, 3), 20 - i * 6.0)
		for k in 3:
			cx.append(Transform3D(Basis().scaled(Vector3(rng.randf_range(3, 6), rng.randf_range(1.2, 2.2), rng.randf_range(2.5, 4.5))), c + Vector3(k * 3.0 - 3.0, rng.randf_range(-0.5, 0.5), rng.randf_range(-1.5, 1.5))))
	var cmm := MultiMesh.new()
	cmm.transform_format = MultiMesh.TRANSFORM_3D
	cmm.mesh = cl
	cmm.instance_count = cx.size()
	for i in cx.size(): cmm.set_instance_transform(i, cx[i])
	var cmi := MultiMeshInstance3D.new()
	cmi.multimesh = cmm
	cmi.material_override = clm
	cmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(cmi)
	clouds = cmi

	# top (Kenney Tower Defense Kit)
	cannon = Node3D.new()
	add_child(cannon)
	_box(Vector3(10.0, 0.3, 0.7), Vector3(0, 0.15, 0), _mat(Color(0.45, 0.32, 0.22), 0.0, 1.0, 0.0, 0.8), cannon)
	_box(Vector3(10.0, 0.1, 0.12), Vector3(0, 0.33, 0), _mat(Color(0.75, 0.75, 0.8), 0.0, 1.0, 0.9, 0.3), cannon)
	barrel = Node3D.new()
	cannon.add_child(barrel)
	var cn := _place("res://assets/td/weapon-cannon.glb", Vector3(0, 0.45, 0), 3.6, PI, barrel)
	cn.name = "CannonModel"
	ring = _mesh(TorusMesh.new(), Vector3(0, 0.5, 0), _mat(CYAN, 2.5), barrel, Vector3.ZERO, false)
	(ring.mesh as TorusMesh).inner_radius = 1.2
	(ring.mesh as TorusMesh).outer_radius = 1.35
	flash = _mesh(SphereMesh.new(), Vector3(0, 1.4, -1.6), _mat(Color(1.0, 0.9, 0.5), 6.0), barrel, Vector3.ZERO, false)
	flash.scale = Vector3.ZERO
	flash_light = OmniLight3D.new()
	flash_light.light_color = Color(1, 0.85, 0.5)
	flash_light.omni_range = 6
	flash_light.position = Vector3(0, 1.5, -1.8)
	barrel.add_child(flash_light)

	# birimler
	frames_p = _team_frames(Color(0.1, 0.75, 1.0), CYAN)
	frames_e = _team_frames(Color(1.0, 0.3, 0.1), ENEMY)
	var per_p := MAXP / NF + 1
	var per_e := MAXE / NF + 1
	var shad := GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for g in NF:
		for team in 2:
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = frames_p[g] if team == 0 else frames_e[g]
			mm.instance_count = per_p if team == 0 else per_e
			mm.visible_instance_count = 0
			var mi := MultiMeshInstance3D.new()
			mi.multimesh = mm
			mi.cast_shadow = shad
			mi.extra_cull_margin = 400.0
			add_child(mi)
			var b := PackedFloat32Array()
			b.resize(mm.instance_count * 12)
			if team == 0:
				pmms.append(mm); pbufs.append(b)
			else:
				emms.append(mm); ebufs.append(b)
	brute_mm = MultiMesh.new()
	brute_mm.transform_format = MultiMesh.TRANSFORM_3D
	brute_mm.mesh = frames_b[0]
	brute_mm.instance_count = 120
	brute_mm.visible_instance_count = 0
	brute_buf.resize(120 * 12)
	var bmi := MultiMeshInstance3D.new()
	bmi.multimesh = brute_mm
	bmi.cast_shadow = shad
	bmi.extra_cull_margin = 400.0
	add_child(bmi)
	type_mm = [null]
	type_buf = [PackedFloat32Array()]
	for ty in [1, 2, 3]:
		var tm := MultiMesh.new()
		tm.transform_format = MultiMesh.TRANSFORM_3D
		tm.mesh = type_frames[ty][0]
		tm.instance_count = 400
		tm.visible_instance_count = 0
		var tmi := MultiMeshInstance3D.new()
		tmi.multimesh = tm
		tmi.cast_shadow = shad
		tmi.extra_cull_margin = 400.0
		add_child(tmi)
		type_mm.append(tm)
		var tb := PackedFloat32Array(); tb.resize(400 * 12)
		type_buf.append(tb)
	var am := _mat(Color(1.0, 0.95, 0.6), 2.0)
	for i in 24:
		var ar := _box(Vector3(0.08, 0.08, 0.9), Vector3(0, -50, 0), am, self, false)
		arrows.append(ar)
	for team in 2:
		var fm := MultiMesh.new()
		fm.transform_format = MultiMesh.TRANSFORM_3D
		fm.mesh = frames_p[0] if team == 0 else frames_e[0]
		fm.instance_count = 160
		fm.visible_instance_count = 0
		var fmi := MultiMeshInstance3D.new()
		fmi.multimesh = fm
		fmi.extra_cull_margin = 400.0
		add_child(fmi)
		fly_mm.append(fm)
		var fb := PackedFloat32Array(); fb.resize(160 * 12)
		fly_buf.append(fb)
	var dm := StandardMaterial3D.new()
	dm.vertex_color_use_as_albedo = true
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var dmesh := SphereMesh.new(); dmesh.radius = 0.35; dmesh.height = 0.5; dmesh.radial_segments = 6; dmesh.rings = 3; dmesh.material = dm
	for i in 14:
		var p := _particles(dmesh, 8, 0.9, 1.0, 3.0, 1.5)
		p.spread = 90
		var gr := Gradient.new()
		gr.set_color(0, Color(0.95, 0.88, 0.75, 0.8))
		gr.set_color(1, Color(0.95, 0.88, 0.75, 0.0))
		p.color_ramp = gr
		dust.append(p)
	for k in ["shot", "gate", "hit", "explode", "basehit", "win", "lose", "coin", "click", "combo", "star"]:
		sfx_streams[k] = load("res://assets/sfx/%s.ogg" % k)
	sfx_streams["hit"] = [sfx_streams["hit"], load("res://assets/sfx/hit0.ogg"), load("res://assets/sfx/hit1.ogg"), load("res://assets/sfx/hit2.ogg")]
	for k in ["crumble", "arrow"]:
		sfx_streams[k] = [load("res://assets/sfx/%s0.ogg" % k), load("res://assets/sfx/%s1.ogg" % k), load("res://assets/sfx/%s2.ogg" % k)]
	music_menu = AudioStreamPlayer.new()
	var mm1: AudioStreamOggVorbis = load("res://assets/music/menu_towntheme.ogg")
	mm1.loop = true
	music_menu.stream = mm1
	add_child(music_menu)
	music_battle = AudioStreamPlayer.new()
	var mm2: AudioStreamOggVorbis = load("res://assets/music/battle_themeA.ogg")
	mm2.loop = true
	music_battle.stream = mm2
	add_child(music_battle)
	for i in 10:
		var ap := AudioStreamPlayer.new()
		add_child(ap)
		sfx_players.append(ap)

	var pm := StandardMaterial3D.new()
	pm.vertex_color_use_as_albedo = true
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var pmesh := BoxMesh.new(); pmesh.size = Vector3(0.18, 0.18, 0.18); pmesh.material = pm
	for i in 24:
		parts.append(_particles(pmesh, 16, 0.55, 3.0, 7.0, -14.0))
	var cm := StandardMaterial3D.new()
	cm.vertex_color_use_as_albedo = true
	var cmesh := BoxMesh.new(); cmesh.size = Vector3(0.45, 0.35, 0.4); cmesh.material = cm
	for i in 10:
		chunks.append(_particles(cmesh, 10, 1.1, 5.0, 10.0, -20.0))
	_build_alive()

func _build_island(total: float) -> void:
	var z0 := 10.0
	var zc := z0 - total * 0.5
	var P: Dictionary = BIOMES[biome]
	_box(Vector3(44, 0.6, total + 6), Vector3(0, -0.35, zc), _mat(P["ground"], 0.0, 1.0, 0.0, 0.9), level_root, false)
	_box(Vector3(42, 7, total + 4), Vector3(0, -4.0, zc), _mat(P["dirt"], 0.0, 1.0, 0.0, 1.0), level_root, false)
	_box(Vector3(10.4, 0.3, total), Vector3(0, -0.12, zc), _mat(P["path"], 0.0, 1.0, 0.0, 0.85), level_root, false)
	var tile := _mat(P["tile"], 0.0, 1.0, 0.0, 0.85)
	for k in int(total / 3.0):
		_box(Vector3(9.8, 0.04, 1.4), Vector3(0, 0.04, z0 - 2.0 - k * 3.0), tile, level_root, false)
	var edge := _mat(Color(0.62, 0.62, 0.66), 0.0, 1.0, 0.0, 0.7)
	for s in [-1, 1]:
		_box(Vector3(0.5, 0.55, total), Vector3(s * 5.3, 0.15, zc), edge, level_root)
	for wm: ShaderMaterial in wind_mats:
		wm.set_shader_parameter("biome_snow", P["snow"])
		wm.set_shader_parameter("biome_dry", P["dry"])
	sea_mat.set_shader_parameter("deep", P["deep"])
	sea_mat.set_shader_parameter("shallow", P["shallow"])
	sea_mat.set_shader_parameter("zmax", z0 + 3.0)
	sea_mat.set_shader_parameter("zmin", zc - total * 0.5 - 3.0)
	var psm: ProceduralSkyMaterial = envr.sky.sky_material
	psm.sky_top_color = P["sky"]
	psm.sky_horizon_color = P["hor"]
	psm.ground_horizon_color = P["hor"]
	envr.fog_light_color = (P["hor"] as Color).lerp(Color.WHITE, 0.4)
	sun.light_color = P["sun"]
	amb_parts.color = P["pcol"]
	amb_parts.gravity = P["pgrav"]
	amb_parts.amount = 130 if biome == 2 else 90
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var n := int(total / 3.0)
	var trees := {}
	for k in P["trees"]: trees[k] = []
	var tk := trees.keys()
	var bush := {}
	for k in P["bush"]: bush[k] = []
	var bk := bush.keys()
	var fl := {}
	for k in P["deco"]: fl[k] = []
	var fk := fl.keys()
	var rocks := {}
	for k in P["rocks"]: rocks[k] = []
	var rk := rocks.keys()
	var cliffs: Array = []
	for i in n:
		var z := z0 - i * 3.0
		for s in [-1, 1]:
			var y := rng.randf() * TAU
			trees[tk[rng.randi() % tk.size()]].append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * rng.randf_range(3.0, 4.6)), Vector3(s * rng.randf_range(8.5, 20.0), 0, z + rng.randf_range(-1, 1))))
			bush[bk[0]].append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * rng.randf_range(2.0, 3.2)), Vector3(s * rng.randf_range(6.0, 8.0), 0, z + rng.randf_range(-1, 1))))
			if i % 2 == 0:
				bush[bk[bk.size() - 1]].append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * rng.randf_range(2.0, 3.0)), Vector3(s * rng.randf_range(10, 19), 0, z)))
			fl[fk[rng.randi() % fk.size()]].append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(2.0, 3.0)), Vector3(s * rng.randf_range(5.9, 12.0), 0, z + rng.randf_range(-1.2, 1.2))))
			fl[fk[fk.size() - 1]].append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * 2.5), Vector3(s * rng.randf_range(6.0, 16.0), 0, z + 1.0)))
			if i % 3 == 0:
				rocks[rk[rng.randi() % rk.size()]].append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * rng.randf_range(2.5, 4.5)), Vector3(s * rng.randf_range(9, 20), 0, z)))
			if i % 2 == 0:
				cliffs.append(Transform3D(Basis(Vector3.UP, 0.0 if s > 0 else PI).rotated(Vector3.UP, PI * 0.5).scaled(Vector3(4.4, 7.0, 4.0)), Vector3(s * 21.0, -7.2, z)))
	for k in tk: _scatter(k, trees[k], level_root)
	for k in bk: _scatter(k, bush[k], level_root)
	for k in fk: _scatter(k, fl[k], level_root)
	for k in rk: _scatter(k, rocks[k], level_root)
	_scatter("res://assets/nature/cliff_large_rock.glb", cliffs, level_root)

func sfx(k: String, db := 0.0, gap := 0.05, pv := 0.12) -> void:
	if not opt["sfx"]: return
	if menu_mode and not k in ["click", "coin", "star", "combo"]: return
	var now := t
	if sfx_last.has(k) and now - float(sfx_last[k]) < gap: return
	sfx_last[k] = now
	var ap: AudioStreamPlayer = sfx_players[sfx_i]
	sfx_i = (sfx_i + 1) % sfx_players.size()
	ap.stream = _pick(sfx_streams[k])
	ap.volume_db = db
	ap.pitch_scale = randf_range(1.0 - pv, 1.0 + pv)
	ap.play()

func _pick(v) -> AudioStream:
	return v[randi() % v.size()] if v is Array else v

func puff(pos: Vector3) -> void:
	var p: CPUParticles3D = dust[dust_i]
	dust_i = (dust_i + 1) % dust.size()
	p.position = pos
	p.restart()

func burst(pos: Vector3, c: Color, amount := 20) -> void:
	var p: CPUParticles3D = parts[part_i]
	part_i = (part_i + 1) % parts.size()
	p.position = pos
	p.color = c
	p.restart()

func chunk_burst(pos: Vector3, c: Color) -> void:
	var p: CPUParticles3D = chunks[chunk_i]
	chunk_i = (chunk_i + 1) % chunks.size()
	p.position = pos
	p.color = c
	p.restart()

func pop_text(pos: Vector3, txt: String, c: Color, big := false) -> void:
	var l := Label3D.new()
	l.text = txt
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.font_size = 170 if big else 130
	l.pixel_size = 0.009
	l.outline_size = 40
	l.font = bold
	l.modulate = c
	l.no_depth_test = true
	l.position = pos
	add_child(l)
	l.scale = Vector3.ONE * 0.3
	var tw := create_tween()
	tw.tween_property(l, "scale", Vector3.ONE * 1.4, 0.12).set_trans(Tween.TRANS_BACK)
	tw.tween_property(l, "scale", Vector3.ONE, 0.1)
	tw.parallel().tween_property(l, "position", pos + Vector3(0, 2.2, 0), 0.7)
	tw.tween_property(l, "modulate:a", 0.0, 0.25)
	tw.tween_callback(l.queue_free)

func _make_gate(gd: Array, z_world: float, si: int, gi: int) -> Dictionary:
	var good: bool = not String(gd[3]).begins_with("-")
	var col: Color = Color(0.15, 1.0, 0.45) if good else Color(1.0, 0.18, 0.28)
	match gd[3]:
		"okcu": col = Color(0.2, 0.75, 1.0)
		"dev": col = Color(1.0, 0.6, 0.1)
		"kalkan": col = Color(1.0, 0.85, 0.2)
	var w: float = float(gd[2]) * 0.88
	var n := Node3D.new()
	n.position = Vector3(gd[1], 0, z_world)
	level_root.add_child(n)
	var frame := _mat(Color(0.95, 0.95, 1.0) if good else Color(1, 0.9, 0.9), 0.0, 1.0, 0.1, 0.3)
	var trim := _mat(col, 0.9)
	for s in [-1, 1]:
		_box(Vector3(0.45, 3.2, 0.6), Vector3(s * (w * 0.5), 1.6, 0), frame, n)
		_box(Vector3(0.6, 0.3, 0.8), Vector3(s * (w * 0.5), 0.15, 0), frame, n)
	_box(Vector3(w + 0.45, 0.5, 0.6), Vector3(0, 3.2, 0), trim, n)
	var pmat := _mat(col.lightened(0.15), 0.35, 1.0, 0.0, 0.25)
	_box(Vector3(w - 0.4, 2.9, 0.12), Vector3(0, 1.5, 0), pmat, n, false)
	var lb := Label3D.new()
	lb.text = {"okcu": "OKÇU", "dev": "DEV\n10:1", "kalkan": "KALKAN\n+1"}.get(gd[3], String(gd[3]).replace("x", "×"))
	var chars := 1
	for ln in lb.text.split("\n"): chars = maxi(chars, ln.length())
	lb.font_size = clampi(int((w - 0.7) / (chars * 0.66 * 0.0105)), 40, 200)
	if lb.text.contains("\n"): lb.font_size = mini(lb.font_size, 110)
	lb.pixel_size = 0.0105
	lb.outline_size = int(lb.font_size * 0.25)
	lb.font = bold
	lb.outline_modulate = col.darkened(0.6)
	lb.position = Vector3(0, 1.7, 0.4)
	lb.rotation_degrees = Vector3(-20, 0, 0)
	n.add_child(lb)
	var charge := 10 if gd[3] == "+10" else (5 if gd[3] == "-5" else 0)
	var cl := Label3D.new()
	cl.font = bold
	cl.font_size = 95
	cl.pixel_size = 0.009
	cl.outline_size = 44
	cl.modulate = Color(col.r, col.g, col.b, 0.0)
	cl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cl.visible = not menu_mode
	cl.no_depth_test = true
	cl.position = Vector3(0, 4.3 + (1.3 if (gi % 2 == 1 and w < 5.0) else 0.0), 0)
	n.add_child(cl)
	return {"cl": cl, "tot": 0, "ct": 9.0, "cnt": 0, "z": gd[0], "bx": gd[1], "cx": gd[1], "w": w, "op": gd[3], "amp": gd[4], "sec": si, "gi": gi,
		"charge": charge, "node": n, "pend": 0, "col": col, "ph": randf() * 6.0, "pmat": pmat}

func _make_base(z_world: float, boss: bool) -> Dictionary:
	var n := Node3D.new()
	n.position = Vector3(0, 0, z_world)
	level_root.add_child(n)
	var S := 2.4
	var C := "res://assets/castle/"
	for x in [-2.4, 0.0, 2.4]:
		_place(C + "wall.glb", Vector3(x, 0, 0), S, 0.0, n)
	var gt := _place(C + "gate.glb", Vector3(0, 0, 1.25), S * 1.3, PI * 0.5, n)
	gt.scale.x = S * 1.3
	for s in [-1, 1]:
		_place(C + "tower-square-base.glb", Vector3(s * 4.3, 0, 0), S * 1.05, 0.0, n)
		_place(C + "tower-square-mid-windows.glb", Vector3(s * 4.3, S * 1.05 * 1.01, 0), S * 1.05, 0.0, n)
		_place(C + "tower-square-top-roof-high.glb", Vector3(s * 4.3, S * 1.05 * 2.02, 0), S * 1.05, 0.0, n)
	if boss:
		_place(C + "tower-hexagon-base.glb", Vector3(0, 0, -2.4), S * 1.4, 0.0, n)
		_place(C + "tower-hexagon-mid.glb", Vector3(0, S * 1.4, -2.4), S * 1.4, 0.0, n)
		_place(C + "tower-hexagon-mid.glb", Vector3(0, S * 2.8, -2.4), S * 1.4, 0.0, n)
		_place(C + "tower-hexagon-roof.glb", Vector3(0, S * 4.2, -2.4), S * 1.4, 0.0, n)
		_place(C + "flag-banner-long.glb", Vector3(-1.5, S * 1.3, 1.3), S, 0.0, n)
		_place(C + "flag-banner-long.glb", Vector3(1.5, S * 1.3, 1.3), S, 0.0, n)
	var dmg := StandardMaterial3D.new()
	dmg.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmg.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dmg.albedo_color = Color(0.12, 0.05, 0.03, 0.0)
	for mi: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		mi.material_overlay = dmg
	for s in [-1, 1]:
		_flag(n, Vector3(s * 4.3, S * 1.05 * 3.2, 0), Color(0.9, 0.15, 0.1) if s < 0 else Color(0.6, 0.15, 0.85))
		_torch(n, Vector3(s * 1.9, 1.7, 1.75))
		_torch(n, Vector3(s * 4.3, S * 1.05 * 1.6, 1.45))
	var defs: Array = []
	var ndef := 3 if menu_mode else (1 if (level == 0 and not daily) else (2 if (level < 3 or daily) else 3))
	for k in ndef:
		var dm := MeshInstance3D.new()
		dm.mesh = frames_e[k % NF]
		dm.scale = Vector3.ONE * us
		dm.position = Vector3([0.0, -2.4, 2.4][k], S * 1.0, 0.2)
		n.add_child(dm)
		defs.append({"n": dm, "cd": randf_range(1.0, 2.5), "y": dm.position.y})
	# tema vurgusu: kalenin arkasinda mor yarik + kristaller
	var pq := QuadMesh.new()
	pq.size = Vector2(7.5, 7.5)
	var psm := ShaderMaterial.new()
	var psh := Shader.new()
	psh.code = PORTAL_SHADER
	psm.shader = psh
	var rift := _mesh(pq, Vector3(0, 6.0 if not boss else 9.0, -4.5), psm, n, Vector3.ZERO, false)
	var crm := _mat(PURPLE, 1.2)
	for s in [-1, 1]:
		var cr := _place("res://assets/td/detail-crystal-large.glb", Vector3(s * 6.6, 0, -1.0), 4.0, randf() * TAU, n)
		for mi: MeshInstance3D in cr.find_children("*", "MeshInstance3D", true, false):
			mi.material_override = crm
	var ol := OmniLight3D.new()
	ol.light_color = PURPLE
	ol.light_energy = 2.0
	ol.omni_range = 10
	ol.position = Vector3(0, 5, -2)
	n.add_child(ol)
	if boss:
		n.scale = Vector3.ONE * 1.25
	return {"node": n, "body": dmg, "rift": Node3D.new(), "cracks": 0, "defs": defs}

# ---------------- seviye ----------------
func _clear_units() -> void:
	px.clear(); pz.clear(); pdx.clear(); pmask.clear(); pa.clear(); fly.clear(); ptype.clear(); php.clear(); pcd.clear(); blasts.clear(); giants_n = 0
	ex.clear(); ez.clear(); ehp.clear(); esc.clear()

func start_level(i: int) -> void:
	menu_mode = false
	daily = false
	_start(LEVELS[i], i)

func _daily_level() -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(daily_day)
	var ops := ["x2", "x3", "+10", "-5", "okcu", "kalkan", "dev"]
	var gs: Array = []
	for row in 3:
		var z := -8.0 - row * 9.0
		if rng.randf() < 0.5:
			gs.append([z, 0.0, 3.2, ops[rng.randi() % ops.size()], rng.randf_range(1.5, 2.6)])
		else:
			var a: String = ops[rng.randi() % ops.size()]
			var b: String = ops[rng.randi() % ops.size()]
			gs.append([z, -2.2, 4.0, a, 0.0]); gs.append([z, 2.2, 4.0, b, 0.0])
	return {"ammo": 400, "time": 120.0, "sections": [{"hp": 260 + rng.randi() % 140, "spawn": rng.randf_range(1.0, 1.6), "brute": 0.12, "gates": gs}]}

func start_daily() -> void:
	menu_mode = false
	daily = true
	_start(_daily_level(), 0)

func _start(L: Dictionary, i: int) -> void:
	level = i
	cur_L = L
	shots_fired = 0
	revived = false
	dailyp.visible = false
	loadout.visible = false
	mapp.visible = false
	settingsp.visible = false
	Engine.time_scale = 1.0
	start_ammo = maxi(1, int(L["ammo"]))
	if menu_mode: biome = 0
	elif daily: biome = absi(hash(daily_day)) % 3
	else: biome = [0, 0, 1, 1, 2, 2][mini(i, 5)]
	if not menu_mode: _music(1)
	hud_coin.text = str(coins)
	_clear_units()
	for c in level_root.get_children():
		c.queue_free()
	gates.clear()
	bases.clear()
	var secs: Array = L["sections"]
	_build_island(SEC_LEN * secs.size() + 30.0)
	for si in secs.size():
		var S: Dictionary = secs[si]
		var off := -si * SEC_LEN
		var gi := 0
		for gd in S["gates"]:
			gates.append(_make_gate(gd, gd[0] + off, si, gi))
			gi += 1
		bases.append(_make_base(BASE_Z + off, si == secs.size() - 1))
	ammo = L["ammo"]
	time_left = L["time"]
	kale_coins = 0
	kill_acc = 0
	sec = 0
	sec_off = 0.0
	_setup_section()
	cannon_x = 0.0
	end_grace = 0.0
	advancing = false
	playing = true
	menu.visible = false
	result.visible = false
	hud.visible = true
	_build_sec_bars(secs.size())
	_update_titles()
	cam.position = Vector3(0, 15.0, 13.0)
	cam_push = 0.0
	if not hint_seen and not menu_mode and not daily and i == 0:
		hint.visible = true
		drag_sum = 0.0
		hint_fire_t = 0.0
		hint_t = 0.0

func _setup_section() -> void:
	var S: Dictionary = cur_L["sections"][sec]
	base_max = S["hp"]
	base_max = int(base_max * (1.0 if daily else HP_MULT[mini(level, 5)]))
	base_hp = base_max
	spawn_t = 2.0
	wave_t = 7.0

func _update_titles() -> void:
	var n: int = cur_L["sections"].size()
	if daily:
		lbl_level.text = "GÜNLÜK · %s · %d atış" % [daily_day, shots_fired]
		return
	lbl_level.text = "BÖLÜM %d · %s" % [level + 1, "BOSS" if sec == n - 1 else "KALE %d/%d" % [sec + 1, n]]

func _fire_rate() -> float:
	return 6.0 + rate_lv * 1.5

func _lv(ty: int) -> int:
	return 0 if daily else int(card_lv[ty])

func _base_hp(ty: int) -> int:
	match ty:
		0: return 1 + _lv(0) / 2
		2: return 6 + 2 * _lv(2)
	return 1

func _add_p(x: float, z: float, dx: float, mask: int, ty := 0, hp := -1) -> void:
	if px.size() >= maxp: return
	if ty == 2:
		if giants_n >= 25 and px.size() > 0:
			var k0 := randi() % px.size()
			for q in px.size():
				var ii := (k0 + q) % px.size()
				if ptype[ii] == 2:
					php[ii] = mini(php[ii] + (hp if hp > 0 else _base_hp(2)), 60)
					return
			return
		giants_n += 1
	px.append(x); pz.append(z); pdx.append(dx); pmask.append(mask); pa.append(0.0)
	ptype.append(ty); php.append(hp if hp > 0 else _base_hp(ty)); pcd.append(randf() * 0.5)

func _kill_p(i: int) -> void:
	if ptype[i] == 2: giants_n -= 1
	var l := px.size() - 1
	px[i] = px[l]; pz[i] = pz[l]; pdx[i] = pdx[l]; pmask[i] = pmask[l]; pa[i] = pa[l]; ptype[i] = ptype[l]; php[i] = php[l]; pcd[i] = pcd[l]
	px.resize(l); pz.resize(l); pdx.resize(l); pmask.resize(l); pa.resize(l); ptype.resize(l); php.resize(l); pcd.resize(l)

func _kill_e(j: int) -> void:
	var l := ex.size() - 1
	ex[j] = ex[l]; ez[j] = ez[l]; ehp[j] = ehp[l]; esc[j] = esc[l]
	ex.resize(l); ez.resize(l); ehp.resize(l); esc.resize(l)

# ---------------- girdi ----------------
func _input(e: InputEvent) -> void:
	if not playing: return
	if e is InputEventScreenTouch or (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT):
		holding = e.pressed
	elif e is InputEventScreenDrag or (e is InputEventMouseMotion and holding):
		cannon_x = clampf(cannon_x + e.relative.x * _world_per_px(), -LANE + 0.4, LANE - 0.4)
		drag_sum += absf(e.relative.x)
	elif e is InputEventKey and e.keycode == KEY_SPACE:
		holding = e.pressed

func _world_per_px() -> float:
	var w := get_viewport().get_visible_rect().size.x
	if cam == null or barrel == null: return 14.0 / w
	var y := cam.unproject_position(barrel.global_position).y
	var d := -(cam.global_transform.affine_inverse() * barrel.global_position).z
	var a := cam.project_position(Vector2(0, y), d)
	var b := cam.project_position(Vector2(w, y), d)
	return absf(b.x - a.x) / w

# ---------------- dongu ----------------
func _process(dt: float) -> void:
	if cam == null: return
	var ws := get_window().size
	var land := ws.x > ws.y
	var csf := 1.35 if land else 1.0
	if csf != last_csf:
		last_csf = csf
		get_window().content_scale_factor = csf
	t += dt
	for c in crystals:
		(c[0] as Node3D).position.y = c[1] + sin(t * 1.2 + c[2]) * 0.4
		(c[0] as Node3D).rotation.y += dt * 0.6
	for b in bases:
		(b["rift"] as Node3D).rotation.y += dt * 1.5
	ring.rotation.y += dt * 3.0
	for g in gates:
		g["ct"] += dt
		if g["ct"] > 0.9:
			var cl: Label3D = g["cl"]
			cl.modulate.a = maxf(0.0, cl.modulate.a - dt * 2.5)
			if cl.modulate.a <= 0.0: g["tot"] = 0
	if bench:
		ft.append(dt)
		var mm := InputEventMouseMotion.new()
		mm.relative = Vector2(cos(t * 0.9) * 3.5 * 0.9 * dt / 14.0 * get_viewport().get_visible_rect().size.x, 0)
		Input.parse_input_event(mm)
		max_units = max(max_units, px.size())
		if bench_shots.size() > 0 and t > bench_shots[0][0]:
			get_viewport().get_texture().get_image().save_png(bench_shots[0][1])
			bench_shots.pop_front()
		if t > bench_len:
			_bench_report()
			return
	# klavye nisan
	var kd := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): kd -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): kd += 1.0
	if kd != 0.0 and playing:
		cannon_x = clampf(cannon_x + kd * 10.0 * dt, -LANE + 0.4, LANE - 0.4)
		drag_sum += 400 * dt
	if hint.visible:
		# tutamak topun ustunde baslar, sonra topun etrafinda saga-sola gider
		hint_t += dt
		var hsp := cam.unproject_position(barrel.global_position + Vector3(0, 0.5, 0))
		var sway := sin(maxf(0.0, hint_t - 0.6) * 2.6) * 180.0 * clampf((hint_t - 0.6) / 0.8, 0.0, 1.0)
		hand.position = hsp - hand.size * 0.5 + Vector2(sway, 0)
		(hint.get_child(0) as Control).position.y = hsp.y - hand.size.y * 0.5 - 200.0
		if drag_sum > 40.0 or hint_fire_t >= 2.0:
			hint.visible = false
			hint_seen = true
			_save()
	cannon.position = Vector3(0, 0, sec_off + 1.8)
	barrel.position.x = lerpf(barrel.position.x, cannon_x, minf(1.0, dt * 35.0))
	barrel.position.z = lerpf(barrel.position.z, 0.0, minf(1.0, dt * 14.0))
	flash_t = maxf(0.0, flash_t - dt * 10.0)
	flash.scale = Vector3.ONE * flash_t * 1.1
	flash_light.light_energy = flash_t * 4.0
	trauma = maxf(0.0, trauma - dt * 2.5)
	# kamera: topun arkasi, alcak acı, ordu ilerledikce ileri itilir
	cam_push = lerpf(cam_push, clampf(-front * 0.06, 0.0, 1.8), minf(1.0, dt * 2.0))
	var cz := cannon.position.z
	var target := Vector3(0.0, 13.0 if land else 15.0, cz + (11.5 if land else 13.0) - cam_push)
	cam.position = cam.position.lerp(target, minf(1.0, dt * 4.0))
	var sh := trauma * trauma * 0.18
	cam.look_at(Vector3(0.0, 0, cam.position.z - (29.0 if land else 21.0)) + Vector3(randf_range(-sh, sh), randf_range(-sh, sh), 0))
	if menu_mode:
		var ang := t * 0.12
		cam.position = Vector3(sin(ang) * 20.0, 10.0, -18.0 + cos(ang) * 20.0)
		cam.look_at(Vector3(0, 2.0, -26.0))
		holding = true
		ammo = 9999
		cannon_x = sin(t * 0.6) * 3.0
	if icon_mode:
		hud.visible = false
		for g in gates: (g["node"] as Node3D).visible = false
		cannon_x = 0.0
		cam.fov = 50.0
		cam.position = Vector3(0.0, 6.0, sec_off + 10.0)
		cam.look_at(Vector3(0.0, 1.0, sec_off - 30.0))
	_alive(dt)
	var t0 := Time.get_ticks_usec()
	var now := Time.get_ticks_usec()
	var rdt := 0.016 if last_us == 0 else clampf((now - last_us) / 1000000.0, 0.0, 0.25)
	last_us = now
	if bench: rdt = dt
	var rem := rdt * Engine.time_scale
	while playing and not advancing and rem > 0.00001:
		var stp := minf(rem, 0.05)
		_sim(stp)
		rem -= stp
	_render()
	if bench: cpu_us.append(Time.get_ticks_usec() - t0)

func _sim(dt: float) -> void:
	var S: Dictionary = cur_L["sections"][sec]
	time_left -= dt
	if holding and ammo > 0:
		hint_fire_t += dt
		fire_acc += dt * _fire_rate()
		while fire_acc >= 1.0 and ammo > 0:
			fire_acc -= 1.0
			ammo -= 1
			var ty: int = ([0, 1, 0] if daily else slots)[shots_fired % 3]
			shots_fired += 1
			if daily and shots_fired % 5 == 0: _update_titles()
			_add_p(barrel.position.x + randf_range(-0.2, 0.2), -1.0, randf_range(-0.6, 0.6), 0, ty)
			barrel.position.z = 0.35
			sfx("shot", -10.0, 0.07)
			dust_t -= 1.0
			if dust_t <= 0.0:
				dust_t = 3.0
				puff(Vector3(barrel.position.x, 0.3, sec_off + 0.2))
			flash_t = 1.0
	else:
		fire_acc = minf(fire_acc, 1.0)
	var sg: Array = []
	for g in gates:
		if g["amp"] > 0.0:
			var w: float = g["w"]
			g["cx"] = clampf(g["bx"] + sin(t * 1.3 + g["ph"]) * g["amp"], -LANE + w * 0.5, LANE - w * 0.5)
			(g["node"] as Node3D).position.x = g["cx"]
		if g["sec"] == sec:
			sg.append(g)
	var base_hits := 0
	var n0 := px.size()
	front = 0.0
	for i in range(n0 - 1, -1, -1):
		var z0: float = pz[i]
		var ty: int = ptype[i]
		var z1: float = z0 - CARD_SPEED[ty] * dt
		if ty == 1:
			z1 = maxf(z1, BASE_Z + 9.0)
			pcd[i] -= dt
			if pcd[i] <= 0.0:
				pcd[i] = maxf(0.35, 0.9 - 0.08 * _lv(1))
				var tj := -1
				var best := 49.0
				for j in ex.size():
					var dz: float = z1 - ez[j]
					if dz > -1.0 and dz < 7.0:
						var dd: float = dz * dz + (ex[j] - px[i]) * (ex[j] - px[i])
						if dd < best:
							best = dd; tj = j
				if tj >= 0:
					ehp[tj] -= 1
					_arrow(Vector3(px[i], 1.0, z1 + sec_off), Vector3(ex[tj], 0.8, ez[tj] + sec_off))
				elif z1 <= BASE_Z + 9.5:
					base_hits += 1
					_arrow(Vector3(px[i], 1.0, z1 + sec_off), Vector3(randf_range(-2.5, 2.5), 2.5, BASE_Z + 1.5 + sec_off))
		var x: float = px[i] + pdx[i] * dt
		if z1 < -29.0:
			x = lerpf(x, clampf(x, -2.8, 2.8), dt * 3.0)
		if x > LANE or x < -LANE:
			pdx[i] = -pdx[i]
			x = clampf(x, -LANE, LANE)
		px[i] = x
		pz[i] = z1
		pa[i] += dt
		front = minf(front, z1)
		if z1 <= BASE_Z + 1.8:
			match ty:
				2: base_hits += 8 + 2 * _lv(2) + maxi(0, php[i] - _base_hp(2))
				3:
					base_hits += 5 + _lv(3)
					burst(Vector3(x, 1.5, BASE_Z + 2.0 + sec_off), PURPLE, 24)
				_: base_hits += 1
			_kill_p(i)
			continue
		var killed := false
		for g in sg:
			var gz: float = g["z"]
			var bit: int = 1 << int(g["gi"])
			if z0 > gz and z1 <= gz and absf(x - g["cx"]) < g["w"] * 0.5 and (pmask[i] & bit) == 0:
				pmask[i] |= bit
				var m := pmask[i]
				match g["op"]:
					"x2":
						_add_p(x + randf_range(-0.5, 0.5), z1 - 0.3, randf_range(-0.8, 0.8), m, ty, php[i]); g["pend"] += 1
					"x3":
						for k in 2: _add_p(x + randf_range(-0.6, 0.6), z1 - 0.3 - 0.3 * k, randf_range(-0.9, 0.9), m, ty, php[i])
						g["pend"] += 2
					"+10":
						if g["charge"] > 0:
							g["charge"] -= 1
							_add_p(x + randf_range(-0.6, 0.6), z1 - 0.4, randf_range(-0.9, 0.9), m, ty, php[i]); g["pend"] += 1
					"okcu":
						if ty == 0:
							ptype[i] = 1; php[i] = 1; g["pend"] += 1
					"kalkan":
						if php[i] < 4:
							php[i] += 1; g["pend"] += 1
					"dev":
						if ty != 2:
							g["cnt"] += 1
							killed = true
							if g["cnt"] >= 10:
								g["cnt"] = 0
								_add_p(x, z1 - 0.5, 0.0, m, 2)
								g["pend"] += 1
					"-5":
						if g["charge"] > 0:
							g["charge"] -= 1
							g["pend"] -= 1
							killed = true
				if killed:
					break
		if killed:
			_kill_p(i)
	for d in bases[sec]["defs"]:
		var dn: Node3D = d["n"]
		d["cd"] -= dt
		dn.position.y = d["y"] + absf(sin(t * 3.0 + d["cd"])) * 0.1
		if d["cd"] <= 0.0 and px.size() > 0:
			d["cd"] = randf_range(1.2, 2.2)
			for tries in 6:
				var i2 := randi() % px.size()
				if pz[i2] > BASE_Z + 2.0 and pz[i2] < BASE_Z + 18.0:
					_arrow(dn.global_position + Vector3(0, 0.9, 0.4), Vector3(px[i2], 0.6, pz[i2] + sec_off))
					sfx("arrow", -12.0, 0.1)
					php[i2] -= 1
					if php[i2] <= 0:
						_fly(px[i2], pz[i2], 0)
						_kill_p(i2)
					break
	pop_t -= dt
	if pop_t <= 0.0:
		pop_t = 0.15
		for g in sg:
			var pnd: int = g["pend"]
			if pnd != 0:
				var nd: Node3D = g["node"]
				g["tot"] += pnd
				g["ct"] = 0.0
				var cl: Label3D = g["cl"]
				var tot: int = g["tot"]
				match g["op"]:
					"okcu": cl.text = "%d OKÇU" % tot
					"kalkan": cl.text = "%d KALKAN" % tot
					"dev": cl.text = "+%d DEV" % tot
					_: cl.text = ("+%d" % tot) if tot >= 0 else str(tot)
				var clv: int = g.get("combo", 0)
				if clv < 3 and tot >= [30, 80, 160][clv]:
					g["combo"] = clv + 1
					_combo(["HARİKA!", "MUHTEŞEM!", "EFSANE!"][clv])
				cl.modulate.a = 1.0
				cl.scale = Vector3.ONE * 1.35
				create_tween().tween_property(cl, "scale", Vector3.ONE, 0.15)
				nd.scale = Vector3(1.12, 1.12, 1.12)
				create_tween().tween_property(nd, "scale", Vector3.ONE, 0.14)
				var pm: StandardMaterial3D = g["pmat"]
				pm.emission_energy_multiplier = 4.0
				create_tween().tween_property(pm, "emission_energy_multiplier", 0.8, 0.25)
				burst(nd.position + Vector3(0, 1.5, 0), g["col"], 14)
				g["pend"] = 0
				sfx("gate", -8.0, 0.12)
	var B: Dictionary = bases[sec]
	if base_hits > 0:
		base_hp -= base_hits
		sfx("basehit", -6.0, 0.09)
		trauma = minf(0.5, trauma + 0.01 * base_hits)
		var bn: Node3D = B["node"]
		var bs: float = 1.25 if sec == bases.size() - 1 else 1.0
		bn.scale = Vector3(1.05, 0.96, 1.05) * bs
		create_tween().tween_property(bn, "scale", Vector3.ONE * bs, 0.08)
		if randf() < 0.35:
			chunk_burst(Vector3(randf_range(-3, 3), randf_range(2, 4), bn.position.z + 1.5), Color(0.8, 0.3, 0.15))
		if randf() < 0.5:
			burst(Vector3(randf_range(-3, 3), 2, bn.position.z + 1.6), ENEMY, 14)
		var ratio := float(base_hp) / base_max
		var want := 3 if ratio < 0.25 else (2 if ratio < 0.5 else (1 if ratio < 0.75 else 0))
		while B["cracks"] < want:
			B["cracks"] += 1
			(B["body"] as StandardMaterial3D).albedo_color = Color(0.12, 0.05, 0.03, 0.2 * B["cracks"])
			for k in 3:
				var cr := _box(Vector3(randf_range(0.1, 0.2), randf_range(1.0, 2.2), 0.08), Vector3(randf_range(-2.8, 2.8), randf_range(1.0, 3.0), 1.55), _mat(Color(0.05, 0.02, 0.02), 0.0), bn, false)
				cr.rotation.z = randf_range(-0.8, 0.8)
			chunk_burst(Vector3(0, 3, bn.position.z + 1.5), Color(0.6, 0.25, 0.15))
	spawn_t -= dt
	if spawn_t <= 0.0 and ex.size() < MAXE:
		spawn_t = S["spawn"] * randf_range(0.7, 1.3)
		var cnt := 1 + randi() % 3
		for k in cnt:
			var brute: bool = randf() < S["brute"]
			ex.append(randf_range(-2.5, 2.5)); ez.append(BASE_Z + 2.6 + k * 0.6)
			ehp.append(10 if brute else 1); esc.append(1.9 if brute else 1.0)
		burst(Vector3(0, 2, (B["node"] as Node3D).position.z + 2.0), PURPLE, 16)
	if not menu_mode and not daily and level > 0:
		wave_t -= dt
		if wave_t <= 0.0:
			wave_t = maxf(9.0, 16.0 - level * 1.4) * randf_range(0.85, 1.15)
			var cxw := randf_range(-2.0, 2.0)
			var cols := mini(3 + level / 2, 5)
			for r in 3:
				for q in cols:
					if ex.size() >= MAXE: break
					ex.append(clampf(cxw + (q - (cols - 1) * 0.5) * 0.7, -3.8, 3.8)); ez.append(BASE_Z + 3.0 + r * 0.7)
					ehp.append(1); esc.append(1.0)
			pop_text(Vector3(cxw, 3.5, BASE_Z + 6.0 + sec_off), "DALGA!", ENEMY, true)
			sfx("arrow", -6.0, 0.1)
	ammo_pop_t -= dt
	spark_n = 0
	for k in buckets.size():
		buckets[k] = PackedInt32Array()
	var np := px.size()
	dead.resize(np)
	dead.fill(0)
	for i in np:
		var c := clampi(int(-pz[i]), 0, 45)
		buckets[c].append(i)
	for j in range(ex.size() - 1, -1, -1):
		var ezj: float = ez[j] + (2.0 if esc[j] > 1.5 else 2.7) * dt
		var exj: float = ex[j] + clampf(barrel.position.x - ex[j], -1.0, 1.0) * 0.3 * dt
		ez[j] = ezj; ex[j] = exj
		if ezj > 0.5:
			ammo = maxi(0, ammo - 3)
			trauma = minf(1.0, trauma + 0.5)
			burst(Vector3(exj, 1, sec_off + 0.5), ENEMY, 24)
			pop_text(Vector3(exj, 2.5, sec_off + 0.5), "-3", Color(1, 0.3, 0.3))
			_vib(50)
			_kill_e(j)
			continue
		var r: float = 0.6 * esc[j]
		var r2 := r * r
		var c := clampi(int(-ezj), 0, 45)
		var hp: int = ehp[j]
		for cc in range(maxi(0, c - 1), mini(45, c + 1) + 1):
			var bk: PackedInt32Array = buckets[cc]
			for idx in bk:
				if dead[idx] == 1: continue
				var ddx: float = px[idx] - exj
				var ddz: float = pz[idx] - ezj
				if ddx * ddx + ddz * ddz < r2:
					var pty: int = ptype[idx]
					if pty == 3:
						blasts.append(Vector2(px[idx], pz[idx]))
						dead[idx] = 1
						hp -= 2
						continue
					hp -= 3 if pty == 2 else 1
					php[idx] -= 1
					if php[idx] > 0:
						if hp <= 0: break
						continue
					dead[idx] = 1
					_fly(px[idx], pz[idx], 0)
					if spark_n < 3:
						spark_n += 1
						burst(Vector3(px[idx], 0.9, pz[idx] + sec_off), Color(1, 0.9, 0.4), 10)
						sfx("hit", -9.0, 0.06)
					if hp <= 0: break
			if hp <= 0: break
		ehp[j] = hp
		if hp <= 0:
			_reward(exj, ezj, esc[j] > 1.5)
			burst(Vector3(exj, 0.8, ezj + sec_off), ENEMY if esc[j] < 1.5 else Color(1, 0.8, 0.2), 18)
			if esc[j] < 1.5: _fly(exj, ezj, 1)
			if esc[j] > 1.5:
				trauma = minf(1.0, trauma + 0.3)
				chunk_burst(Vector3(exj, 1, ezj + sec_off), ENEMY)
			_kill_e(j)
	for i in range(np - 1, -1, -1):
		if dead[i] == 1:
			_kill_p(i)
	for bl: Vector2 in blasts:
		var rr := 2.0 + 0.3 * _lv(3)
		burst(Vector3(bl.x, 1.0, bl.y + sec_off), PURPLE, 30)
		burst(Vector3(bl.x, 0.5, bl.y + sec_off), Color(1, 0.6, 1), 20)
		sfx("explode", -12.0, 0.1)
		for j in range(ex.size() - 1, -1, -1):
			if Vector2(ex[j], ez[j]).distance_squared_to(bl) < rr * rr:
				ehp[j] -= 3
				if ehp[j] <= 0:
					_reward(ex[j], ez[j], esc[j] > 1.5)
					if esc[j] < 1.5: _fly(ex[j], ez[j], 1)
					_kill_e(j)
	blasts.clear()
	for j in range(ex.size() - 1, -1, -1):
		if ehp[j] <= 0:
			_reward(ex[j], ez[j], esc[j] > 1.5)
			burst(Vector3(ex[j], 0.8, ez[j] + sec_off), ENEMY, 12)
			if esc[j] < 1.5: _fly(ex[j], ez[j], 1)
			_kill_e(j)
	lbl_time.text = "%d" % ceili(maxf(0.0, time_left))
	lbl_ammo.text = "%d" % ammo
	if ammo_bar: ammo_bar.value = clampf(float(ammo) / start_ammo * 100.0, 0.0, 100.0)
	lbl_units.text = "%d" % px.size()
	(sec_bars[sec] as ProgressBar).value = 100.0 - float(maxi(base_hp, 0)) / base_max * 100.0
	if base_hp <= 0:
		_base_destroyed()
		return
	if bench or menu_mode: return
	if time_left <= 0.0:
		_lose("Süre doldu!\nİpucu: ×2 / ×3 kapılarından geçir,\nkırmızı kapılardan kaçın.")
	elif ammo <= 0 and px.size() == 0:
		end_grace += dt
		if end_grace > 0.6:
			_lose("Mermin ve ordun bitti!\nİpucu: Düşman öldürmek mermi verir.\nTopa ulaşan düşman 3 mermi götürür.")

func _reward(x: float, z: float, brute: bool) -> void:
	if menu_mode: return
	kill_acc += 6 if brute else 1
	if kill_acc >= 3:
		var add := kill_acc / 3
		kill_acc -= add * 3
		ammo += add
		_ammo_popup(x, z, add)

func _ammo_popup(x: float, z: float, add: int) -> void:
	# kucuk, kisa omurlu, yolun kenarinda; ard arda gelenler birlesir (+3 mermi)
	var side := -1.0 if x < 0.0 else 1.0
	var pos := Vector3(clampf(x + side * 1.3, -LANE + 0.3, LANE - 0.3), 1.4, z + sec_off)
	if ammo_pop != null and is_instance_valid(ammo_pop) and ammo_pop_t > 0.0:
		ammo_pop_n += add
	else:
		ammo_pop = Label3D.new()
		ammo_pop.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		# eski yazinin (130, top hizasinda) ekranda ~%40'i; uzaklik telafisiyle her yerde ayni boy
		var dk := clampf(cam.global_position.distance_to(pos) / cam.global_position.distance_to(Vector3(0, 2.6, sec_off + 0.5)), 1.0, 2.5)
		ammo_pop.font_size = int(52 * dk)
		ammo_pop.pixel_size = 0.009
		ammo_pop.outline_size = int(16 * dk)
		ammo_pop.font = bold
		ammo_pop.modulate = CYAN
		ammo_pop.no_depth_test = true
		ammo_pop.render_priority = 10
		ammo_pop.outline_render_priority = 9
		add_child(ammo_pop)
		ammo_pop_n = add
		ammo_pop.position = pos
	ammo_pop_t = 0.5
	var l := ammo_pop
	l.text = "+%d mermi" % ammo_pop_n
	l.modulate.a = 1.0
	l.scale = Vector3.ONE * 1.25
	if ammo_pop_tw != null and ammo_pop_tw.is_valid(): ammo_pop_tw.kill()
	var tw := create_tween()
	ammo_pop_tw = tw
	tw.tween_property(l, "scale", Vector3.ONE, 0.08)
	tw.parallel().tween_property(l, "position", l.position + Vector3(0, 0.5, 0), 0.4)
	tw.tween_property(l, "modulate:a", 0.0, 0.15)
	tw.tween_callback(l.queue_free)

func _arrow(a: Vector3, b: Vector3) -> void:
	var ar: MeshInstance3D = arrows[arrow_i]
	arrow_i = (arrow_i + 1) % arrows.size()
	ar.position = a
	ar.look_at_from_position(a, b, Vector3.UP)
	var tw := create_tween()
	tw.tween_property(ar, "position", b, 0.2)
	tw.tween_callback(func() -> void: ar.position.y = -50.0)

func _fly(x: float, z: float, team: int) -> void:
	if fly.size() >= 300 * 8: return
	fly.append_array(PackedFloat32Array([x, 0.0, z, randf_range(-2.5, 2.5), randf_range(5.0, 8.0), (3.5 if team == 0 else -3.5) + randf_range(-1, 1), 0.0, float(team)]))

func _base_destroyed() -> void:
	sfx("explode", 0.0, 0.0, 0.05)
	var B: Dictionary = bases[sec]
	var bn: Node3D = B["node"]
	trauma = 1.0
	var final := sec + 1 >= bases.size()
	_crumble(bn)
	_hitstop(final)
	_punch(8.0)
	_vib(120 if final else 60)
	sfx("crumble", 0.0, 0.0, 0.1)
	_coin_burst(bn.global_position + Vector3(0, 3, 2), 12)
	for k in 8:
		burst(bn.position + Vector3(randf_range(-3.5, 3.5), randf_range(1, 6), 1.0), [ENEMY, PURPLE, Color(1, 0.85, 0.3)][k % 3], 30)
	for k in 5:
		chunk_burst(bn.position + Vector3(randf_range(-3, 3), randf_range(1, 5), 1.0), Color(0.7, 0.25, 0.12))
	var tw := create_tween()
	tw.tween_property(bn, "scale", bn.scale * Vector3(1.15, 0.2, 1.15), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(bn.hide)
	coins += 15
	kale_coins += 15
	if sec + 1 >= bases.size():
		_win()
		return
	# sonraki kaleye ilerle: kalan birlikler mermiye doner
	var bonus := px.size() / 2 + 15
	ammo += bonus
	pop_text(Vector3(barrel.position.x, 4, sec_off - 6), "+%d MERMİ" % bonus, CYAN, true)
	for i in range(0, px.size(), 8):
		burst(Vector3(px[i], 0.8, pz[i] + sec_off), CYAN, 8)
	_clear_units()
	advancing = true
	holding = false
	sec += 1
	(sec_bars[sec - 1] as ProgressBar).value = 100.0
	_update_titles()
	_setup_section()
	var tw2 := create_tween()
	tw2.tween_interval(0.6)
	tw2.tween_property(self, "sec_off", -sec * SEC_LEN, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw2.tween_callback(func() -> void: advancing = false)

func _render() -> void:
	var step := int(t * 16.0)
	var n := px.size()
	var ezmax := -999.0
	for j in ez.size(): ezmax = maxf(ezmax, ez[j])
	var S := us
	for g in NF:
		var b: PackedFloat32Array = pbufs[g]
		var k := 0
		var i := g
		while i < n:
			if ptype[i] != 0:
				i += NF
				continue
			var o := k * 12
			var sc := S * minf(1.0, 0.25 + pa[i] * 6.0) * (1.0 + 0.08 * float(php[i] - 1 - _lv(0) / 2))
			b[o] = -sc; b[o + 5] = sc; b[o + 10] = -sc
			b[o + 3] = px[i]; b[o + 7] = 0.05 + ((absf(sin(t * 13.0 + i)) * 0.3) if (pz[i] < BASE_Z + 4.5 or pz[i] < ezmax + 1.0) else 0.0); b[o + 11] = pz[i] + sec_off
			k += 1
			i += NF
		var mm: MultiMesh = pmms[g]
		mm.mesh = frames_p[(g + step) % NF]
		mm.buffer = b
		mm.visible_instance_count = k
		pbufs[g] = b
	var m := ex.size()
	var nb := 0
	for g in NF:
		var b: PackedFloat32Array = ebufs[g]
		var k := 0
		var j := g
		while j < m:
			if esc[j] > 1.5:
				if g == 0 and nb < 120:
					var o2 := nb * 12
					brute_buf[o2] = bs; brute_buf[o2 + 5] = bs; brute_buf[o2 + 10] = bs
					brute_buf[o2 + 3] = ex[j]; brute_buf[o2 + 7] = 0.05; brute_buf[o2 + 11] = ez[j] + sec_off
					nb += 1
			else:
				var o := k * 12
				b[o] = S; b[o + 5] = S; b[o + 10] = S
				b[o + 3] = ex[j]; b[o + 7] = 0.05 + ((absf(sin(t * 12.0 + j)) * 0.3) if (n > 0 and ez[j] > front - 1.0) else 0.0); b[o + 11] = ez[j] + sec_off
				k += 1
			j += NF
		var mm: MultiMesh = emms[g]
		mm.mesh = frames_e[(g + step + 3) % NF]
		mm.buffer = b
		mm.visible_instance_count = k
		ebufs[g] = b
	var tcount := [0, 0, 0, 0]
	var fr := int(t * 14.0) % NF
	for i in n:
		var ty: int = ptype[i]
		if ty == 0: continue
		var c: int = tcount[ty]
		if c >= 400: continue
		var tb: PackedFloat32Array = type_buf[ty]
		var o := c * 12
		var gro := 1.0
		if ty == 2: gro = minf(1.7, 1.0 + 0.04 * float(maxi(0, php[i] - _base_hp(2))))
		else: gro = 1.0 + 0.08 * float(php[i] - 1)
		var sc: float = type_scale[ty] * minf(1.0, 0.25 + pa[i] * 6.0) * gro
		tb[o] = -sc; tb[o + 5] = sc; tb[o + 10] = -sc
		tb[o + 3] = px[i]; tb[o + 7] = 0.05 + ((absf(sin(t * 11.0 + i)) * 0.3) if (pz[i] < BASE_Z + 4.5 or pz[i] < ezmax + 1.0) else 0.0); tb[o + 11] = pz[i] + sec_off
		type_buf[ty] = tb
		tcount[ty] = c + 1
	for ty in [1, 2, 3]:
		var tm: MultiMesh = type_mm[ty]
		tm.mesh = type_frames[ty][(fr + ty) % NF]
		tm.buffer = type_buf[ty]
		tm.visible_instance_count = tcount[ty]
	brute_mm.mesh = frames_b[int(t * 10.0) % NF]
	brute_mm.buffer = brute_buf
	brute_mm.visible_instance_count = nb
	# ucusan olumler
	var dt := get_process_delta_time()
	var cnt := [0, 0]
	var fi := fly.size() - 8
	while fi >= 0:
		fly[fi + 6] += dt
		if fly[fi + 6] > 0.9:
			var last := fly.size() - 8
			for q in 8: fly[fi + q] = fly[last + q]
			fly.resize(last)
		else:
			fly[fi + 4] -= 22.0 * dt
			fly[fi] += fly[fi + 3] * dt; fly[fi + 1] = maxf(0.0, fly[fi + 1] + fly[fi + 4] * dt); fly[fi + 2] += fly[fi + 5] * dt
			var tm := int(fly[fi + 7])
			if cnt[tm] < 160:
				var fb: PackedFloat32Array = fly_buf[tm]
				var o: int = cnt[tm] * 12
				var a := fly[fi + 6] * 14.0
				var c := cos(a) * S
				var sn := sin(a) * S
				fb[o] = S; fb[o + 1] = 0; fb[o + 2] = 0; fb[o + 3] = fly[fi]
				fb[o + 4] = 0; fb[o + 5] = c; fb[o + 6] = -sn; fb[o + 7] = fly[fi + 1]
				fb[o + 8] = 0; fb[o + 9] = sn; fb[o + 10] = c; fb[o + 11] = fly[fi + 2] + sec_off
				fly_buf[tm] = fb
				cnt[tm] += 1
		fi -= 8
	for tm in 2:
		(fly_mm[tm] as MultiMesh).buffer = fly_buf[tm]
		(fly_mm[tm] as MultiMesh).visible_instance_count = cnt[tm]

# ---------------- sonuc ----------------
func _win() -> void:
	sfx("win", -2.0, 0.0, 0.0)
	playing = false
	holding = false
	if daily:
		var prev: int = daily_best.get(daily_day, 0)
		if prev == 0 or shots_fired < prev:
			daily_best[daily_day] = shots_fired
		earned = 60
		coins += earned
		_save()
		_post_score(shots_fired)
		await get_tree().create_timer(1.0, true, false, true).timeout
		res_title.text = "ZAFER!"
		res_title.modulate = CYAN
		stars_box.visible = false
		res_info.text = "%d atışla yıktın!\nBugünkü en iyin: %d   (+%d coin)" % [shots_fired, daily_best[daily_day], earned]
		btn_double.visible = false
		btn_revive.visible = false
		btn_next.text = "Sıralama"
		_show_result()
		return
	var c_lvl := 40 + 30 * (level + 1)
	var c_ammo := mini(ammo, 150)
	var c_time := int(time_left)
	earned = c_lvl + c_ammo + c_time
	coins += earned
	var tmax: float = cur_L["time"]
	var s_time := time_left >= tmax * 0.3
	var s_ammo := ammo >= start_ammo * 0.25
	var st := 1 + int(s_time) + int(s_ammo)
	hint_seen = true
	win_lines = "1. yıldız: Kale yıkıldı\n2. yıldız: %d+ sn kalsın (%d) %s\n3. yıldız: %d+ mermi kalsın (%d) %s\nBölüm %d + Mermi %d + Süre %d + Kaleler %d" % [int(tmax * 0.3), c_time, "OK" if s_time else "X", int(start_ammo * 0.25), ammo, "OK" if s_ammo else "X", c_lvl, c_ammo, c_time, kale_coins]
	stars_best[level] = maxi(int(stars_best.get(level, 0)), st)
	doubled = false
	levels_since_ad += 1
	if level + 1 < LEVELS.size():
		unlocked = maxi(unlocked, level + 2)
	_save()
	await get_tree().create_timer(1.0, true, false, true).timeout
	res_title.text = "ZAFER!"
	res_title.modulate = CYAN
	res_info.text = ""
	var adur := _anim_win(st)
	btn_double.visible = true
	btn_next.text = "Sonraki Bölüm" if level + 1 < LEVELS.size() else "Menü"
	btn_next.visible = true
	btn_revive.visible = false
	_show_result(adur)

func _lose(why: String) -> void:
	sfx("lose", -2.0, 0.0, 0.0)
	playing = false
	holding = false
	res_title.text = "YENİLDİN"
	stars_box.visible = false
	_music(0)
	res_title.modulate = ENEMY
	res_info.text = why
	btn_double.visible = false
	btn_revive.visible = not revived
	btn_next.text = "Tekrar Dene"
	btn_next.visible = true
	_show_result()

func _show_result(lock := 0.5) -> void:
	hud.visible = false
	result.visible = true
	result.modulate.a = 0.0
	create_tween().tween_property(result, "modulate:a", 1.0, 0.25)
	# animasyon bitene kadar butonlar tiklanmaz
	res_lock_id += 1
	var my_id := res_lock_id
	for b: Button in res_btns:
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.modulate.a = 0.45
	var tw := create_tween()
	tw.tween_interval(lock)
	tw.tween_callback(func() -> void:
		if my_id != res_lock_id: return
		for b: Button in res_btns:
			b.mouse_filter = Control.MOUSE_FILTER_STOP
			create_tween().tween_property(b, "modulate:a", 1.0, 0.12))

func _on_double() -> void:
	if doubled: return
	Ads.show_rewarded(func(ok: bool) -> void:
		if ok:
			coins += earned
			doubled = true
			_save()
			res_info.text = "+%d coin (2×)   (Toplam: %d)" % [earned * 2, coins]
			btn_double.visible = false)

func _maybe_interstitial(then: Callable) -> void:
	# adil reklam: ilk 3 bolumde asla, sonra en fazla 3 bolumde bir
	if level >= 3 and levels_since_ad >= 3:
		levels_since_ad = 0
		_save()
		Ads.show_interstitial(then)
	else:
		then.call()

func _on_revive() -> void:
	Ads.show_rewarded(func(ok: bool) -> void:
		if ok:
			revived = true
			ammo += 50
			time_left = maxf(time_left, 25.0)
			end_grace = 0.0
			result.visible = false
			hud.visible = true
			playing = true)

func _on_next() -> void:
	if daily:
		_show_daily()
		return
	if res_title.text == "ZAFER!":
		if level + 1 < LEVELS.size():
			var nxt := level + 1
			_maybe_interstitial(func() -> void: _show_loadout(nxt))
		else:
			_maybe_interstitial(_show_menu)
	elif daily:
		start_daily()
	else:
		_start(cur_L, level)

func _show_menu() -> void:
	_fade(_enter_menu)

# ---------------- UI ----------------
func _style(c: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(36)
	s.border_color = Color(1, 1, 1, 0.9)
	s.set_border_width_all(6)
	s.content_margin_top = 18
	s.content_margin_bottom = 18
	return s

func _btn(txt: String, c: Color, parent: Node, cb: Callable) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(720, 140)
	b.add_theme_font_size_override("font_size", 56)
	b.add_theme_stylebox_override("normal", _style(c))
	b.add_theme_stylebox_override("hover", _style(c.lightened(0.15)))
	b.add_theme_stylebox_override("pressed", _style(c.darkened(0.2)))
	b.add_theme_stylebox_override("disabled", _style(Color(0.3, 0.3, 0.38)))
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	b.add_theme_constant_override("outline_size", 10)
	b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	b.pressed.connect(func() -> void: sfx("click", -6.0, 0.03, 0.05))
	b.pressed.connect(cb)
	parent.add_child(b)
	return b

func _label(txt: String, size: int, parent: Node, c := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", maxi(8, size / 6))
	l.modulate = c
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(l)
	return l

func _panel(parent: Node) -> VBoxContainer:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(root)
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.02, 0.1, 0.78)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(cc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 34)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	cc.add_child(v)
	return v

func _build_ui() -> void:
	var cl := CanvasLayer.new()
	add_child(cl)
	hud = Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(hud)
	var top := VBoxContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_top = 40
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(top)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(row)
	lbl_level = _label("BÖLÜM 1", 46, top, Color(1, 1, 1))
	top.move_child(lbl_level, 0)
	lbl_time = _chip(row, Color(1.0, 0.8, 0.2), "time")
	lbl_ammo = _chip(row, Color(1.0, 0.5, 0.2), "ammo")
	lbl_units = _chip(row, CYAN, "army")
	var abc := CenterContainer.new()
	abc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(abc)
	ammo_bar = ProgressBar.new()
	ammo_bar.custom_minimum_size = Vector2(520, 26)
	ammo_bar.show_percentage = false
	ammo_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fb := StyleBoxFlat.new(); fb.bg_color = Color(1.0, 0.55, 0.2); fb.set_corner_radius_all(13)
	var bb := StyleBoxFlat.new(); bb.bg_color = Color(0.05, 0.05, 0.15, 0.7); bb.set_corner_radius_all(13)
	ammo_bar.add_theme_stylebox_override("fill", fb)
	ammo_bar.add_theme_stylebox_override("background", bb)
	abc.add_child(ammo_bar)
	var crow := HBoxContainer.new()
	crow.alignment = BoxContainer.ALIGNMENT_END
	crow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_coin = _chip(crow, Color(1, 0.85, 0.2), "ammo")
	var hc := CenterContainer.new()
	top.add_child(hc)
	sec_box = HBoxContainer.new()
	sec_box.add_theme_constant_override("separation", 14)
	hc.add_child(sec_box)
	top.add_child(crow)
	var cpad := Control.new()
	cpad.custom_minimum_size = Vector2(30, 0)
	crow.add_child(cpad)
	var hl := _label("Sürükle: nişan · Basılı tut: ateş · Düşman öldür: +mermi", 34, hud, Color(1, 1, 1, 0.7))
	hl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hl.offset_top = -80
	hl.offset_bottom = -30
	hint = Control.new()
	hint.set_anchors_preset(Control.PRESET_FULL_RECT)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(hint)
	var hlab := _label("SÜRÜKLE & BASILI TUT", 64, hint, Color(1, 1, 0.6))
	hlab.position = Vector2(0, 1250)
	hlab.size = Vector2(1080, 90)
	hand = Panel.new()
	var hs := StyleBoxFlat.new()
	hs.bg_color = Color(1, 1, 1, 0.85)
	hs.set_corner_radius_all(60)
	hs.border_color = CYAN
	hs.set_border_width_all(10)
	hand.add_theme_stylebox_override("panel", hs)
	hand.size = Vector2(120, 120)
	hand.position = Vector2(480, 1380)
	hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_child(hand)
	var fing := ColorRect.new()
	fing.color = Color(1, 1, 1, 0.85)
	fing.size = Vector2(36, 110)
	fing.position = Vector2(42, -80)
	hand.add_child(fing)
	hint.visible = false
	hud.visible = false

	ui_layer = cl
	var mv := _panel(cl)
	menu = mv.get_parent().get_parent()
	(menu.get_child(0) as ColorRect).color = Color(0.03, 0.02, 0.1, 0.15)
	_build_logo(mv)
	_label("Ordunu kur, yarığı kapat!", 46, mv, Color(1, 0.95, 0.8))
	lbl_coins = _label("", 60, mv, Color(1, 0.85, 0.2))
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 300)
	mv.add_child(gap)
	var pb := _btn("OYNA", Color(0.1, 0.72, 0.4), mv, _show_map)
	pb.custom_minimum_size = Vector2(720, 180)
	pb.add_theme_font_size_override("font_size", 90)
	_btn("Günlük Meydan Okuma", Color(0.95, 0.55, 0.1), mv, _show_daily)
	_btn("Ayarlar", Color(0.3, 0.35, 0.6), mv, _show_settings).custom_minimum_size = Vector2(720, 100)
	var badge := PanelContainer.new()
	var bsb := StyleBoxFlat.new(); bsb.bg_color = Color(0.1, 0.6, 0.3, 0.9); bsb.set_corner_radius_all(30)
	bsb.content_margin_left = 24; bsb.content_margin_right = 24; bsb.content_margin_top = 6; bsb.content_margin_bottom = 6
	badge.add_theme_stylebox_override("panel", bsb)
	badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mv.add_child(badge)
	_label("Zorla reklam yok", 38, badge)
	_build_loadout(cl)
	_build_daily(cl)
	_build_map(cl)
	_build_settings(cl)

	var rv := _panel(cl)
	result = rv.get_parent().get_parent()
	res_title = _label("", 140, rv)
	stars_box = HBoxContainer.new()
	stars_box.alignment = BoxContainer.ALIGNMENT_CENTER
	stars_box.add_theme_constant_override("separation", 20)
	rv.add_child(stars_box)
	for k in 3:
		var sc := Control.new()
		sc.custom_minimum_size = Vector2(190, 190)
		stars_box.add_child(sc)
		var sp := _star(sc, 80, Color(0.3, 0.27, 0.4), Vector2(95, 100 - (16 if k == 1 else 0)))
		res_stars.append(sp)
	res_info = _label("", 44, rv, Color(1, 0.85, 0.2))
	res_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# metin alani bastan ayrilir: yazi animasyonu sirasinda butonlar kaymaz
	res_info.custom_minimum_size = Vector2(860, 500)
	res_info.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	btn_next = _btn("Sonraki", Color(0.1, 0.7, 0.45), rv, _on_next)
	btn_double = _btn("2× Coin  (Reklam izle)", Color(0.95, 0.6, 0.1), rv, _on_double)
	btn_revive = _btn("Devam et +50 mermi (Reklam)", Color(0.85, 0.3, 0.6), rv, _on_revive)
	var bmenu := _btn("Menü", Color(0.3, 0.3, 0.5), rv, _show_menu)
	res_btns = [btn_next, btn_double, btn_revive, bmenu]
	result.visible = false
	var fl := CanvasLayer.new()
	fl.layer = 10
	add_child(fl)
	fader = ColorRect.new()
	fader.color = Color(0.03, 0.02, 0.08, 0.0)
	fader.set_anchors_preset(Control.PRESET_FULL_RECT)
	fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fl.add_child(fader)
	_refresh_menu()

func _chip(parent: Node, col: Color, kind: String) -> Label:
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.1, 0.22, 0.72)
	sb.set_corner_radius_all(40)
	sb.border_color = col
	sb.set_border_width_all(5)
	sb.content_margin_left = 14; sb.content_margin_right = 26; sb.content_margin_top = 8; sb.content_margin_bottom = 8
	pc.add_theme_stylebox_override("panel", sb)
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(pc)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	pc.add_child(h)
	var ic := Panel.new()
	ic.custom_minimum_size = Vector2(62, 62)
	var isb := StyleBoxFlat.new()
	isb.bg_color = col
	isb.set_corner_radius_all(31)
	ic.add_theme_stylebox_override("panel", isb)
	h.add_child(ic)
	var dk := Color(0.1, 0.1, 0.2)
	match kind:
		"time":
			var r1 := ColorRect.new(); r1.color = dk; r1.size = Vector2(6, 22); r1.position = Vector2(28, 12); ic.add_child(r1)
			var r2 := ColorRect.new(); r2.color = dk; r2.size = Vector2(18, 6); r2.position = Vector2(28, 30); ic.add_child(r2)
		"ammo":
			var b := Panel.new(); var bsb := StyleBoxFlat.new(); bsb.bg_color = dk; bsb.set_corner_radius_all(14)
			b.add_theme_stylebox_override("panel", bsb); b.size = Vector2(28, 28); b.position = Vector2(17, 17); ic.add_child(b)
		"army":
			var hd := Panel.new(); var hsb := StyleBoxFlat.new(); hsb.bg_color = dk; hsb.set_corner_radius_all(9)
			hd.add_theme_stylebox_override("panel", hsb); hd.size = Vector2(18, 18); hd.position = Vector2(22, 10); ic.add_child(hd)
			var bd := Panel.new(); var bdsb := StyleBoxFlat.new(); bdsb.bg_color = dk; bdsb.corner_radius_top_left = 12; bdsb.corner_radius_top_right = 12
			bd.add_theme_stylebox_override("panel", bdsb); bd.size = Vector2(30, 20); bd.position = Vector2(16, 31); ic.add_child(bd)
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 50)
	l.add_theme_font_override("font", bold)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 10)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(l)
	return l

func _build_sec_bars(n: int) -> void:
	for c in sec_box.get_children():
		c.queue_free()
	sec_bars.clear()
	var w := 760 / n - 14
	for i in n:
		var pb := ProgressBar.new()
		pb.custom_minimum_size = Vector2(w, 40 if i < n - 1 else 52)
		pb.show_percentage = false
		var fill := StyleBoxFlat.new(); fill.bg_color = CYAN if i < n - 1 else Color(1, 0.75, 0.1); fill.set_corner_radius_all(18)
		var bgs := StyleBoxFlat.new(); bgs.bg_color = Color(0, 0, 0, 0.55); bgs.set_corner_radius_all(18)
		bgs.border_color = Color.WHITE; bgs.set_border_width_all(4)
		pb.add_theme_stylebox_override("fill", fill)
		pb.add_theme_stylebox_override("background", bgs)
		sec_box.add_child(pb)
		sec_bars.append(pb)

func _build_loadout(cl: Node) -> void:
	var v := _panel(cl)
	loadout = v.get_parent().get_parent()
	v.add_theme_constant_override("separation", 22)
	_label("ORDUNU KUR", 100, v, CYAN)
	_label("Top sırayla bu 3 kartı atar (dokun: değiştir)", 36, v, Color(1, 1, 1, 0.8))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	v.add_child(row)
	for k in 3:
		var kk := k
		var b := _btn("", Color(0.15, 0.4, 0.8), row, func() -> void: _cycle_slot(kk))
		b.custom_minimum_size = Vector2(300, 200)
		slot_btns.append(b)
	card_rows = VBoxContainer.new()
	card_rows.add_theme_constant_override("separation", 14)
	v.add_child(card_rows)
	_btn("SAVAŞA BAŞLA", Color(0.1, 0.7, 0.45), v, func() -> void: _fade(func() -> void: start_level(lo_level)))
	_btn("Geri", Color(0.3, 0.3, 0.5), v, _show_map).custom_minimum_size = Vector2(720, 90)
	loadout.visible = false

func _card_desc(ty: int) -> String:
	return ["Kılıç + kalkan, dengeli", "Uzaktan ok atar, kırılgan", "Yavaş, dayanıklı, kaleye çok vurur", "Temasta alan patlaması"][ty]

func _show_loadout(i: int) -> void:
	lo_level = i
	mapp.visible = false
	_music(0)
	menu.visible = false
	result.visible = false
	hud.visible = false
	loadout.visible = true
	_refresh_loadout()

func _cycle_slot(k: int) -> void:
	var cur: int = slots[k]
	for step in range(1, 5):
		var nx := (cur + step) % 4
		if owned[nx]:
			slots[k] = nx
			break
	_save()
	_refresh_loadout()

func _refresh_loadout() -> void:
	var cols := [Color(0.15, 0.55, 0.9), Color(0.15, 0.7, 0.4), Color(0.9, 0.5, 0.1), Color(0.6, 0.3, 0.9)]
	for k in 3:
		var b: Button = slot_btns[k]
		var ty: int = slots[k]
		b.text = "%d. %s\nSv.%d" % [k + 1, CARD_NAMES[ty], int(card_lv[ty]) + 1]
		b.add_theme_stylebox_override("normal", _style(cols[ty]))
		b.add_theme_stylebox_override("hover", _style(cols[ty].lightened(0.15)))
		b.add_theme_font_size_override("font_size", 44)
	for c in card_rows.get_children():
		c.queue_free()
	var cl := _label("Coin: %d" % coins, 50, card_rows, Color(1, 0.85, 0.2))
	cl.name = "coins"
	for ty in 4:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 16)
		card_rows.add_child(h)
		var l := _label("%s - %s" % [CARD_NAMES[ty], _card_desc(ty)], 32, h)
		l.custom_minimum_size = Vector2(560, 0)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var tyy := ty
		var b: Button
		if not owned[ty]:
			if unlocked < CARD_REQ[ty]:
				b = _btn("Bölüm %d sonrası" % (CARD_REQ[ty] - 1), Color(0.3, 0.3, 0.38), h, func() -> void: pass)
				b.disabled = true
			else:
				b = _btn("Aç: %d" % CARD_COST[ty], Color(0.9, 0.6, 0.1), h, func() -> void: _buy_card(tyy))
				b.disabled = coins < CARD_COST[ty]
		else:
			var cost := 80 * (int(card_lv[ty]) + 1)
			b = _btn("Sv.%d: %d coin" % [int(card_lv[ty]) + 2, cost] if card_lv[ty] < 5 else "MAKS", Color(0.55, 0.2, 0.9), h, func() -> void: _up_card(tyy))
			b.disabled = coins < cost or card_lv[ty] >= 5
		b.custom_minimum_size = Vector2(300, 90)
		b.add_theme_font_size_override("font_size", 38)

func _buy_card(ty: int) -> void:
	if coins >= CARD_COST[ty] and not owned[ty]:
		coins -= CARD_COST[ty]
		owned[ty] = true
		_save()
		_refresh_loadout()

func _up_card(ty: int) -> void:
	var cost := 80 * (int(card_lv[ty]) + 1)
	if coins >= cost and card_lv[ty] < 5:
		coins -= cost
		card_lv[ty] = int(card_lv[ty]) + 1
		_save()
		_refresh_loadout()

func _today() -> String:
	var d := Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_system()) + 3 * 3600)
	return "%04d-%02d-%02d" % [d.year, d.month, d.day]

func _build_daily(cl: Node) -> void:
	var v := _panel(cl)
	dailyp = v.get_parent().get_parent()
	v.add_theme_constant_override("separation", 24)
	_label("GÜNLÜK MEYDAN OKUMA", 80, v, Color(1, 0.75, 0.2))
	daily_info = _label("", 40, v)
	daily_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	daily_info.custom_minimum_size = Vector2(900, 0)
	nick_edit = LineEdit.new()
	nick_edit.placeholder_text = "Takma ad (2-16 harf)"
	nick_edit.max_length = 16
	nick_edit.custom_minimum_size = Vector2(720, 100)
	nick_edit.add_theme_font_size_override("font_size", 46)
	nick_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	nick_edit.text_changed.connect(func(tx: String) -> void:
		nickname = tx.strip_edges()
		_save())
	v.add_child(nick_edit)
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new(); sb.bg_color = Color(0.08, 0.1, 0.25, 0.85); sb.set_corner_radius_all(30)
	sb.content_margin_left = 30; sb.content_margin_right = 30; sb.content_margin_top = 20; sb.content_margin_bottom = 20
	pc.add_theme_stylebox_override("panel", sb)
	pc.custom_minimum_size = Vector2(900, 700)
	v.add_child(pc)
	daily_list = Label.new()
	daily_list.add_theme_font_size_override("font_size", 36)
	daily_list.add_theme_font_override("font", bold)
	pc.add_child(daily_list)
	_btn("OYNA", Color(0.1, 0.7, 0.45), v, func() -> void: _fade(start_daily))
	_btn("Geri", Color(0.3, 0.3, 0.5), v, _show_menu).custom_minimum_size = Vector2(720, 90)
	dailyp.visible = false
	lb_http = HTTPRequest.new()
	add_child(lb_http)
	lb_http.request_completed.connect(_on_lb)
	post_http = HTTPRequest.new()
	add_child(post_http)
	post_http.request_completed.connect(func(_r: int, _c: int, _h: PackedStringArray, _b: PackedByteArray) -> void: _fetch_lb())

func _show_daily() -> void:
	daily_day = _today()
	mapp.visible = false
	menu.visible = false
	result.visible = false
	hud.visible = false
	loadout.visible = false
	dailyp.visible = true
	nick_edit.text = nickname
	var best: int = daily_best.get(daily_day, 0)
	daily_info.text = "%s · Herkese aynı bölüm. Kaleyi EN AZ atışla yık!\nKartlar sabit: Savaşçı, Okçu, Savaşçı.  Senin en iyin: %s" % [daily_day, str(best) if best > 0 else "-"]
	daily_list.text = "Türkiye sıralaması yükleniyor..."
	_fetch_lb()

func _fetch_lb() -> void:
	lb_http.cancel_request()
	lb_http.request(API + "/daily?day=" + daily_day)

func _on_lb(_r: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if code != 200:
		daily_list.text = "Sıralama şu an alınamadı."
		return
	var data = JSON.parse_string(body.get_string_from_utf8())
	if typeof(data) != TYPE_ARRAY or data.size() == 0:
		daily_list.text = "TÜRKİYE SIRALAMASI (bugün)\n\nHenüz skor yok — ilk sen ol!"
		return
	var lines := ["TÜRKİYE SIRALAMASI (bugün)  — az atış = iyi", ""]
	var i := 1
	for row in data:
		if i > 12: break
		lines.append("%2d. %-16s %4d atış" % [i, str(row["nick"]), int(row["score"])])
		i += 1
	daily_list.text = "\n".join(lines)

func _post_score(score: int) -> void:
	if test_run or nickname.length() < 2: return
	posts_sent += 1
	var body := JSON.stringify({"day": daily_day, "nick": nickname, "score": score})
	post_http.cancel_request()
	post_http.request(API + "/score", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)

func _refresh_menu() -> void:
	lbl_coins.text = "Coin: %d" % coins
	if map_coins: map_coins.text = "Coin: %d" % coins
	for i in map_nodes.size():
		var b: Button = map_nodes[i]["b"]
		b.disabled = i >= unlocked
		var sv: int = stars_best.get(i, 0)
		for k in 3:
			(map_nodes[i]["stars"][k] as Polygon2D).color = Color(1.0, 0.82, 0.15) if k < sv else Color(0.3, 0.28, 0.4)
	for i in lvl_btns.size():
		var b: Button = lvl_btns[i]
		b.disabled = i >= unlocked
		b.text = ("Bölüm %d" % (i + 1)) if i < unlocked else ("Bölüm %d  (kilitli)" % (i + 1))
	var cost := _up_cost()
	up_btn.text = "Atış Hızı Sv.%d: %d coin" % [rate_lv + 1, cost]
	up_btn.disabled = coins < cost or rate_lv >= 10

func _up_cost() -> int:
	return 60 * (rate_lv + 1)

func _on_upgrade() -> void:
	var cost := _up_cost()
	if coins >= cost and rate_lv < 10:
		coins -= cost
		rate_lv += 1
		_save()
		_refresh_menu()

func _save() -> void:
	var c := ConfigFile.new()
	c.set_value("p", "coins", coins)
	c.set_value("p", "unlocked", unlocked)
	c.set_value("p", "rate_lv", rate_lv)
	c.set_value("p", "hint", hint_seen)
	c.set_value("p", "owned", owned)
	c.set_value("p", "card_lv", card_lv)
	c.set_value("p", "slots", slots)
	c.set_value("p", "ads_n", levels_since_ad)
	c.set_value("p", "nick", nickname)
	c.set_value("p", "daily_best", daily_best)
	c.set_value("p", "opt", opt)
	c.set_value("p", "stars", stars_best)
	c.save("user://save.cfg")

func _load() -> void:
	var c := ConfigFile.new()
	if c.load("user://save.cfg") == OK:
		coins = c.get_value("p", "coins", 0)
		unlocked = c.get_value("p", "unlocked", 1)
		rate_lv = c.get_value("p", "rate_lv", 0)
		hint_seen = c.get_value("p", "hint", false)
		owned = c.get_value("p", "owned", owned)
		card_lv = c.get_value("p", "card_lv", card_lv)
		slots = c.get_value("p", "slots", slots)
		levels_since_ad = c.get_value("p", "ads_n", 0)
		nickname = c.get_value("p", "nick", "")
		daily_best = c.get_value("p", "daily_best", {})
		opt = c.get_value("p", "opt", opt)
		stars_best = c.get_value("p", "stars", {})

func _bench_report() -> void:
	var a: Array = ft.slice(int(ft.size() * 0.15))
	var s := 0.0
	var mx := 0.0
	var spikes := 0
	for d in a:
		s += d; mx = maxf(mx, d)
		if d > 0.05: spikes += 1
	a.sort()
	var p99: float = a[int(a.size() * 0.99)]
	var cs := 0.0
	var cm := 0.0
	for u in cpu_us:
		cs += u; cm = maxf(cm, u)
	print("SIM avg_ms=%.2f max_ms=%.2f" % [cs / cpu_us.size() / 1000.0, cm / 1000.0])
	print("BENCH frames=%d avg_fps=%.1f p99_ms=%.2f max_ms=%.2f spikes50=%d max_units=%d enemies=%d" % [a.size(), a.size() / s, p99 * 1000, mx * 1000, spikes, max_units, ex.size()])
	get_tree().quit()

# ================= v6: canli dunya / kabuk =================
const BIOMES := [
	{"name": "ÇAYIR", "ground": Color(0.36, 0.72, 0.28), "dirt": Color(0.5, 0.38, 0.28), "path": Color(0.78, 0.55, 0.36), "tile": Color(0.7, 0.47, 0.3),
		"trees": ["res://assets/nature/tree_default.glb", "res://assets/nature/tree_oak.glb", "res://assets/nature/tree_pineRoundC.glb", "res://assets/nature/tree_detailed.glb"],
		"bush": ["res://assets/nature/plant_bushLarge.glb", "res://assets/nature/plant_bush.glb"],
		"deco": ["res://assets/nature/flower_redA.glb", "res://assets/nature/flower_yellowA.glb", "res://assets/nature/flower_purpleA.glb", "res://assets/nature/grass_large.glb"],
		"rocks": ["res://assets/nature/rock_tallB.glb"], "snow": 0.0, "dry": 0.0,
		"sky": Color(0.22, 0.5, 0.95), "hor": Color(0.72, 0.86, 1.0), "deep": Color(0.08, 0.38, 0.78), "shallow": Color(0.25, 0.78, 0.95),
		"pcol": Color(0.55, 0.8, 0.25), "pgrav": Vector3(0.5, -0.7, 0.0), "sun": Color(1.0, 0.92, 0.78)},
	{"name": "KANYON", "ground": Color(0.8, 0.6, 0.38), "dirt": Color(0.66, 0.38, 0.24), "path": Color(0.82, 0.5, 0.3), "tile": Color(0.7, 0.4, 0.24),
		"trees": ["res://assets/nature/cactus_tall.glb", "res://assets/nature/cactus_short.glb", "res://assets/nature/rock_largeA.glb", "res://assets/nature/stone_tallB.glb"],
		"bush": ["res://assets/nature/cactus_short.glb", "res://assets/nature/plant_bush.glb"],
		"deco": ["res://assets/nature/rock_largeC.glb", "res://assets/nature/stone_tallB.glb", "res://assets/nature/grass_large.glb"],
		"rocks": ["res://assets/nature/rock_tallB.glb", "res://assets/nature/stone_tallB.glb"], "snow": 0.0, "dry": 0.45,
		"sky": Color(0.3, 0.55, 0.92), "hor": Color(0.95, 0.85, 0.72), "deep": Color(0.04, 0.45, 0.6), "shallow": Color(0.35, 0.9, 0.85),
		"pcol": Color(0.95, 0.8, 0.55), "pgrav": Vector3(2.0, -0.15, 0.0), "sun": Color(1.0, 0.86, 0.66)},
	{"name": "KARLI DAĞ", "ground": Color(0.9, 0.94, 1.0), "dirt": Color(0.5, 0.55, 0.66), "path": Color(0.74, 0.6, 0.5), "tile": Color(0.63, 0.5, 0.42),
		"trees": ["res://assets/nature/tree_pineTallA_detailed.glb", "res://assets/nature/tree_pineDefaultA.glb", "res://assets/nature/tree_pineRoundC.glb", "res://assets/td/snow-detail-tree-large.glb"],
		"bush": ["res://assets/nature/plant_bush.glb", "res://assets/nature/rock_largeC.glb"],
		"deco": ["res://assets/nature/rock_largeC.glb", "res://assets/nature/log_large.glb", "res://assets/nature/stone_tallB.glb", "res://assets/nature/plant_bush.glb"],
		"rocks": ["res://assets/nature/rock_tallB.glb", "res://assets/nature/stone_tallB.glb"], "snow": 1.0, "dry": 0.0,
		"sky": Color(0.38, 0.55, 0.82), "hor": Color(0.86, 0.92, 1.0), "deep": Color(0.07, 0.28, 0.48), "shallow": Color(0.45, 0.72, 0.9),
		"pcol": Color(1.0, 1.0, 1.0), "pgrav": Vector3(0.3, -1.3, 0.0), "sun": Color(0.95, 0.97, 1.0)},
]
const MENU_L := {"ammo": 99999, "time": 99999.0, "sections": [{"hp": 99999999, "spawn": 1.1, "brute": 0.15, "gates": [[-10.0, -2.2, 4.0, "x2", 0.0], [-10.0, 2.2, 4.0, "x3", 0.0], [-20.0, 0.0, 4.0, "okcu", 1.5]]}]}

const WIND_SHADER := """
shader_type spatial;
render_mode cull_disabled;
uniform vec3 albedo = vec3(1.0);
uniform float sway = 0.0;
uniform float biome_snow = 0.0;
uniform float biome_dry = 0.0;
void vertex() {
	vec3 wp = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	float h = max(VERTEX.y, 0.0);
	float w = sin(TIME * 1.7 + wp.x * 0.35 + wp.z * 0.25) + 0.4 * sin(TIME * 3.3 + wp.z * 0.7);
	VERTEX.x += w * sway * h * h;
	VERTEX.z += w * sway * 0.5 * h * h;
}
void fragment() {
	vec3 c = albedo;
	float g = step(c.r, c.g) * step(c.b, c.g);
	c = mix(c, c * vec3(1.25, 0.95, 0.45) + vec3(0.12, 0.08, 0.0), biome_dry * g);
	vec3 wn = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	c = mix(c, vec3(0.93, 0.96, 1.0), biome_snow * smoothstep(0.3, 0.75, wn.y));
	ALBEDO = c;
	ROUGHNESS = 0.85;
}
"""
const SEA_SHADER := """
shader_type spatial;
uniform vec3 deep : source_color = vec3(0.08, 0.38, 0.78);
uniform vec3 shallow : source_color = vec3(0.25, 0.78, 0.95);
uniform float edge_x = 21.5;
uniform float zmin = -200.0;
uniform float zmax = 14.0;
varying vec3 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float hsh(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float nz(vec2 p) { vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hsh(i), hsh(i + vec2(1.0, 0.0)), f.x), mix(hsh(i + vec2(0.0, 1.0)), hsh(i + vec2(1.0, 1.0)), f.x), f.y); }
void fragment() {
	float dx = max(abs(wp.x) - edge_x, 0.0);
	float dz = max(max(wp.z - zmax, zmin - wp.z), 0.0);
	float d = length(vec2(dx, dz));
	float n = nz(wp.xz * 0.3 + vec2(TIME * 0.35, TIME * 0.2)) * 0.6 + nz(wp.xz * 1.1 - vec2(TIME * 0.5)) * 0.4;
	float band = 0.5 + 0.5 * sin(d * 2.4 - TIME * 2.2 + n * 3.0);
	float foam = smoothstep(4.0, 0.3, d) * smoothstep(0.55, 0.85, n * 0.6 + band * 0.55) + smoothstep(0.9, 0.0, d);
	vec3 c = mix(shallow, deep, smoothstep(0.0, 16.0, d));
	c += vec3(0.07) * smoothstep(0.6, 0.85, n);
	ALBEDO = mix(c, vec3(0.97, 1.0, 1.0), clamp(foam, 0.0, 1.0));
	ROUGHNESS = 0.12;
	METALLIC = 0.15;
	SPECULAR = 0.7;
}
"""
const FLAG_SHADER := """
shader_type spatial;
render_mode cull_disabled;
uniform vec3 col : source_color;
void vertex() {
	float u = UV.x;
	VERTEX.z += sin(TIME * 6.0 - u * 6.0) * 0.22 * u;
	VERTEX.y += sin(TIME * 4.0 - u * 5.0) * 0.05 * u;
}
void fragment() { ALBEDO = col * (0.75 + 0.25 * sin(UV.x * 6.0 - TIME * 6.0)); ROUGHNESS = 0.9; }
"""
const RAY_SHADER := """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;
uniform float a = 0.1;
void fragment() {
	float f = (1.0 - UV.y) * smoothstep(0.0, 0.35, UV.x) * smoothstep(1.0, 0.65, UV.x);
	ALBEDO = vec3(1.0, 0.95, 0.8);
	ALPHA = f * a * (0.7 + 0.3 * sin(TIME * 0.6 + UV.x * 4.0));
}
"""

func _wind_mat(c: Color, sway: float) -> ShaderMaterial:
	if wind_sh == null:
		wind_sh = Shader.new()
		wind_sh.code = WIND_SHADER
	var m := ShaderMaterial.new()
	m.shader = wind_sh
	m.set_shader_parameter("albedo", Vector3(c.srgb_to_linear().r, c.srgb_to_linear().g, c.srgb_to_linear().b))
	m.set_shader_parameter("sway", sway)
	m.set_shader_parameter("biome_snow", BIOMES[biome]["snow"])
	m.set_shader_parameter("biome_dry", BIOMES[biome]["dry"])
	wind_mats.append(m)
	return m

func _build_alive() -> void:
	# carpisma zemini (fizik parcalari icin)
	var fl := StaticBody3D.new()
	var fcs := CollisionShape3D.new()
	fcs.shape = WorldBoundaryShape3D.new()
	fl.add_child(fcs)
	add_child(fl)
	# kuslar + kelebekler
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for k in 6:
		birds.append({"n": _mk_flyer(Color(0.95, 0.95, 0.98), 0.9), "ph": rng.randf() * TAU, "sp": rng.randf_range(0.25, 0.45), "h": rng.randf_range(13, 19),
			"r": rng.randf_range(10, 18), "dz": rng.randf_range(-20, 10), "cx": 0.0, "fl": rng.randf_range(8, 11), "bf": false})
	for k in 7:
		var bc: Color = [Color(1.0, 0.85, 0.2), Color(1.0, 0.45, 0.8), Color(0.5, 0.8, 1.0), Color(1.0, 1.0, 1.0)][k % 4]
		birds.append({"n": _mk_flyer(bc, 0.35), "ph": rng.randf() * TAU, "sp": rng.randf_range(0.6, 1.1), "h": rng.randf_range(1.0, 2.2),
			"r": rng.randf_range(1.5, 3.0), "dz": rng.randf_range(-16, 4), "cx": (-1.0 if k % 2 == 0 else 1.0) * rng.randf_range(7, 12), "fl": rng.randf_range(16, 22), "bf": true})
	# ortam parcaciklari (yaprak / kum / kar)
	amb_parts = CPUParticles3D.new()
	amb_parts.amount = 90
	amb_parts.lifetime = 7.0
	amb_parts.preprocess = 7.0
	amb_parts.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	amb_parts.emission_box_extents = Vector3(24, 7, 24)
	amb_parts.direction = Vector3(1, 0, 0)
	amb_parts.spread = 180
	amb_parts.initial_velocity_min = 0.1
	amb_parts.initial_velocity_max = 0.6
	amb_parts.angular_velocity_min = -180
	amb_parts.angular_velocity_max = 180
	amb_parts.scale_amount_min = 0.6
	amb_parts.scale_amount_max = 1.3
	var qm := QuadMesh.new()
	qm.size = Vector2(0.2, 0.14)
	var am := StandardMaterial3D.new()
	am.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	am.vertex_color_use_as_albedo = true
	am.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	am.cull_mode = BaseMaterial3D.CULL_DISABLED
	qm.material = am
	amb_parts.mesh = qm
	add_child(amb_parts)
	# isik huzmeleri (kameraya bagli, ucuz)
	var rs := Shader.new()
	rs.code = RAY_SHADER
	for k in 3:
		var rq := QuadMesh.new()
		rq.size = Vector2(5.0 + k * 2.0, 60.0)
		var rm := ShaderMaterial.new()
		rm.shader = rs
		rm.set_shader_parameter("a", 0.07)
		var r := _mesh(rq, Vector3(-14.0 + k * 7.0, 14.0, -40.0), rm, cam, Vector3(0, 0, deg_to_rad(28.0)), false)
		rays.append(r)

func _mk_flyer(col: Color, s: float) -> Node3D:
	var b := Node3D.new()
	add_child(b)
	var m := _mat(col, 0.15)
	_box(Vector3(0.25, 0.12, 0.5) * s, Vector3.ZERO, m, b, false)
	for sd in [-1, 1]:
		var piv := Node3D.new()
		b.add_child(piv)
		_box(Vector3(0.9, 0.04, 0.45) * s, Vector3(sd * 0.5 * s, 0, 0), m, piv, false)
	return b

func _alive(dt: float) -> void:
	if clouds:
		clouds.position.x = sin(t * 0.05) * 10.0
		clouds.position.z = fmod(t * 0.8, 12.0)
	var meadow := biome == 0
	for bd in birds:
		var b: Node3D = bd["n"]
		if bd["bf"] and not meadow:
			b.visible = false
			continue
		b.visible = true
		var a: float = t * bd["sp"] + bd["ph"]
		var c := Vector3(bd["cx"], bd["h"], cam.position.z - 26.0 + bd["dz"])
		b.position = c + Vector3(cos(a) * bd["r"], sin(t * 0.9 + bd["ph"]) * (0.6 if bd["bf"] else 1.2), sin(a) * bd["r"] * 0.6)
		b.rotation.y = -a
		var f: float = sin(t * bd["fl"] + bd["ph"]) * (1.0 if bd["bf"] else 0.6)
		(b.get_child(1) as Node3D).rotation.z = f
		(b.get_child(2) as Node3D).rotation.z = -f
	if amb_parts:
		amb_parts.position = cam.position + Vector3(0, -2.0, -18.0)
	if logo and menu.visible:
		logo.scale = Vector2.ONE * (1.0 + 0.035 * sin(t * 2.4))

func _flag(parent: Node3D, pos: Vector3, col: Color) -> void:
	if flag_sh == null:
		flag_sh = Shader.new()
		flag_sh.code = FLAG_SHADER
	_cyl(0.06, 0.06, 2.6, pos + Vector3(0, 1.3, 0), _mat(Color(0.35, 0.28, 0.2), 0.0), parent)
	var q := QuadMesh.new()
	q.size = Vector2(1.6, 0.95)
	q.subdivide_width = 10
	q.subdivide_depth = 2
	var sm := ShaderMaterial.new()
	sm.shader = flag_sh
	sm.set_shader_parameter("col", col)
	_mesh(q, pos + Vector3(0.8, 2.05, 0), sm, parent, Vector3.ZERO, false)

func _torch(parent: Node3D, pos: Vector3) -> void:
	_cyl(0.07, 0.1, 0.7, pos, _mat(Color(0.35, 0.22, 0.12), 0.0), parent)
	_mesh(SphereMesh.new(), pos + Vector3(0, 0.42, 0), _mat(Color(1.0, 0.7, 0.2), 4.0), parent, Vector3.ZERO, false).scale = Vector3.ONE * 0.22
	if fire_mesh == null:
		var fm := StandardMaterial3D.new()
		fm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fm.vertex_color_use_as_albedo = true
		fm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		fm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		fire_mesh = QuadMesh.new()
		fire_mesh.size = Vector2(0.35, 0.35)
		fire_mesh.material = fm
	var p := CPUParticles3D.new()
	p.mesh = fire_mesh
	p.amount = 14
	p.lifetime = 0.55
	p.direction = Vector3.UP
	p.spread = 18
	p.initial_velocity_min = 0.6
	p.initial_velocity_max = 1.5
	p.gravity = Vector3(0, 1.2, 0)
	p.scale_amount_min = 0.7
	p.scale_amount_max = 1.4
	var gr := Gradient.new()
	gr.set_color(0, Color(1.0, 0.95, 0.5, 1.0))
	gr.set_color(1, Color(1.0, 0.2, 0.05, 0.0))
	gr.add_point(0.4, Color(1.0, 0.5, 0.1, 0.85))
	p.color_ramp = gr
	p.position = pos + Vector3(0, 0.45, 0)
	parent.add_child(p)

func _crumble(bn: Node3D) -> void:
	var stone := _mat(Color(0.78, 0.74, 0.68), 0.0, 1.0, 0.0, 0.9)
	var roof := _mat(Color(0.72, 0.24, 0.2), 0.0, 1.0, 0.0, 0.8)
	var cnt := 22 if opt["shadows"] else 14
	var s: float = bn.scale.x
	for k in cnt:
		var rb := RigidBody3D.new()
		var sz := Vector3(randf_range(0.5, 1.1), randf_range(0.4, 0.9), randf_range(0.5, 1.0)) * s
		var cs := CollisionShape3D.new()
		var bsh := BoxShape3D.new()
		bsh.size = sz
		cs.shape = bsh
		rb.add_child(cs)
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = sz
		mi.mesh = bm
		mi.material_override = roof if k % 5 == 0 else stone
		rb.add_child(mi)
		rb.position = bn.global_position + Vector3(randf_range(-4.5, 4.5) * s, randf_range(1.0, 6.0) * s, randf_range(-1.0, 1.5))
		rb.rotation = Vector3(randf(), randf(), randf()) * TAU
		level_root.add_child(rb)
		rb.apply_central_impulse(Vector3(randf_range(-5, 5), randf_range(3, 8), randf_range(2, 7)) * rb.mass)
		rb.angular_velocity = Vector3(randf_range(-6, 6), randf_range(-6, 6), randf_range(-6, 6))
		var tw := rb.create_tween()
		tw.tween_interval(2.6)
		tw.tween_property(mi, "scale", Vector3.ONE * 0.01, 0.5)
		tw.tween_callback(rb.queue_free)
	for k in 10:
		puff(bn.global_position + Vector3(randf_range(-4.5, 4.5), randf_range(0.3, 3.5), randf_range(0.0, 2.0)))

func _hitstop(final: bool) -> void:
	if bench: return
	Engine.time_scale = 0.02
	await get_tree().create_timer(0.12, true, false, true).timeout
	Engine.time_scale = 0.3 if final else 1.0
	if final:
		await get_tree().create_timer(1.1, true, false, true).timeout
		Engine.time_scale = 1.0

func _punch(a: float) -> void:
	if cam == null: return
	cam.fov = 64.0 - a * 0.4
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(cam, "fov", 64.0, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _vib(ms: int) -> void:
	if opt["vib"] and (OS.has_feature("android") or OS.has_feature("web_android")):
		Input.vibrate_handheld(ms)

func _combo(txt: String) -> void:
	if menu_mode: return
	var l := Label.new()
	l.text = txt
	l.add_theme_font_override("font", bold)
	l.add_theme_font_size_override("font_size", 140)
	l.add_theme_color_override("font_color", Color(1.0, 0.86, 0.2))
	l.add_theme_color_override("font_outline_color", Color(0.45, 0.08, 0.0))
	l.add_theme_constant_override("outline_size", 40)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	l.add_theme_constant_override("shadow_offset_y", 12)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.anchor_right = 1.0
	l.offset_top = 520
	l.offset_bottom = 720
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(l)
	l.pivot_offset = Vector2(get_viewport().get_visible_rect().size.x * 0.5, 100)
	l.rotation = deg_to_rad(randf_range(-7, 7))
	l.scale = Vector2.ONE * 0.2
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(l, "scale", Vector2.ONE * 1.25, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "scale", Vector2.ONE, 0.1)
	tw.tween_interval(0.45)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)
	tw.parallel().tween_property(l, "offset_top", 440.0, 0.3)
	tw.tween_callback(l.queue_free)
	sfx("combo", -4.0, 0.2, 0.0)
	_punch(4.0)
	_vib(40)

func _coin_burst(wp: Vector3, n: int) -> void:
	if menu_mode or hud_coin == null or bench: return
	var sp := cam.unproject_position(wp)
	var tgt := hud_coin.get_global_rect().get_center()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.82, 0.15)
	sb.set_corner_radius_all(24)
	sb.border_color = Color(0.7, 0.45, 0.0)
	sb.set_border_width_all(5)
	for k in n:
		var c := Panel.new()
		c.add_theme_stylebox_override("panel", sb)
		c.size = Vector2(48, 48)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.position = sp + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		ui_layer.add_child(c)
		var mid := sp + Vector2(randf_range(-200, 200), randf_range(-260, -60))
		var tw := create_tween().set_ignore_time_scale(true)
		tw.tween_property(c, "position", mid, 0.28).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(c, "position", tgt - Vector2(24, 24), 0.42 + k * 0.04).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tw.tween_callback(func() -> void:
			c.queue_free()
			sfx("coin", -12.0, 0.03, 0.2)
			hud_coin.text = str(coins))

func _fade(cb: Callable) -> void:
	if fader == null or bench:
		cb.call()
		return
	fader.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(fader, "color:a", 1.0, 0.16)
	tw.tween_callback(cb)
	tw.tween_property(fader, "color:a", 0.0, 0.3)
	tw.tween_callback(func() -> void: fader.mouse_filter = Control.MOUSE_FILTER_IGNORE)

func _music(which: int) -> void:
	cur_music = which
	if music_menu == null or bench: return
	var on: AudioStreamPlayer = music_menu if which == 0 else music_battle
	var off: AudioStreamPlayer = music_battle if which == 0 else music_menu
	if not on.playing:
		on.volume_db = -40.0
		on.play()
	var tw := create_tween().set_ignore_time_scale(true)
	tw.tween_property(on, "volume_db", -10.0 if opt["music"] else -80.0, 0.8)
	tw.parallel().tween_property(off, "volume_db", -80.0, 0.8)
	tw.tween_callback(off.stop)

func _enter_menu() -> void:
	Engine.time_scale = 1.0
	result.visible = false
	hud.visible = false
	loadout.visible = false
	dailyp.visible = false
	mapp.visible = false
	settingsp.visible = false
	if not menu_mode:
		menu_mode = true
		daily = false
		_start(MENU_L, 0)
		hud.visible = false
	menu.visible = true
	_refresh_menu()
	_music(0)

func _star(parent: Node, r: float, col: Color, pos: Vector2) -> Polygon2D:
	var pts := PackedVector2Array()
	for k in 10:
		var a := -PI / 2 + k * PI / 5
		var rr := r if k % 2 == 0 else r * 0.45
		pts.append(Vector2(cos(a), sin(a)) * rr)
	var o := Polygon2D.new()
	var po := PackedVector2Array()
	for p in pts: po.append(p * 1.22)
	o.polygon = po
	o.color = Color(0.05, 0.03, 0.15, 0.9)
	o.position = pos
	parent.add_child(o)
	var s := Polygon2D.new()
	s.polygon = pts
	s.color = col
	o.add_child(s)
	return s

func _build_logo(parent: Node) -> void:
	logo = Control.new()
	logo.custom_minimum_size = Vector2(1000, 360)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(logo)
	var words := [["RIFT", CYAN, 0.0], ["RUSH", Color(1.0, 0.62, 0.1), 165.0]]
	for w in words:
		var l := Label.new()
		l.text = w[0]
		l.add_theme_font_override("font", bold)
		l.add_theme_font_size_override("font_size", 210)
		l.add_theme_color_override("font_color", w[1])
		l.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.25))
		l.add_theme_constant_override("outline_size", 54)
		l.add_theme_color_override("font_shadow_color", Color(0.02, 0.0, 0.08, 0.85))
		l.add_theme_constant_override("shadow_offset_x", 10)
		l.add_theme_constant_override("shadow_offset_y", 18)
		l.add_theme_constant_override("shadow_outline_size", 54)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.position = Vector2(0, w[2])
		l.size = Vector2(1000, 220)
		logo.add_child(l)
	logo.pivot_offset = Vector2(500, 180)
	logo.rotation = deg_to_rad(-4.0)

func _build_map(cl: Node) -> void:
	mapp = Control.new()
	mapp.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(mapp)
	var bg := TextureRect.new()
	var gt := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array([0.0, 0.3, 0.38, 0.62, 0.7, 1.0])
	gr.colors = PackedColorArray([Color(0.62, 0.75, 0.95), Color(0.8, 0.88, 1.0), Color(0.95, 0.72, 0.42), Color(0.88, 0.6, 0.35), Color(0.45, 0.78, 0.35), Color(0.25, 0.6, 0.25)])
	gt.gradient = gr
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 256
	bg.texture = gt
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.modulate.a = 0.93
	mapp.add_child(bg)
	var board := Control.new()
	board.anchor_left = 0.5
	board.anchor_right = 0.5
	board.offset_left = -540
	board.offset_right = 540
	board.offset_bottom = 1920
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mapp.add_child(board)
	var tl := _label("HARİTA", 96, board, Color(1, 1, 1))
	tl.position = Vector2(0, 50)
	tl.size = Vector2(1080, 120)
	map_coins = _label("", 52, board, Color(1, 0.9, 0.3))
	map_coins.position = Vector2(0, 170)
	map_coins.size = Vector2(1080, 70)
	var xs := [-210.0, 170.0, -120.0, 220.0, -190.0, 120.0]
	var line := Line2D.new()
	line.width = 22
	line.default_color = Color(1, 1, 1, 0.55)
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	board.add_child(line)
	var bnames := ["ÇAYIR", "KANYON", "KARLI DAĞ"]
	for b in 3:
		var bl := _label(bnames[b], 44, board, Color(1, 1, 1, 0.8))
		bl.position = Vector2(0, 1460 - b * 460 - 30)
		bl.size = Vector2(1060, 60)
		bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if b % 2 == 0 else HORIZONTAL_ALIGNMENT_LEFT
	for i in LEVELS.size():
		var c := Vector2(540 + xs[i], 1520 - i * 230)
		line.add_point(c)
		var idx := i
		var b := _btn(str(i + 1), [Color(0.2, 0.7, 0.3), Color(0.9, 0.55, 0.15), Color(0.35, 0.55, 0.95)][i / 2], board, func() -> void: _fade(func() -> void: _show_loadout(idx)))
		b.custom_minimum_size = Vector2(170, 170)
		b.size = Vector2(170, 170)
		b.position = c - Vector2(85, 85)
		b.add_theme_font_size_override("font_size", 80)
		for st in ["normal", "hover", "pressed", "disabled"]:
			var sbx: StyleBoxFlat = (b.get_theme_stylebox(st) as StyleBoxFlat).duplicate()
			sbx.set_corner_radius_all(85)
			sbx.set_border_width_all(10)
			b.add_theme_stylebox_override(st, sbx)
		var stars: Array = []
		for k in 3:
			stars.append(_star(board, 24, Color(0.3, 0.28, 0.4), c + Vector2((k - 1) * 56, 118 - (8 if k == 1 else 0))))
		map_nodes.append({"b": b, "stars": stars})
	up_btn = _btn("", Color(0.55, 0.2, 0.9), board, _on_upgrade)
	up_btn.custom_minimum_size = Vector2(720, 100)
	up_btn.size = Vector2(720, 100)
	up_btn.position = Vector2(180, 1730)
	var back := _btn("Geri", Color(0.3, 0.3, 0.5), board, _show_menu)
	back.custom_minimum_size = Vector2(220, 90)
	back.size = Vector2(220, 90)
	back.position = Vector2(30, 60)
	mapp.visible = false

func _show_map() -> void:
	_fade(func() -> void:
		menu.visible = false
		loadout.visible = false
		dailyp.visible = false
		result.visible = false
		mapp.visible = true
		_refresh_menu())

func _build_settings(cl: Node) -> void:
	var v := _panel(cl)
	settingsp = v.get_parent().get_parent()
	_label("AYARLAR", 100, v, CYAN)
	for k in ["sfx", "music", "vib", "shadows"]:
		set_btns[k] = _btn("", Color(0.2, 0.45, 0.8), v, _toggle_opt.bind(k))
	_btn("Geri", Color(0.3, 0.3, 0.5), v, func() -> void:
		settingsp.visible = false
		menu.visible = true)
	settingsp.visible = false

func _toggle_opt(k: String) -> void:
	opt[k] = not opt[k]
	_apply_opts()
	_save()
	_refresh_settings()

func _refresh_settings() -> void:
	var names := {"sfx": "Ses efektleri", "music": "Müzik", "vib": "Titreşim", "shadows": "Gölge & yüksek kalite"}
	for k in set_btns:
		var b: Button = set_btns[k]
		var on: bool = opt[k]
		b.text = "%s: %s" % [names[k], "AÇIK" if on else "KAPALI"]
		var c := Color(0.12, 0.65, 0.4) if on else Color(0.35, 0.35, 0.45)
		b.add_theme_stylebox_override("normal", _style(c))
		b.add_theme_stylebox_override("hover", _style(c.lightened(0.15)))

func _show_settings() -> void:
	menu.visible = false
	settingsp.visible = true
	_refresh_settings()

func _apply_opts() -> void:
	if sun: sun.shadow_enabled = opt["shadows"]
	if envr: envr.glow_enabled = opt["shadows"]
	_music(cur_music)

func _anim_win(st: int) -> float:
	stars_box.visible = true
	for k in 3:
		var p: Polygon2D = res_stars[k]
		p.color = Color(0.3, 0.27, 0.4)
		p.scale = Vector2.ONE
	var tw := create_tween()
	for k in st:
		var p: Polygon2D = res_stars[k]
		tw.tween_interval(0.1)
		tw.tween_callback(func() -> void:
			p.color = Color(1.0, 0.82, 0.15)
			p.scale = Vector2.ONE * 1.6
			sfx("star", -6.0, 0.0, 0.1)
			_vib(25))
		tw.tween_property(p, "scale", Vector2.ONE, 0.08).set_trans(Tween.TRANS_BACK)
	var e := earned + kale_coins
	var base := coins - e
	var wl := win_lines
	tw.tween_method(func(v: float) -> void: res_info.text = "%s = +%d coin\nToplam: %d" % [wl, int(v), base + int(v)], 0.0, float(e), 0.25)
	return st * 0.18 + 0.25

func _ok(name: String, cond: bool) -> void:
	ft_res.append([name, cond])
	print("FLOW %s: %s" % ["OK  " if cond else "FAIL", name])

func _find_btn(root: Node, prefix: String) -> Button:
	for b in root.find_children("*", "Button", true, false):
		if (b as Button).text.begins_with(prefix) and b.is_visible_in_tree():
			return b
	return null

func _wait(s: float) -> void:
	await get_tree().create_timer(s, true, false, true).timeout

func _flowtest(shot: String) -> void:
	var ads := [0]
	Ads.ad_event.connect(func(kind: String, _s: String) -> void:
		if kind == "interstitial": ads[0] += 1)
	coins = 1000; unlocked = 6; owned = [true, false, false, false]; card_lv = [0, 0, 0, 0]; slots = [0, 0, 0]; levels_since_ad = 0; hint_seen = true
	await _wait(1.0)
	_show_map()
	await _wait(0.8)
	_ok("harita acildi", mapp.visible)
	(map_nodes[2]["b"] as Button).pressed.emit()
	await _wait(0.8)
	_ok("kart ekrani (bolum 3)", loadout.visible and lo_level == 2)
	var bb := _find_btn(card_rows, "Aç: 100")
	_ok("okcu satin al butonu var", bb != null and not bb.disabled)
	if bb: bb.pressed.emit()
	await _wait(0.3)
	_ok("okcu alindi, 100 coin dustu", owned[1] and coins == 900)
	var ub := _find_btn(card_rows, "Sv.2: 80")
	if ub: ub.pressed.emit()
	await _wait(0.3)
	_ok("savasci Sv.2, 80 coin dustu", int(card_lv[0]) == 1 and coins == 820)
	(slot_btns[1] as Button).pressed.emit()
	await _wait(0.2)
	_ok("slot 2 -> Okcu", int(slots[1]) == 1)
	var sb := _find_btn(loadout, "SAVAŞA BAŞLA")
	sb.pressed.emit()
	await _wait(1.2)
	_ok("oyun basladi (bolum 3, kanyon)", playing and not menu_mode and level == 2 and biome == 1)
	holding = true
	await _wait(2.0)
	_ok("top kartlari sirayla atiyor (okcu var)", ptype.has(1) or shots_fired > 0)
	holding = false
	_lose("test")
	await _wait(0.5)
	_ok("yenilgide 'Devam et' gorunur", btn_revive.visible)
	var a0 := ammo
	btn_revive.pressed.emit()
	await _wait(0.4)
	_ok("revive: oyun devam, +50 mermi", playing and ammo == a0 + 50 and not result.visible)
	_lose("test2")
	await _wait(0.4)
	_ok("ikinci yenilgide revive yok", not btn_revive.visible)
	btn_next.pressed.emit()
	await _wait(1.0)
	_ok("tekrar dene calisti", playing)
	ammo = 300
	var guard := 0
	while playing and guard < 40:
		base_hp = 0
		guard += 1
		await _wait(0.6)
	await _wait(4.2)
	_ok("zafer ekrani + yildiz", result.visible and res_title.text == "ZAFER!" and stars_box.visible)
	if shot != "":
		get_viewport().get_texture().get_image().save_png(shot)
	_ok("bolum 4 acildi", unlocked >= 4)
	btn_next.pressed.emit()
	await _wait(0.8)
	_ok("3. bolumden sonra reklam YOK", ads[0] == 0 and loadout.visible)
	level = 1; levels_since_ad = 9
	_maybe_interstitial(func() -> void: pass)
	_ok("ilk 3 bolumde asla reklam", ads[0] == 0)
	level = 3; levels_since_ad = 3
	_maybe_interstitial(func() -> void: pass)
	_ok("4. bolum sonrasi 1 reklam", ads[0] == 1 and levels_since_ad == 0)
	_maybe_interstitial(func() -> void: pass)
	_ok("hemen ardindan reklam yok (3 bolum bekle)", ads[0] == 1)
	# gunluk skor gonderimi
	nickname = "flowtest_bot"
	_show_daily()
	await _wait(1.5)
	(_find_btn(dailyp, "OYNA") as Button).pressed.emit()
	await _wait(1.0)
	_ok("gunluk basladi", playing and daily)
	shots_fired = 4321
	base_hp = 0
	await _wait(4.0)
	_ok("gunluk zafer", result.visible and daily_best.get(daily_day, 0) == 4321)
	await _wait(2.5)
	btn_next.pressed.emit()
	await _wait(4.0)
	_ok("test kosusu skor GONDERMEDI, siralama okundu", posts_sent == 0 and not daily_list.text.contains("alınamadı"))
	var fails := 0
	for r in ft_res:
		if not r[1]: fails += 1
	print("FLOW DONE %d/%d ok" % [ft_res.size() - fails, ft_res.size()])
	get_tree().quit()


func _autoplay(lv: int) -> void:
	# AP_MODE: smart (varsayilan, eski bot) | casual (gecikmeli/yanilan oyuncu) | hold (ortada basili tut)
	var mode := OS.get_environment("AP_MODE")
	if mode == "": mode = "smart"
	var ts := float(OS.get_environment("AP_TS")) if OS.get_environment("AP_TS") != "" else 2.0
	var shots := mode == "smart" and DisplayServer.get_name() != "headless"
	hint_seen = lv > 0
	rate_lv = 0; card_lv = [0, 0, 0, 0]
	owned = [true, true, false, false]; slots = [0, 0, 1] if lv >= 2 else [0, 0, 0]
	if OS.get_environment("AP_LOADOUT") == "start":
		owned = [true, false, false, false]; slots = [0, 0, 0]
		rate_lv = lv  # yeni oyuncu: her bolumden sonra 1 atis hizi yukseltmesi
	var dir := "/workspace/riftrush-review/"
	start_level(lv)
	Engine.time_scale = ts
	holding = true
	var shot_i := 0
	var t0 := Time.get_ticks_msec()
	var rt := 0.0
	var tgt_x := 0.0
	var tgt_g = null
	while playing:
		await get_tree().process_frame
		Engine.time_scale = ts
		holding = true
		var gdt := get_process_delta_time() * ts
		if mode == "hold":
			cannon_x = 0.0
		elif mode == "casual":
			rt -= gdt
			if rt <= 0.0:
				rt = randf_range(0.4, 0.9)
				tgt_g = null
				var r := randf()
				var bestg = null
				var bz := 99.0
				for g in gates:
					if g["sec"] == sec and not String(g["op"]).begins_with("-") and absf(g["z"]) < bz:
						bz = absf(g["z"]); bestg = g
				var nz := -999.0
				var nx := 0.0
				for j in ex.size():
					if ez[j] > nz: nz = ez[j]; nx = ex[j]
				if r < 0.15 and nz > -12.0:
					tgt_x = nx
				elif r < 0.85 and bestg != null:
					tgt_g = bestg
					tgt_x = 0.0
				else:
					tgt_x = randf_range(-3.0, 3.0)
				tgt_x += randf_range(-0.6, 0.6)
			var want: float = (tgt_g["cx"] + tgt_x) if tgt_g != null else tgt_x
			cannon_x = move_toward(cannon_x, want, 8.0 * gdt)
		else:
			var best := 99.0
			var tx := 0.0
			for g in gates:
				if g["sec"] == sec and String(g["op"]).begins_with("x") and absf(g["z"]) < best:
					best = absf(g["z"]); tx = g["cx"]
			if ex.size() > 0 and randf() < 0.3:
				var nz := -999.0
				for j in ex.size():
					if ez[j] > nz: nz = ez[j]; if nz > -12.0: tx = ex[j]
			cannon_x = move_toward(cannon_x, tx, 0.25)
		if shots and (Time.get_ticks_msec() - t0) > 9000 * (shot_i + 1) and shot_i < 3:
			shot_i += 1
			get_viewport().get_texture().get_image().save_png(dir + "rr8-ap-L%d-%d.png" % [lv + 1, shot_i])
	var used: float = float(cur_L["time"]) - time_left
	await _wait(1.3)
	print("AUTOPLAY mode=%s level=%d result=%s used=%.1fs time_left=%.1f ammo=%d/%d sec=%d/%d base_hp=%d" % [mode, lv + 1, "WIN" if res_title.text == "ZAFER!" else "LOSE", used, time_left, ammo, start_ammo, sec + 1, bases.size(), maxi(base_hp, 0)])
	if shots:
		await _wait(1.7)
		get_viewport().get_texture().get_image().save_png(dir + "rr8-ap-L%d-result.png" % (lv + 1))
	get_tree().quit()
