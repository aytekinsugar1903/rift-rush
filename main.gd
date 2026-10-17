extends Node3D
## Rift Rush - MVP. Tum sahne kodla kuruluyor (tek dosya, kolay iterasyon).

const LANE := 4.6
const BASE_Z := -38.0
const MAXP := 1500
const MAXE := 400
const PSPEED := 7.5
const CYAN := Color(0.15, 0.95, 1.0)
const ENEMY := Color(1.0, 0.38, 0.12)
const PURPLE := Color(0.65, 0.2, 1.0)

# gate: [z, x, genislik, islem, hareket_genligi]
const LEVELS := [
	{"ammo": 60, "time": 60.0, "hp": 150, "spawn": 2.2, "brute": 0.0,
	 "gates": [[-10.0, -2.3, 4.2, "x2", 0.0], [-10.0, 2.3, 4.2, "+10", 0.0], [-22.0, 0.0, 3.6, "x3", 1.6]]},
	{"ammo": 70, "time": 60.0, "hp": 450, "spawn": 1.3, "brute": 0.1,
	 "gates": [[-8.0, -2.3, 4.2, "x2", 0.0], [-8.0, 2.3, 4.2, "-5", 0.0], [-16.0, 0.0, 3.2, "+10", 2.2], [-25.0, -2.3, 4.2, "x3", 0.0], [-25.0, 2.3, 4.2, "x2", 0.0]]},
	{"ammo": 80, "time": 75.0, "hp": 1100, "spawn": 0.75, "brute": 0.2,
	 "gates": [[-8.0, 0.0, 3.0, "-5", 2.6], [-14.0, -2.3, 4.2, "x2", 0.0], [-14.0, 2.3, 4.2, "x2", 0.0], [-21.0, 0.0, 3.0, "x3", 2.4], [-28.0, -3.0, 3.0, "x2", 0.0], [-28.0, 0.0, 3.0, "+10", 0.0], [-28.0, 3.0, 3.0, "-5", 0.0]]},
]

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
var level := 0
var playing := false
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

var coins := 0
var unlocked := 1
var rate_lv := 0

var cam: Camera3D
var cannon: Node3D
var barrel: Node3D
var base_node: MeshInstance3D
var rift: MeshInstance3D
var parts: Array = []
var part_i := 0
var gate_root: Node3D

var hud: Control
var lbl_level: Label
var lbl_time: Label
var lbl_ammo: Label
var lbl_units: Label
var hp_bar: ProgressBar
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
var bench_shot := ""
var ft: Array = []
var max_units := 0

func _ready() -> void:
	_load()
	_build_world()
	_build_ui()
	for i in 46:
		buckets.append(PackedInt32Array())
	var args := OS.get_cmdline_user_args()
	if args.size() > 0 and args[0] == "bench":
		bench = true
		if args.size() > 1: bench_len = float(args[1])
		if args.size() > 2: bench_shot = args[2]
		start_level(2)
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

# ---------------- dunya ----------------
func _mat(c: Color, emit := 0.6, alpha := 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c.r, c.g, c.b, alpha)
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emit
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

func _box(size: Vector3, pos: Vector3, m: Material, parent: Node = self) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.material_override = m
	mi.position = pos
	parent.add_child(mi)
	return mi

func _build_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.03, 0.14)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75, 0.7, 0.95)
	env.ambient_light_energy = 0.7
	env.glow_enabled = true
	env.glow_intensity = 0.9
	env.glow_bloom = 0.15
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_energy = 1.1
	add_child(sun)

	cam = Camera3D.new()
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.fov = 44
	cam.position = Vector3(0, 34, 8)
	add_child(cam)
	cam.look_at(Vector3(0, 0, -19))

	_box(Vector3(11, 0.2, 52), Vector3(0, -0.1, -18), _mat(Color(0.12, 0.1, 0.28), 0.0))
	for i in 13:
		_box(Vector3(9.6, 0.02, 0.12), Vector3(0, 0.01, 2.0 - i * 3.3), _mat(Color(0.3, 0.25, 0.7), 0.4))
	for s in [-1, 1]:
		_box(Vector3(0.3, 0.6, 52), Vector3(s * 5.2, 0.3, -18), _mat(CYAN, 1.2))

	base_node = _box(Vector3(7, 3, 2), Vector3(0, 1.5, BASE_Z), _mat(ENEMY, 0.5))
	_box(Vector3(1.6, 1.2, 1.6), Vector3(-2.6, 2.1, 0), _mat(Color(0.9, 0.2, 0.1), 0.8), base_node)
	_box(Vector3(1.6, 1.2, 1.6), Vector3(2.6, 2.1, 0), _mat(Color(0.9, 0.2, 0.1), 0.8), base_node)
	rift = MeshInstance3D.new()
	var tor := TorusMesh.new()
	tor.inner_radius = 2.4
	tor.outer_radius = 3.0
	rift.mesh = tor
	rift.material_override = _mat(PURPLE, 3.0)
	rift.position = Vector3(0, 4.2, BASE_Z - 2.2)
	rift.rotation_degrees = Vector3(90, 0, 0)
	add_child(rift)
	var core := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 2.4
	cyl.bottom_radius = 2.4
	cyl.height = 0.05
	core.mesh = cyl
	core.material_override = _mat(Color(0.35, 0.05, 0.6), 1.5, 0.75)
	rift.add_child(core)
	var ol := OmniLight3D.new()
	ol.light_color = PURPLE
	ol.light_energy = 3.0
	ol.omni_range = 12
	ol.position = Vector3(0, 4, BASE_Z)
	add_child(ol)

	cannon = Node3D.new()
	cannon.position = Vector3(0, 0, 1.6)
	add_child(cannon)
	var cb := MeshInstance3D.new()
	var cbm := CylinderMesh.new()
	cbm.top_radius = 0.8
	cbm.bottom_radius = 1.0
	cbm.height = 0.6
	cb.mesh = cbm
	cb.material_override = _mat(Color(0.2, 0.3, 0.5), 0.2)
	cb.position.y = 0.3
	cannon.add_child(cb)
	barrel = Node3D.new()
	barrel.position = Vector3(0, 0.8, 0)
	cannon.add_child(barrel)
	_box(Vector3(0.7, 0.7, 1.8), Vector3(0, 0, -0.6), _mat(CYAN, 1.0), barrel)

	gate_root = Node3D.new()
	add_child(gate_root)

	var cap := CapsuleMesh.new()
	cap.radius = 0.17
	cap.height = 0.6
	cap.radial_segments = 6
	cap.rings = 2
	cap.material = _mat(CYAN, 1.3)
	pmm = MultiMesh.new()
	pmm.transform_format = MultiMesh.TRANSFORM_3D
	pmm.mesh = cap
	pmm.instance_count = MAXP
	pmm.visible_instance_count = 0
	var pmi := MultiMeshInstance3D.new()
	pmi.multimesh = pmm
	add_child(pmi)
	var cap2 := CapsuleMesh.new()
	cap2.radius = 0.22
	cap2.height = 0.7
	cap2.radial_segments = 6
	cap2.rings = 2
	cap2.material = _mat(ENEMY, 1.0)
	emm = MultiMesh.new()
	emm.transform_format = MultiMesh.TRANSFORM_3D
	emm.mesh = cap2
	emm.instance_count = MAXE
	emm.visible_instance_count = 0
	var emi := MultiMeshInstance3D.new()
	emi.multimesh = emm
	add_child(emi)
	pbuf.resize(MAXP * 12)
	for i in MAXP:
		pbuf[i * 12] = 1.0; pbuf[i * 12 + 5] = 1.0; pbuf[i * 12 + 10] = 1.0
	ebuf.resize(MAXE * 12)

	var pm := StandardMaterial3D.new()
	pm.vertex_color_use_as_albedo = true
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var pmesh := BoxMesh.new()
	pmesh.size = Vector3(0.14, 0.14, 0.14)
	pmesh.material = pm
	for i in 20:
		var p := CPUParticles3D.new()
		p.emitting = false
		p.one_shot = true
		p.amount = 20
		p.lifetime = 0.55
		p.explosiveness = 1.0
		p.mesh = pmesh
		p.direction = Vector3(0, 1, 0)
		p.spread = 70
		p.initial_velocity_min = 3.0
		p.initial_velocity_max = 7.0
		p.gravity = Vector3(0, -14, 0)
		p.scale_amount_min = 0.6
		p.scale_amount_max = 1.4
		add_child(p)
		parts.append(p)

func burst(pos: Vector3, c: Color, amount := 20) -> void:
	var p: CPUParticles3D = parts[part_i]
	part_i = (part_i + 1) % parts.size()
	p.position = pos
	p.color = c
	p.amount = amount
	p.restart()

func pop_text(pos: Vector3, txt: String, c: Color, big := false) -> void:
	var l := Label3D.new()
	l.text = txt
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.font_size = 140 if big else 110
	l.pixel_size = 0.008
	l.outline_size = 28
	l.modulate = c
	l.no_depth_test = true
	l.position = pos
	add_child(l)
	l.scale = Vector3.ONE * 0.3
	var tw := create_tween()
	tw.tween_property(l, "scale", Vector3.ONE * 1.3, 0.12).set_trans(Tween.TRANS_BACK)
	tw.tween_property(l, "scale", Vector3.ONE, 0.1)
	tw.parallel().tween_property(l, "position", pos + Vector3(0, 2.0, 0), 0.7)
	tw.tween_property(l, "modulate:a", 0.0, 0.25)
	tw.tween_callback(l.queue_free)

# ---------------- seviye ----------------
func start_level(i: int) -> void:
	level = i
	var L: Dictionary = LEVELS[i]
	px.clear(); pz.clear(); pdx.clear(); pmask.clear()
	ex.clear(); ez.clear(); ehp.clear(); esc.clear()
	for g in gates:
		(g["node"] as Node).queue_free()
	gates.clear()
	for gd in L["gates"]:
		var good: bool = not String(gd[3]).begins_with("-")
		var col: Color = Color(0.2, 1.0, 0.45) if good else Color(1.0, 0.2, 0.3)
		var n := Node3D.new()
		n.position = Vector3(gd[1], 0, gd[0])
		gate_root.add_child(n)
		_box(Vector3(gd[2], 2.2, 0.12), Vector3(0, 1.1, 0), _mat(col, 0.0, 0.32), n)
		for s in [-1, 1]:
			_box(Vector3(0.2, 2.4, 0.2), Vector3(s * gd[2] * 0.5, 1.2, 0), _mat(col, 1.5), n)
		var lb := Label3D.new()
		lb.text = String(gd[3]).replace("x", "×")
		lb.font_size = 170
		lb.pixel_size = 0.01
		lb.outline_size = 30
		lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lb.position = Vector3(0, 1.3, 0.1)
		n.add_child(lb)
		var charge := 10 if gd[3] == "+10" else (5 if gd[3] == "-5" else 0)
		gates.append({"z": gd[0], "bx": gd[1], "cx": gd[1], "w": gd[2], "op": gd[3], "amp": gd[4],
			"charge": charge, "node": n, "pend": 0, "col": col, "ph": randf() * 6.0})
	ammo = L["ammo"]
	time_left = L["time"]
	base_max = L["hp"]
	base_hp = base_max
	base_node.visible = true
	base_node.scale = Vector3.ONE
	spawn_t = 1.5
	cannon_x = 0.0
	end_grace = 0.0
	playing = true
	menu.visible = false
	result.visible = false
	hud.visible = true
	lbl_level.text = "BÖLÜM %d" % (i + 1)

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
	elif e is InputEventKey and e.keycode == KEY_SPACE:
		holding = e.pressed

# ---------------- dongu ----------------
func _process(dt: float) -> void:
	t += dt
	rift.rotation.y += dt * 1.5
	if bench:
		ft.append(dt)
		var mm := InputEventMouseMotion.new()
		mm.relative = Vector2(cos(t * 0.9) * 3.5 * 0.9 * dt / 14.0 * get_viewport().get_visible_rect().size.x, 0)
		Input.parse_input_event(mm)
		max_units = max(max_units, px.size())
		if bench_shot != "" and t > 6.0:
			get_viewport().get_texture().get_image().save_png(bench_shot)
			bench_shot = ""
		if t > bench_len:
			_bench_report()
			return
	cannon.position.x = lerpf(cannon.position.x, cannon_x, minf(1.0, dt * 18.0))
	barrel.scale.z = lerpf(barrel.scale.z, 1.0, minf(1.0, dt * 12.0))
	trauma = maxf(0.0, trauma - dt * 1.8)
	var sh := trauma * trauma * 0.6
	cam.h_offset = randf_range(-sh, sh)
	cam.v_offset = randf_range(-sh, sh)
	if playing:
		_sim(dt)
	_render()

func _sim(dt: float) -> void:
	var L: Dictionary = LEVELS[level]
	time_left -= dt
	# ates
	if holding and ammo > 0:
		fire_acc += dt * _fire_rate()
		while fire_acc >= 1.0 and ammo > 0:
			fire_acc -= 1.0
			ammo -= 1
			_add_p(cannon.position.x + randf_range(-0.15, 0.15), 0.8, randf_range(-0.5, 0.5), 0)
			barrel.scale.z = 0.7
	else:
		fire_acc = minf(fire_acc, 1.0)
	# hareketli kapilar
	for g in gates:
		if g["amp"] > 0.0:
			var w: float = g["w"]
			g["cx"] = clampf(g["bx"] + sin(t * 1.3 + g["ph"]) * g["amp"], -LANE + w * 0.5, LANE - w * 0.5)
			(g["node"] as Node3D).position.x = g["cx"]
	# oyuncu birimleri
	var base_hits := 0
	var n0 := px.size()
	for i in range(n0 - 1, -1, -1):
		var z0: float = pz[i]
		var z1: float = z0 - PSPEED * dt
		var x: float = px[i] + pdx[i] * dt
		if z1 < -29.0:
			x = lerpf(x, clampf(x, -3.0, 3.0), dt * 3.0)
		if x > LANE or x < -LANE:
			pdx[i] = -pdx[i]
			x = clampf(x, -LANE, LANE)
		px[i] = x
		pz[i] = z1
		if z1 <= BASE_Z + 1.3:
			base_hits += 1
			_kill_p(i)
			continue
		var killed := false
		for gi in gates.size():
			var g: Dictionary = gates[gi]
			var gz: float = g["z"]
			if z0 > gz and z1 <= gz and absf(x - g["cx"]) < g["w"] * 0.5 and (pmask[i] & (1 << gi)) == 0:
				pmask[i] |= 1 << gi
				var m := pmask[i]
				match g["op"]:
					"x2":
						_add_p(x + randf_range(-0.4, 0.4), z1 - 0.2, randf_range(-0.8, 0.8), m); g["pend"] += 1
					"x3":
						for k in 2: _add_p(x + randf_range(-0.5, 0.5), z1 - 0.2 - 0.2 * k, randf_range(-0.9, 0.9), m)
						g["pend"] += 2
					"+10":
						if g["charge"] > 0:
							g["charge"] -= 1
							_add_p(x + randf_range(-0.5, 0.5), z1 - 0.3, randf_range(-0.9, 0.9), m); g["pend"] += 1
					"-5":
						if g["charge"] > 0:
							g["charge"] -= 1
							g["pend"] -= 1
							killed = true
				if killed:
					break
		if killed:
			_kill_p(i)
	# kapi pop'lari
	pop_t -= dt
	if pop_t <= 0.0:
		pop_t = 0.15
		for g in gates:
			var pnd: int = g["pend"]
			if pnd != 0:
				var nd: Node3D = g["node"]
				pop_text(nd.position + Vector3(randf_range(-0.6, 0.6), 2.4, 0), ("+%d" % pnd) if pnd > 0 else str(pnd), g["col"], absi(pnd) > 8)
				nd.scale = Vector3(1.15, 1.15, 1.15)
				create_tween().tween_property(nd, "scale", Vector3.ONE, 0.12)
				burst(nd.position + Vector3(0, 1, 0), g["col"], 12)
				g["pend"] = 0
	if base_hits > 0:
		base_hp -= base_hits
		trauma = minf(1.0, trauma + 0.04 * base_hits)
		base_node.scale = Vector3(1.06, 0.95, 1.06)
		create_tween().tween_property(base_node, "scale", Vector3.ONE, 0.08)
		if randf() < 0.5:
			burst(Vector3(randf_range(-3, 3), 2, BASE_Z + 1.2), ENEMY, 14)
	# dusman dogur
	spawn_t -= dt
	if spawn_t <= 0.0 and ex.size() < MAXE:
		spawn_t = L["spawn"] * randf_range(0.7, 1.3)
		var cnt := 1 + randi() % 3
		for k in cnt:
			var brute: bool = randf() < L["brute"]
			ex.append(randf_range(-2.5, 2.5)); ez.append(BASE_Z + 2.0 + k * 0.5)
			ehp.append(8 if brute else 1); esc.append(1.9 if brute else 1.0)
		burst(Vector3(0, 3, BASE_Z - 1.5), PURPLE, 16)
	# carpisma izgarasi
	for k in buckets.size():
		buckets[k] = PackedInt32Array()
	var np := px.size()
	dead.resize(np)
	dead.fill(0)
	for i in np:
		var c := clampi(int(-pz[i]), 0, 45)
		buckets[c].append(i)
	for j in range(ex.size() - 1, -1, -1):
		var ezj: float = ez[j] + 2.6 * dt
		var exj: float = ex[j] + clampf(cannon.position.x - ex[j], -1.0, 1.0) * 0.3 * dt
		ez[j] = ezj; ex[j] = exj
		if ezj > 1.0:
			ammo = maxi(0, ammo - 3)
			trauma = minf(1.0, trauma + 0.5)
			burst(Vector3(exj, 1, 1), ENEMY, 24)
			pop_text(Vector3(exj, 2, 1), "-3", Color(1, 0.3, 0.3))
			_kill_e(j)
			continue
		var r: float = 0.42 * esc[j]
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
			burst(Vector3(exj, 0.6, ezj), ENEMY if esc[j] < 1.5 else Color(1, 0.8, 0.2), 18)
			if esc[j] > 1.5: trauma = minf(1.0, trauma + 0.3)
			_kill_e(j)
	for i in range(np - 1, -1, -1):
		if dead[i] == 1:
			_kill_p(i)
	# HUD
	lbl_time.text = "%d sn" % ceili(maxf(0.0, time_left))
	lbl_ammo.text = "Mermi: %d" % ammo
	lbl_units.text = "Ordu: %d" % px.size()
	hp_bar.value = float(maxi(base_hp, 0)) / base_max * 100.0
	# bitis
	if bench: return
	if base_hp <= 0:
		_win()
	elif time_left <= 0.0:
		_lose("Süre doldu!")
	elif ammo <= 0 and px.size() == 0:
		end_grace += dt
		if end_grace > 0.6:
			_lose("Ordun tükendi!")

func _render() -> void:
	var n := px.size()
	for i in n:
		var o := i * 12
		pbuf[o + 3] = px[i]
		pbuf[o + 7] = 0.32 + absf(sin(t * 14.0 + i)) * 0.18
		pbuf[o + 11] = pz[i]
	pmm.buffer = pbuf
	pmm.visible_instance_count = n
	var m := ex.size()
	for j in m:
		var o := j * 12
		var s: float = esc[j]
		ebuf[o] = s; ebuf[o + 5] = s; ebuf[o + 10] = s
		ebuf[o + 3] = ex[j]
		ebuf[o + 7] = 0.4 * s + absf(sin(t * 10.0 + j)) * 0.12
		ebuf[o + 11] = ez[j]
	emm.buffer = ebuf
	emm.visible_instance_count = m

# ---------------- sonuc ----------------
func _win() -> void:
	playing = false
	holding = false
	trauma = 1.0
	for k in 6:
		burst(Vector3(randf_range(-3, 3), randf_range(1, 4), BASE_Z), [ENEMY, PURPLE, CYAN][k % 3], 30)
	base_node.visible = false
	earned = 40 + 30 * (level + 1) + ammo + int(time_left)
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
	px.clear(); pz.clear(); pdx.clear(); pmask.clear()
	ex.clear(); ez.clear(); ehp.clear(); esc.clear()
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
	row.add_theme_constant_override("separation", 60)
	top.add_child(row)
	lbl_level = _label("BÖLÜM 1", 52, row, CYAN)
	lbl_time = _label("60 sn", 52, row)
	lbl_ammo = _label("Mermi: 0", 52, row)
	var hc := CenterContainer.new()
	top.add_child(hc)
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(760, 46)
	hp_bar.show_percentage = false
	var fill := StyleBoxFlat.new(); fill.bg_color = ENEMY; fill.set_corner_radius_all(20)
	var bgs := StyleBoxFlat.new(); bgs.bg_color = Color(0, 0, 0, 0.6); bgs.set_corner_radius_all(20)
	bgs.border_color = Color.WHITE; bgs.set_border_width_all(4)
	hp_bar.add_theme_stylebox_override("fill", fill)
	hp_bar.add_theme_stylebox_override("background", bgs)
	hc.add_child(hp_bar)
	lbl_units = _label("Ordu: 0", 44, top, CYAN)
	var hint := _label("Sürükle: nişan al  •  Basılı tut: ateş", 36, hud, Color(1, 1, 1, 0.7))
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -90
	hint.offset_bottom = -30
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
	c.save("user://save.cfg")

func _load() -> void:
	var c := ConfigFile.new()
	if c.load("user://save.cfg") == OK:
		coins = c.get_value("p", "coins", 0)
		unlocked = c.get_value("p", "unlocked", 1)
		rate_lv = c.get_value("p", "rate_lv", 0)

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
	print("BENCH frames=%d avg_fps=%.1f p99_ms=%.2f max_ms=%.2f spikes50=%d max_units=%d enemies=%d" % [a.size(), a.size() / s, p99 * 1000, mx * 1000, spikes, max_units, ex.size()])
	get_tree().quit()
