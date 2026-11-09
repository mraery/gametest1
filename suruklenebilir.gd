extends Control

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var press_start_pos: Vector2 = Vector2.ZERO
var has_moved: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	z_as_relative = false
	if name.ends_with("Paneli"):
		z_index = 32
	else:
		z_index = 8

func _get_ana() -> Node:
	if get_tree() and get_tree().current_scene:
		return get_tree().current_scene
	if owner:
		return owner
	var n = get_parent()
	while n:
		if n.name == "masa" or n.has_method("inceleme_ogesi_secildi"):
			return n
		n = n.get_parent()
	return null

func _gui_input(event: InputEvent) -> void:
	var ana = _get_ana()
	var inceleme_aktif: bool = (ana != null and ana.get("inceleme_modu_aktif") == true)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			has_moved = false
			press_start_pos = get_global_mouse_position()
			drag_offset = get_global_mouse_position() - global_position
			if ana and ana.has_method("_masa_katmanlarini_duzenle"):
				ana._masa_katmanlarini_duzenle()
			accept_event()
		else:
			if is_dragging:
				var dist = get_global_mouse_position().distance_to(press_start_pos)
				is_dragging = false
				accept_event()
				if dist <= 10.0:
					if inceleme_aktif:
						_inceleme_tiklandi(get_local_mouse_position(), ana)
					else:
						_tiklandi()

	elif event is InputEventMouseMotion and is_dragging:
		var dist = get_global_mouse_position().distance_to(press_start_pos)
		if dist > 10.0:
			has_moved = true
		var yeni_pos = get_global_mouse_position() - drag_offset
		var min_y = 32.0 if (name.ends_with("Paneli")) else 140.0
		yeni_pos.x = clampf(yeni_pos.x, 0.0, 1024.0 - size.x * 0.3)
		yeni_pos.y = clampf(yeni_pos.y, min_y, 576.0 - size.y * 0.3)
		global_position = yeni_pos
		accept_event()

func _inceleme_tiklandi(local_pos: Vector2, ana: Node) -> void:
	if not ana: return
	if name == "KuralKitabiPaneli":
		_inceleme_kural_kitabi(local_pos, ana)
	elif name == "GazeteOkumaPaneli":
		_inceleme_gazete(local_pos, ana)
	elif name == "GardiyanEmri":
		ana.inceleme_ogesi_secildi("emir_notu", "Warden Graves'in Günlük Emri", self)
	elif name == "KuralKitabi":
		_tiklandi()
		var sec1 = ana.get("secilen_inceleme_1")
		if sec1 is Dictionary and not sec1.is_empty():
			var kp = ana.find_child("KuralKitabiPaneli") as Control
			ana.inceleme_ogesi_secildi("kural_evrak", "Kural Kitabı (Blok & Evrak Kuralları)", kp if (kp and kp.visible) else self)
	elif name == "CezaeviPostasi":
		_tiklandi()
		var sec1 = ana.get("secilen_inceleme_1")
		if sec1 is Dictionary and not sec1.is_empty():
			var gp = ana.find_child("GazeteOkumaPaneli") as Control
			ana.inceleme_ogesi_secildi("gazete_haber", "Cezaevi Postası (Günlük Duyuru)", gp if (gp and gp.visible) else self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		call_deferred("_reset_drag")

func _reset_drag() -> void:
	is_dragging = false

func _tiklandi() -> void:
	var ana = _get_ana()
	if not ana: return
	if name == "CezaeviPostasi" and ana.has_method("gazete_okuma_ac_kapat"):
		ana.gazete_okuma_ac_kapat()
	elif name == "KuralKitabi" and ana.has_method("kural_kitabi_ac_kapat"):
		ana.kural_kitabi_ac_kapat()
	elif name == "GardiyanEmri":
		if ana.has_method("_masa_katmanlarini_duzenle"):
			ana._masa_katmanlarini_duzenle()
		pivot_offset = size * 0.5
		var t = create_tween()
		t.tween_property(self, "scale", Vector2(1.16, 1.16), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_interval(1.4)
		t.tween_property(self, "scale", Vector2(1.0, 1.0), 0.16)

func _inceleme_kural_kitabi(pos: Vector2, ana: Node) -> void:
	if not ana or not ana.has_method("inceleme_ogesi_secildi"): return
	if ana.has_method("kural_kitabi_sayfa_degistir"):
		ana.kural_kitabi_sayfa_degistir(1)
	if pos.x < 228.0:
		if pos.y < 130.0:
			ana.inceleme_ogesi_secildi("kural_blok", ana.blok_aciklama("A Blok"), find_child("ABlokIcerik"))
		elif pos.y < 215.0:
			ana.inceleme_ogesi_secildi("kural_blok", ana.blok_aciklama("B Blok"), find_child("BBlokIcerik"))
		else:
			ana.inceleme_ogesi_secildi("kural_blok", ana.blok_aciklama("C Blok"), find_child("CBlokIcerik"))
	else:
		ana.inceleme_ogesi_secildi("kural_evrak", "Kural Kitabı (Evrak & Onay Şartları)", find_child("EvrakKuralIcerik"))

func _inceleme_gazete(pos: Vector2, ana: Node) -> void:
	if not ana or not ana.has_method("inceleme_ogesi_secildi"): return
	if pos.x < 230.0:
		ana.inceleme_ogesi_secildi("gazete_haber", "Gazete: Nakil ve Arananlar Sütunu", find_child("Aranan1Yazi"))
	else:
		ana.inceleme_ogesi_secildi("gazete_haber", "Gazete Gündem (Bugünün Duyuruları)", find_child("SagUstYazi"))
