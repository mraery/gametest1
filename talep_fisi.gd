extends Control

const MASA_OLCEK: float = 1.08

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var masada_acik: bool = false
var _press_global_pos: Vector2 = Vector2.ZERO
var _press_local_pos: Vector2 = Vector2.ZERO
var _dragged_far: bool = false

var burusuk_kagitlar = [
	preload("res://assets/kagit_burusuk_1.png"),
	preload("res://assets/kagit_burusuk_2.png"),
	preload("res://assets/kagit_burusuk_3.png")
]

var baski_onay = preload("res://assets/damga_baski_onay.png")
var baski_red = preload("res://assets/damga_baski_red.png")

func _ready() -> void:
	z_as_relative = false
	z_index = 14
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _get_ana() -> Node:
	if get_tree() and get_tree().current_scene:
		return get_tree().current_scene
	if owner:
		return owner
	var n = get_parent()
	while n:
		if n.name == "masa" or n.has_method("bildirim_goster"):
			return n
		n = n.get_parent()
	return null

func delikten_uzat() -> void:
	# Mahkum geldiğinde fiş önce gişe deliğinden uzatılır ve hemen masanın üstüne büyük olarak açılır
	visible = true
	masada_acik = false
	is_dragging = false
	_dragged_far = false
	modulate.a = 1.0
	scale = Vector2(1.0, 1.0)
	size = Vector2(92.0, 56.0)
	position = Vector2(455.0, 168.0)

	for ch in get_children():
		if ch is Control:
			ch.visible = (ch.name == "DeliktekiKagit")

	var t = create_tween()
	t.tween_interval(0.22)
	t.tween_property(self, "position:y", 195.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_callback(func():
		if visible and not masada_acik:
			masaya_ac(false)
	)

func masaya_ac(fare_tutuyor: bool = true) -> void:
	if masada_acik: return
	masada_acik = true
	visible = true
	size = Vector2(246.0, 288.0)
	scale = Vector2(MASA_OLCEK, MASA_OLCEK)

	for ch in get_children():
		if ch is Control:
			if ch.name == "DeliktekiKagit" or ch.name == "DamgaGorsel":
				ch.visible = false
			else:
				ch.visible = true

	if fare_tutuyor:
		drag_offset = Vector2(size.x * 0.5 * MASA_OLCEK, 32.0 * MASA_OLCEK)
		var hedef_pos = get_global_mouse_position() - drag_offset
		hedef_pos.x = clampf(hedef_pos.x, 10.0, 1024.0 - size.x * MASA_OLCEK)
		hedef_pos.y = clampf(hedef_pos.y, 140.0, 576.0 - size.y * MASA_OLCEK)
		global_position = hedef_pos
		is_dragging = true
	else:
		var ana = _get_ana()
		var hedef_masa_pos = Vector2(430.0, 268.0)
		if ana:
			var kk = ana.get_node_or_null("KuralKitabiPaneli")
			var gz = ana.get_node_or_null("GazeteOkumaPaneli")
			if (kk and kk.visible) or (gz and gz.visible):
				hedef_masa_pos = Vector2(692.0, 142.0)
		scale = Vector2(0.55, 0.55)
		var t = create_tween()
		t.parallel().tween_property(self, "position", hedef_masa_pos, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(self, "scale", Vector2(MASA_OLCEK, MASA_OLCEK), 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _gui_input(event: InputEvent) -> void:
	var ana = _get_ana()
	var inceleme_aktif: bool = (ana != null and ana.get("inceleme_modu_aktif") == true)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_global_pos = get_global_mouse_position()
			_press_local_pos = get_local_mouse_position()
			_dragged_far = false
			if not masada_acik:
				masaya_ac(not inceleme_aktif)
				if inceleme_aktif:
					_inceleme_tiklamasi(Vector2(120.0, 140.0))
			else:
				is_dragging = true
				drag_offset = get_global_mouse_position() - global_position
			accept_event()
		else:
			var was_dragging = is_dragging
			if is_dragging:
				_surukleme_bitti()
			if inceleme_aktif and not _dragged_far and was_dragging:
				_inceleme_tiklamasi(get_local_mouse_position())
			accept_event()

	elif event is InputEventMouseMotion and is_dragging:
		if get_global_mouse_position().distance_to(_press_global_pos) > 10.0:
			_dragged_far = true
		var yeni_pos = get_global_mouse_position() - drag_offset
		yeni_pos.x = clampf(yeni_pos.x, 5.0, 1024.0 - 60.0)
		yeni_pos.y = clampf(yeni_pos.y, 130.0, 576.0 - 60.0)
		global_position = yeni_pos

		# Sadece gişe penceresinin içine doğru itildiğinde küçülsün, masanın hiçbir yerinde küçülmesin
		pivot_offset = Vector2(size.x * 0.5, 25.0)
		if yeni_pos.y < 188.0 and yeni_pos.x > 330.0 and yeni_pos.x < 670.0:
			var t_oran = clampf((yeni_pos.y - 130.0) / 58.0, 0.45, 1.0) * MASA_OLCEK
			scale = Vector2(t_oran, t_oran)
		else:
			scale = Vector2(MASA_OLCEK, MASA_OLCEK)

		accept_event()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_dragging:
			var ana = _get_ana()
			var inceleme_aktif: bool = (ana != null and ana.get("inceleme_modu_aktif") == true)
			_surukleme_bitti()
			if inceleme_aktif and not _dragged_far:
				_inceleme_tiklamasi(get_local_mouse_position())

func _surukleme_bitti() -> void:
	if not is_dragging:
		return
	is_dragging = false
	var ana = _get_ana()
	if not ana: return

	# Gişede mahkum yoksa teslimat yapılamaz
	if not ana.get("gisede_mahkum_var"):
		if scale.x != MASA_OLCEK:
			var t_s = create_tween()
			t_s.tween_property(self, "scale", Vector2(MASA_OLCEK, MASA_OLCEK), 0.15).set_trans(Tween.TRANS_SINE)
		return

	# Mahkum penceresi veya teslim bölmesine sürüklendiyse (Papers Please tarzı küçülerek teslim)
	var damgali_mi: bool = (str(ana.get("secilen_damga")) != "")
	var teslim_esik_y: float = 248.0 if damgali_mi else 202.0
	if masada_acik and (global_position.y < teslim_esik_y and global_position.x > 290.0 and global_position.x < 690.0):
		if damgali_mi:
			masada_acik = false
			var t = create_tween()
			t.parallel().tween_property(self, "scale", Vector2(0.22, 0.22), 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			t.parallel().tween_property(self, "position:y", 155.0, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			t.parallel().tween_property(self, "modulate:a", 0.0, 0.30)
			t.tween_callback(func():
				visible = false
			)
			if ana.has_method("_on_teslim_et_basildi"):
				ana._on_teslim_et_basildi()
		else:
			if ana.has_method("bildirim_goster"):
				ana.bildirim_goster("UYARI: Mahkuma vermeden önce kağıdı sağdaki mührün altına sürükleyip mühürleyin!", Color(1.0, 0.85, 0.3))
			var t = create_tween()
			t.parallel().tween_property(self, "scale", Vector2(MASA_OLCEK, MASA_OLCEK), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(self, "position:y", 268.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		if scale.x != MASA_OLCEK:
			var t = create_tween()
			t.tween_property(self, "scale", Vector2(MASA_OLCEK, MASA_OLCEK), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _inceleme_tiklamasi(pos: Vector2) -> void:
	var ana = _get_ana()
	if not ana or not ana.has_method("inceleme_ogesi_secildi"): return

	if pos.x >= 14.0 and pos.x <= 98.0 and pos.y >= 45.0 and pos.y <= 155.0:
		ana.inceleme_ogesi_secildi("fis_foto", "Fişteki Fotoğraf", find_child("VesikalikGorsel"))
	elif pos.x >= 100.0 and pos.y >= 45.0 and pos.y <= 78.0:
		ana.inceleme_ogesi_secildi("fis_sicil", "Fişteki Sicil No", find_child("SicilDeger"))
	elif pos.x >= 100.0 and pos.y >= 79.0 and pos.y <= 113.0:
		ana.inceleme_ogesi_secildi("fis_blok", "Fişteki Blok Bilgisi", find_child("BlokDeger"))
	elif pos.x >= 100.0 and pos.y >= 114.0 and pos.y <= 150.0:
		ana.inceleme_ogesi_secildi("fis_izin", "Fişteki İzin Durumu", find_child("IzinDeger"))
	elif pos.y >= 168.0 and pos.y <= 190.0:
		ana.inceleme_ogesi_secildi("fis_talep_ilac", "Fişteki İlaç Talebi", find_child("SatirIlacAd"))
	elif pos.y >= 191.0 and pos.y <= 210.0:
		ana.inceleme_ogesi_secildi("fis_talep_yemek", "Fişteki Yiyecek Talebi", find_child("SatirYemekAd"))
	elif pos.y >= 211.0 and pos.y <= 234.0:
		ana.inceleme_ogesi_secildi("fis_talep_icecek", "Fişteki İçecek Talebi", find_child("SatirIcecekAd"))
	elif pos.x < 115.0 and pos.y >= 235.0:
		ana.inceleme_ogesi_secildi("fis_tarih", "Fişteki Tarih", find_child("TarihDeger"))
	elif pos.x >= 115.0 and pos.y >= 235.0:
		ana.inceleme_ogesi_secildi("fis_imza", "Fişteki Gardiyan İmzası", find_child("OnayDeger"))
	else:
		ana.inceleme_ogesi_secildi("fis_genel", "Talep Fişi", self)

func damga_bas(tip: String, yerel_pos: Variant = null) -> void:
	if not masada_acik:
		masaya_ac(false)
	var damga_rect: TextureRect = find_child("DamgaGorsel")
	if not damga_rect:
		return

	if tip == "ONAYLANDI":
		damga_rect.texture = baski_onay
		damga_rect.modulate = Color(1.0, 1.0, 1.0, 0.96)
	else:
		damga_rect.texture = baski_red
		damga_rect.modulate = Color(1.0, 1.0, 1.0, 0.96)

	damga_rect.visible = true
	damga_rect.pivot_offset = damga_rect.size * 0.5

	# Eğer mühür belirli bir noktaya vurulduysa tam o noktaya yerleştir
	if yerel_pos is Vector2 and yerel_pos != Vector2(-1, -1):
		var hedef_x = yerel_pos.x - damga_rect.size.x * 0.5
		var hedef_y = yerel_pos.y - damga_rect.size.y * 0.5
		damga_rect.position.x = clampf(hedef_x, 4.0, size.x - damga_rect.size.x - 4.0)
		damga_rect.position.y = clampf(hedef_y, 12.0, size.y - damga_rect.size.y - 6.0)
		damga_rect.rotation = randf_range(-0.10, 0.08)
	else:
		damga_rect.position = Vector2(36.0, 168.0)
		damga_rect.rotation = -0.09

	# Vuruş slam darbe animasyonu (Papers Please kauçuk mühür darbe hissi)
	damga_rect.scale = Vector2(1.3, 1.3)
	var t = create_tween()
	t.tween_property(damga_rect, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func rastgele_burusukluk_sec() -> void:
	var kagit_doku = find_child("KagitDokusu")
	if kagit_doku and burusuk_kagitlar.size() > 0:
		kagit_doku.texture = burusuk_kagitlar[randi() % burusuk_kagitlar.size()]
