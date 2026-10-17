extends Node3D
## Rift Rush - MVP v2 (3D gorunum, cok asamali bolumler). Tum sahne kodla kuruluyor.

const LANE := 4.4
const BASE_Z := -38.0
const SEC_LEN := 52.0
const MAXP := 1500
const MAXE := 400
const PSPEED := 7.0
const CYAN := Color(0.15, 0.95, 1.0)
const ENEMY := Color(1.0, 0.38, 0.12)
const PURPLE := Color(0.65, 0.2, 1.0)

# gate: [z, x, genislik, islem, hareket_genligi]
const LEVELS := [
	{"ammo": 80, "time": 100.0, "sections": [
		{"hp": 90, "spawn": 2.6, "brute": 0.0, "gates": [[-10.0, -2.2, 4.0, "x2", 0.0], [-10.0, 2.2, 4.0, "+10", 0.0], [-23.0, 0.0, 3.6, "x3", 1.4]]},
		{"hp": 220, "spawn": 1.9, "brute": 0.1, "gates": [[-9.0, -2.2, 4.0, "x2", 0.0], [-9.0, 2.2, 4.0, "-5", 0.0], [-18.0, 0.0, 3.4, "+10", 2.0], [-27.0, 0.0, 3.6, "x3", 1.2]]}]},
	{"ammo": 100, "time": 120.0, "sections": [
		{"hp": 160, "spawn": 1.8, "brute": 0.05, "gates": [[-9.0, -2.2, 4.0, "x2", 0.0], [-9.0, 2.2, 4.0, "-5", 0.0], [-20.0, 0.0, 3.4, "x3", 1.8]]},
		{"hp": 280, "spawn": 1.4, "brute": 0.12, "gates": [[-8.0, 0.0, 3.2, "+10", 2.2], [-17.0, -2.2, 4.0, "x3", 0.0], [-17.0, 2.2, 4.0, "x2", 0.0], [-27.0, 0.0, 3.0, "-5", 2.4]]},
		{"hp": 520, "spawn": 1.1, "brute": 0.2, "gates": [[-8.0, -2.2, 4.0, "x2", 0.0], [-8.0, 2.2, 4.0, "x2", 0.0], [-18.0, 0.0, 3.2, "x3", 2.4], [-27.0, -2.8, 2.8, "x2", 0.0], [-27.0, 0.0, 2.8, "+10", 0.0], [-27.0, 2.8, 2.8, "-5", 0.0]]}]},
	{"ammo": 120, "time": 140.0, "sections": [
		{"hp": 260, "spawn": 1.2, "brute": 0.12, "gates": [[-8.0, 0.0, 3.0, "-5", 2.6], [-15.0, -2.2, 4.0, "x2", 0.0], [-15.0, 2.2, 4.0, "x2", 0.0], [-25.0, 0.0, 3.0, "x3", 2.4]]},
		{"hp": 480, "spawn": 0.9, "brute": 0.2, "gates": [[-8.0, -2.2, 4.0, "x3", 0.0], [-8.0, 2.2, 4.0, "-5", 0.0], [-18.0, 0.0, 3.0, "x2", 2.6], [-27.0, -2.8, 2.8, "x2", 0.0], [-27.0, 0.0, 2.8, "-5", 1.0], [-27.0, 2.8, 2.8, "+10", 0.0]]},
		{"hp": 1000, "spawn": 0.7, "brute": 0.3, "gates": [[-8.0, 0.0, 3.0, "x2", 2.6], [-16.0, -2.2, 4.0, "x3", 0.0], [-16.0, 2.2, 4.0, "-5", 0.0], [-25.0, 0.0, 3.0, "x2", 2.4]]}]},
]

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

var bench := false
var bench_len := 12.0
var bench_shots: Array = []
var ft: Array = []
var max_units := 0
var cpu_us: Array = []

func _ready() -> void:
	_load()
	await _bake_units()
	_build_world()
	_build_ui()
	for i in 46:
		buckets.append(PackedInt32Array())
	var args := OS.get_cmdline_user_args()
	if args.size() > 0 and args[0] == "bench":
		bench = true
		hint_seen = true
		if args.size() > 1: bench_len = float(args[1])
		for k in range(2, args.size() - 1, 2):
			bench_shots.append([float(args[k]), args[k + 1]])
		start_level(int(OS.get_environment("BENCH_LEVEL")) if OS.get_environment("BENCH_LEVEL") != "" else 2)
		ammo = 99999
		rate_lv = 30
		var mb := InputEventMouseButton.new()
		mb.button_index = MOUSE_BUTTON_LEFT
		mb.pressed = true
		mb.position = Vector2(540, 1200)
		Input.parse_input_event(mb)
	elif args.size() > 1 and args[0] == "menushot":
		await get_tree().create_timer(1.5).timeout
		get_viewport().get_texture().get_image().save_png(args[1])
		get_tree().quit()

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
			st.commit(out)
			out.surface_set_material(out.get_surface_count() - 1, mi.get_active_material(s))
	return out

func _asset_mesh(path: String) -> ArrayMesh:
	if mesh_cache.has(path): return mesh_cache[path]
	var n := _glb(path)
	add_child(n)
	var m := _flatten(n)
	n.queue_free()
	mesh_cache[path] = m
	return m

func _bake_units() -> void:
	var ch := _glb("res://assets/chars/character-male-a.glb")
	add_child(ch)
	var ap: AnimationPlayer = ch.find_child("AnimationPlayer", true, false)
	ap.play("sprint")
	ap.speed_scale = 0.0
	var L := ap.current_animation_length
	for f in NF:
		ap.seek(L * f / NF, true)
		await get_tree().process_frame
		unit_frames.append(_flatten(ch, true))
	unit_mat = (unit_frames[0] as ArrayMesh).surface_get_material(0)
	ch.queue_free()

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
	m.rim = 0.6
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
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows_on else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
	shadows_on = OS.get_environment("SHADOWS") == "1"  # varsayilan kapali (mobil/web performansi)
	var env := Environment.new()
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
	env.ambient_light_color = Color(0.85, 0.85, 0.95)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_white = 2.2
	env.glow_enabled = true
	env.glow_intensity = 0.35
	env.glow_hdr_threshold = 1.2
	env.fog_enabled = true
	env.fog_light_color = Color(0.75, 0.87, 1.0)
	env.fog_density = 0.0025
	env.fog_sky_affect = 0.3
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -40, 0)
	sun.light_energy = 1.1
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.shadow_enabled = shadows_on
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 50.0
	add_child(sun)

	cam = Camera3D.new()
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	cam.fov = 62
	cam.far = 260
	add_child(cam)

	level_root = Node3D.new()
	add_child(level_root)

	# deniz + bulutlar (kalici)
	var sea := PlaneMesh.new()
	sea.size = Vector2(600, 600)
	var seam := _mat(Color(0.18, 0.55, 0.9), 0.0, 1.0, 0.2, 0.08)
	_mesh(sea, Vector3(0, -9, -80), seam, self, Vector3.ZERO, false)
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

	# birimler: Kenney Mini Characters 'sprint' animasyonu NF kareye pisirildi
	var pmat := _team_mat(Color(0.8, 1.0, 1.0), CYAN, 0.75)
	var emat := _team_mat(Color(1.0, 0.7, 0.6), ENEMY, 0.55)
	var per_p := MAXP / NF + 1
	var per_e := MAXE / NF + 1
	for g in NF:
		for team in 2:
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = unit_frames[g]
			mm.instance_count = per_p if team == 0 else per_e
			mm.visible_instance_count = 0
			var mi := MultiMeshInstance3D.new()
			mi.multimesh = mm
			mi.material_override = pmat if team == 0 else emat
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.extra_cull_margin = 400.0
			add_child(mi)
			var b := PackedFloat32Array()
			b.resize(mm.instance_count * 12)
			if team == 0:
				pmms.append(mm); pbufs.append(b)
			else:
				emms.append(mm); ebufs.append(b)

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

func _build_island(total: float) -> void:
	var z0 := 10.0
	var zc := z0 - total * 0.5
	# ada govdesi + cim
	_box(Vector3(44, 0.6, total + 6), Vector3(0, -0.35, zc), _mat(Color(0.36, 0.72, 0.28), 0.0, 1.0, 0.0, 0.9), level_root, false)
	_box(Vector3(42, 7, total + 4), Vector3(0, -4.0, zc), _mat(Color(0.5, 0.38, 0.28), 0.0, 1.0, 0.0, 1.0), level_root, false)
	# yol (tas) + kenar
	_box(Vector3(10.4, 0.3, total), Vector3(0, -0.12, zc), _mat(Color(0.62, 0.55, 0.45), 0.0, 1.0, 0.0, 0.85), level_root, false)
	var tile := _mat(Color(0.55, 0.48, 0.4), 0.0, 1.0, 0.0, 0.85)
	for k in int(total / 3.0):
		_box(Vector3(9.8, 0.04, 1.4), Vector3(0, 0.04, z0 - 2.0 - k * 3.0), tile, level_root, false)
	var edge := _mat(Color(0.62, 0.62, 0.66), 0.0, 1.0, 0.0, 0.7)
	for s in [-1, 1]:
		_box(Vector3(0.5, 0.55, total), Vector3(s * 5.3, 0.15, zc), edge, level_root)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var n := int(total / 3.0)
	var trees := {"res://assets/nature/tree_default.glb": [], "res://assets/nature/tree_oak.glb": [], "res://assets/nature/tree_pineRoundC.glb": [], "res://assets/nature/tree_detailed.glb": []}
	var tk := trees.keys()
	var bush: Array = []
	var bush2: Array = []
	var fl := {"res://assets/nature/flower_redA.glb": [], "res://assets/nature/flower_yellowA.glb": [], "res://assets/nature/flower_purpleA.glb": []}
	var fk := fl.keys()
	var rocks: Array = []
	var cliffs: Array = []
	var grass: Array = []
	for i in n:
		var z := z0 - i * 3.0
		for s in [-1, 1]:
			var y := rng.randf() * TAU
			trees[tk[rng.randi() % 4]].append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * rng.randf_range(3.0, 4.6)), Vector3(s * rng.randf_range(8.5, 20.0), 0, z + rng.randf_range(-1, 1))))
			bush.append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * rng.randf_range(2.0, 3.2)), Vector3(s * rng.randf_range(6.0, 8.0), 0, z + rng.randf_range(-1, 1))))
			if i % 2 == 0:
				bush2.append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * rng.randf_range(2.0, 3.0)), Vector3(s * rng.randf_range(10, 19), 0, z)))
			for k in 1:
				fl[fk[rng.randi() % 3]].append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(2.0, 3.0)), Vector3(s * rng.randf_range(5.9, 12.0), 0, z + rng.randf_range(-1.2, 1.2))))
			grass.append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * 2.5), Vector3(s * rng.randf_range(6.0, 16.0), 0, z + 1.0)))
			if i % 3 == 0:
				rocks.append(Transform3D(Basis(Vector3.UP, y).scaled(Vector3.ONE * rng.randf_range(2.5, 4.5)), Vector3(s * rng.randf_range(9, 20), 0, z)))
			if i % 2 == 0:
				cliffs.append(Transform3D(Basis(Vector3.UP, 0.0 if s > 0 else PI).rotated(Vector3.UP, PI * 0.5).scaled(Vector3(4.4, 7.0, 4.0)), Vector3(s * 21.0, -7.2, z)))
	for k in tk: _scatter(k, trees[k], level_root)
	_scatter("res://assets/nature/plant_bushLarge.glb", bush, level_root)
	_scatter("res://assets/nature/plant_bush.glb", bush2, level_root)
	for k in fk: _scatter(k, fl[k], level_root)
	_scatter("res://assets/nature/grass_large.glb", grass, level_root)
	_scatter("res://assets/nature/rock_tallB.glb", rocks, level_root)
	_scatter("res://assets/nature/cliff_large_rock.glb", cliffs, level_root)

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
	l.outline_size = 32
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
	var w: float = gd[2]
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
	lb.text = String(gd[3]).replace("x", "×")
	lb.font_size = 220
	lb.pixel_size = 0.0105
	lb.outline_size = 44
	lb.outline_modulate = col.darkened(0.6)
	lb.position = Vector3(0, 1.7, 0.4)
	lb.rotation_degrees = Vector3(-20, 0, 0)
	n.add_child(lb)
	var charge := 10 if gd[3] == "+10" else (5 if gd[3] == "-5" else 0)
	return {"z": gd[0], "bx": gd[1], "cx": gd[1], "w": w, "op": gd[3], "amp": gd[4], "sec": si, "gi": gi,
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
		_place(C + "flag.glb", Vector3(s * 4.3, S * 1.05 * 3.35, 0), S, 0.0, n)
	if boss:
		_place(C + "tower-hexagon-base.glb", Vector3(0, 0, -2.4), S * 1.4, 0.0, n)
		_place(C + "tower-hexagon-mid.glb", Vector3(0, S * 1.4, -2.4), S * 1.4, 0.0, n)
		_place(C + "tower-hexagon-mid.glb", Vector3(0, S * 2.8, -2.4), S * 1.4, 0.0, n)
		_place(C + "tower-hexagon-roof.glb", Vector3(0, S * 4.2, -2.4), S * 1.4, 0.0, n)
		_place(C + "flag-banner-long.glb", Vector3(-1.5, S * 1.3, 1.3), S, 0.0, n)
		_place(C + "flag-banner-long.glb", Vector3(1.5, S * 1.3, 1.3), S, 0.0, n)
	# tema vurgusu: kalenin arkasinda mor yarik + kristaller
	var rift := _mesh(TorusMesh.new(), Vector3(0, 6.5 if not boss else 9.5, -4.5), _mat(PURPLE, 3.0), n, Vector3(90, 0, 0), false)
	(rift.mesh as TorusMesh).inner_radius = 1.8
	(rift.mesh as TorusMesh).outer_radius = 2.2
	var core := _cyl(1.8, 1.8, 0.05, Vector3.ZERO, _mat(Color(0.45, 0.1, 0.75), 1.6, 0.7), rift, 24)
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
	return {"node": n, "body": StandardMaterial3D.new(), "rift": rift, "cracks": 0}

# ---------------- seviye ----------------
func _clear_units() -> void:
	px.clear(); pz.clear(); pdx.clear(); pmask.clear()
	ex.clear(); ez.clear(); ehp.clear(); esc.clear()

func start_level(i: int) -> void:
	level = i
	var L: Dictionary = LEVELS[i]
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
	cam.position = Vector3(0, 10.5, 12.0)
	cam_push = 0.0
	if not hint_seen:
		hint.visible = true
		drag_sum = 0.0

func _setup_section() -> void:
	var S: Dictionary = LEVELS[level]["sections"][sec]
	base_max = S["hp"]
	base_hp = base_max
	spawn_t = 2.0

func _update_titles() -> void:
	var n: int = LEVELS[level]["sections"].size()
	lbl_level.text = "BÖLÜM %d • %s" % [level + 1, "BOSS" if sec == n - 1 else "KALE %d/%d" % [sec + 1, n]]

func _fire_rate() -> float:
	return 6.0 + rate_lv * 1.5

func _add_p(x: float, z: float, dx: float, mask: int) -> void:
	if px.size() >= MAXP: return
	px.append(x); pz.append(z); pdx.append(dx); pmask.append(mask)

func _kill_p(i: int) -> void:
	var l := px.size() - 1
	px[i] = px[l]; pz[i] = pz[l]; pdx[i] = pdx[l]; pmask[i] = pmask[l]
	px.resize(l); pz.resize(l); pdx.resize(l); pmask.resize(l)

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
		var w := get_viewport().get_visible_rect().size.x
		cannon_x = clampf(cannon_x + e.relative.x / w * 14.0, -LANE + 0.4, LANE - 0.4)
		drag_sum += absf(e.relative.x)
	elif e is InputEventKey and e.keycode == KEY_SPACE:
		holding = e.pressed

# ---------------- dongu ----------------
func _process(dt: float) -> void:
	if cam == null: return
	t += dt
	for c in crystals:
		(c[0] as Node3D).position.y = c[1] + sin(t * 1.2 + c[2]) * 0.4
		(c[0] as Node3D).rotation.y += dt * 0.6
	for b in bases:
		(b["rift"] as Node3D).rotation.y += dt * 1.5
	ring.rotation.y += dt * 3.0
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
		cannon_x = clampf(cannon_x + kd * 9.0 * dt, -LANE + 0.4, LANE - 0.4)
		drag_sum += 400 * dt
	if hint.visible:
		hand.position.x = 540 - 60 + sin(t * 3.0) * 220
		if drag_sum > 500.0:
			hint.visible = false
			hint_seen = true
			_save()
	cannon.position = Vector3(0, 0, sec_off + 1.8)
	barrel.position.x = lerpf(barrel.position.x, cannon_x, minf(1.0, dt * 18.0))
	barrel.position.z = lerpf(barrel.position.z, 0.0, minf(1.0, dt * 14.0))
	flash_t = maxf(0.0, flash_t - dt * 10.0)
	flash.scale = Vector3.ONE * flash_t * 1.1
	flash_light.light_energy = flash_t * 4.0
	trauma = maxf(0.0, trauma - dt * 1.8)
	# kamera: topun arkasi, alcak acı, ordu ilerledikce ileri itilir
	cam_push = lerpf(cam_push, clampf(-front * 0.12, 0.0, 3.5), minf(1.0, dt * 2.0))
	var cz := cannon.position.z
	var target := Vector3(barrel.position.x * 0.35, 10.5, cz + 11.5 - cam_push)
	cam.position = cam.position.lerp(target, minf(1.0, dt * 4.0))
	var sh := trauma * trauma * 0.5
	cam.look_at(Vector3(barrel.position.x * 0.2, 0, cam.position.z - 22.0) + Vector3(randf_range(-sh, sh), randf_range(-sh, sh), 0))
	var t0 := Time.get_ticks_usec()
	if playing and not advancing:
		_sim(dt)
	_render()
	if bench: cpu_us.append(Time.get_ticks_usec() - t0)

func _sim(dt: float) -> void:
	var S: Dictionary = LEVELS[level]["sections"][sec]
	time_left -= dt
	if holding and ammo > 0:
		fire_acc += dt * _fire_rate()
		while fire_acc >= 1.0 and ammo > 0:
			fire_acc -= 1.0
			ammo -= 1
			_add_p(barrel.position.x + randf_range(-0.2, 0.2), -1.0, randf_range(-0.6, 0.6), 0)
			barrel.position.z = 0.35
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
		var z1: float = z0 - PSPEED * dt
		var x: float = px[i] + pdx[i] * dt
		if z1 < -29.0:
			x = lerpf(x, clampf(x, -2.8, 2.8), dt * 3.0)
		if x > LANE or x < -LANE:
			pdx[i] = -pdx[i]
			x = clampf(x, -LANE, LANE)
		px[i] = x
		pz[i] = z1
		front = minf(front, z1)
		if z1 <= BASE_Z + 1.8:
			base_hits += 1
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
						_add_p(x + randf_range(-0.5, 0.5), z1 - 0.3, randf_range(-0.8, 0.8), m); g["pend"] += 1
					"x3":
						for k in 2: _add_p(x + randf_range(-0.6, 0.6), z1 - 0.3 - 0.3 * k, randf_range(-0.9, 0.9), m)
						g["pend"] += 2
					"+10":
						if g["charge"] > 0:
							g["charge"] -= 1
							_add_p(x + randf_range(-0.6, 0.6), z1 - 0.4, randf_range(-0.9, 0.9), m); g["pend"] += 1
					"-5":
						if g["charge"] > 0:
							g["charge"] -= 1
							g["pend"] -= 1
							killed = true
				if killed:
					break
		if killed:
			_kill_p(i)
	pop_t -= dt
	if pop_t <= 0.0:
		pop_t = 0.15
		for g in sg:
			var pnd: int = g["pend"]
			if pnd != 0:
				var nd: Node3D = g["node"]
				pop_text(nd.position + Vector3(randf_range(-0.6, 0.6), 3.8, 0), ("+%d" % pnd) if pnd > 0 else str(pnd), g["col"], absi(pnd) > 8)
				nd.scale = Vector3(1.12, 1.12, 1.12)
				create_tween().tween_property(nd, "scale", Vector3.ONE, 0.14)
				var pm: StandardMaterial3D = g["pmat"]
				pm.emission_energy_multiplier = 4.0
				create_tween().tween_property(pm, "emission_energy_multiplier", 0.8, 0.25)
				burst(nd.position + Vector3(0, 1.5, 0), g["col"], 14)
				g["pend"] = 0
	var B: Dictionary = bases[sec]
	if base_hits > 0:
		base_hp -= base_hits
		trauma = minf(1.0, trauma + 0.03 * base_hits)
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
			(B["body"] as StandardMaterial3D).albedo_color = (B["body"] as StandardMaterial3D).albedo_color.darkened(0.22)
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
					dead[idx] = 1
					hp -= 1
					if hp <= 0: break
			if hp <= 0: break
		ehp[j] = hp
		if hp <= 0:
			burst(Vector3(exj, 0.8, ezj + sec_off), ENEMY if esc[j] < 1.5 else Color(1, 0.8, 0.2), 18)
			if esc[j] > 1.5:
				trauma = minf(1.0, trauma + 0.3)
				chunk_burst(Vector3(exj, 1, ezj + sec_off), ENEMY)
			_kill_e(j)
	for i in range(np - 1, -1, -1):
		if dead[i] == 1:
			_kill_p(i)
	lbl_time.text = "%d sn" % ceili(maxf(0.0, time_left))
	lbl_ammo.text = "Mermi: %d" % ammo
	lbl_units.text = "Ordu: %d" % px.size()
	(sec_bars[sec] as ProgressBar).value = 100.0 - float(maxi(base_hp, 0)) / base_max * 100.0
	if base_hp <= 0:
		_base_destroyed()
		return
	if bench: return
	if time_left <= 0.0:
		_lose("Süre doldu!")
	elif ammo <= 0 and px.size() == 0:
		end_grace += dt
		if end_grace > 0.6:
			_lose("Ordun tükendi!")

func _base_destroyed() -> void:
	var B: Dictionary = bases[sec]
	var bn: Node3D = B["node"]
	trauma = 1.0
	for k in 8:
		burst(bn.position + Vector3(randf_range(-3.5, 3.5), randf_range(1, 6), 1.0), [ENEMY, PURPLE, Color(1, 0.85, 0.3)][k % 3], 30)
	for k in 5:
		chunk_burst(bn.position + Vector3(randf_range(-3, 3), randf_range(1, 5), 1.0), Color(0.7, 0.25, 0.12))
	var tw := create_tween()
	tw.tween_property(bn, "scale", bn.scale * Vector3(1.15, 0.2, 1.15), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(bn.hide)
	coins += 15
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
	for g in NF:
		var b: PackedFloat32Array = pbufs[g]
		var k := 0
		var i := g
		while i < n:
			var o := k * 12
			b[o] = -1.7; b[o + 5] = 1.7; b[o + 10] = -1.7
			b[o + 3] = px[i]; b[o + 7] = 0.05; b[o + 11] = pz[i] + sec_off
			k += 1
			i += NF
		var mm: MultiMesh = pmms[g]
		mm.mesh = unit_frames[(g + step) % NF]
		mm.buffer = b
		mm.visible_instance_count = k
		pbufs[g] = b
	var m := ex.size()
	for g in NF:
		var b: PackedFloat32Array = ebufs[g]
		var k := 0
		var j := g
		while j < m:
			var o := k * 12
			var s: float = esc[j] * 2.0
			b[o] = s; b[o + 5] = s; b[o + 10] = s
			b[o + 3] = ex[j]; b[o + 7] = 0.05; b[o + 11] = ez[j] + sec_off
			k += 1
			j += NF
		var mm: MultiMesh = emms[g]
		mm.mesh = unit_frames[(g + step + 3) % NF]
		mm.buffer = b
		mm.visible_instance_count = k
		ebufs[g] = b

# ---------------- sonuc ----------------
func _win() -> void:
	playing = false
	holding = false
	earned = 40 + 30 * (level + 1) + mini(ammo, 150) + int(time_left)
	coins += earned
	doubled = false
	if level + 1 < LEVELS.size():
		unlocked = maxi(unlocked, level + 2)
	_save()
	await get_tree().create_timer(1.0).timeout
	res_title.text = "ZAFER!"
	res_title.modulate = CYAN
	res_info.text = "+%d coin   (Toplam: %d)" % [earned, coins]
	btn_double.visible = true
	btn_next.text = "Sonraki Bölüm" if level + 1 < LEVELS.size() else "Menü"
	btn_next.visible = true
	_show_result()

func _lose(why: String) -> void:
	playing = false
	holding = false
	res_title.text = "YENİLDİN"
	res_title.modulate = ENEMY
	res_info.text = why
	btn_double.visible = false
	btn_next.text = "Tekrar Dene"
	btn_next.visible = true
	_show_result()

func _show_result() -> void:
	hud.visible = false
	result.visible = true
	result.modulate.a = 0.0
	create_tween().tween_property(result, "modulate:a", 1.0, 0.25)

func _on_double() -> void:
	if doubled: return
	Ads.show_rewarded(func(ok: bool) -> void:
		if ok:
			coins += earned
			doubled = true
			_save()
			res_info.text = "+%d coin (2×)   (Toplam: %d)" % [earned * 2, coins]
			btn_double.visible = false)

func _on_next() -> void:
	if res_title.text == "ZAFER!":
		if level + 1 < LEVELS.size():
			var nxt := level + 1
			Ads.show_interstitial(func() -> void: start_level(nxt))
		else:
			Ads.show_interstitial(_show_menu)
	else:
		start_level(level)

func _show_menu() -> void:
	playing = false
	_clear_units()
	result.visible = false
	hud.visible = false
	menu.visible = true
	_refresh_menu()

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
	row.add_theme_constant_override("separation", 40)
	top.add_child(row)
	lbl_level = _label("BÖLÜM 1", 42, row, CYAN)
	lbl_time = _label("60 sn", 42, row)
	lbl_ammo = _label("Mermi: 0", 42, row)
	var hc := CenterContainer.new()
	top.add_child(hc)
	sec_box = HBoxContainer.new()
	sec_box.add_theme_constant_override("separation", 14)
	hc.add_child(sec_box)
	lbl_units = _label("Ordu: 0", 44, top, CYAN)
	var hl := _label("A/D veya sürükle: nişan  •  Basılı tut: ateş", 34, hud, Color(1, 1, 1, 0.7))
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

	var mv := _panel(cl)
	menu = mv.get_parent().get_parent()
	_label("RIFT RUSH", 150, mv, CYAN)
	_label("Yarıktan gelen orduyu durdur!", 46, mv, Color(0.85, 0.75, 1))
	lbl_coins = _label("", 60, mv, Color(1, 0.85, 0.2))
	for i in LEVELS.size():
		var idx := i
		lvl_btns.append(_btn("", Color(0.1, 0.55, 0.85), mv, func() -> void: start_level(idx)))
	up_btn = _btn("", Color(0.55, 0.2, 0.9), mv, _on_upgrade)
	_label("Sürükle: nişan al  •  Basılı tut: ateş", 38, mv, Color(1, 1, 1, 0.7))

	var rv := _panel(cl)
	result = rv.get_parent().get_parent()
	res_title = _label("", 140, rv)
	res_info = _label("", 56, rv, Color(1, 0.85, 0.2))
	btn_double = _btn("2× Coin  (Reklam izle)", Color(0.95, 0.6, 0.1), rv, _on_double)
	btn_next = _btn("Sonraki", Color(0.1, 0.7, 0.45), rv, _on_next)
	_btn("Menü", Color(0.3, 0.3, 0.5), rv, _show_menu)
	result.visible = false
	_refresh_menu()

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

func _refresh_menu() -> void:
	lbl_coins.text = "Coin: %d" % coins
	for i in lvl_btns.size():
		var b: Button = lvl_btns[i]
		b.disabled = i >= unlocked
		b.text = ("Bölüm %d" % (i + 1)) if i < unlocked else ("Bölüm %d  (kilitli)" % (i + 1))
	var cost := _up_cost()
	up_btn.text = "Atış Hızı Sv.%d  →  %d coin" % [rate_lv + 1, cost]
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
	c.save("user://save.cfg")

func _load() -> void:
	var c := ConfigFile.new()
	if c.load("user://save.cfg") == OK:
		coins = c.get_value("p", "coins", 0)
		unlocked = c.get_value("p", "unlocked", 1)
		rate_lv = c.get_value("p", "rate_lv", 0)
		hint_seen = c.get_value("p", "hint", false)

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
