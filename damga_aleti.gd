extends TextureButton

@export var damga_tipi: String = "ONAYLANDI"

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var baslangic_yerel_pos: Vector2 = Vector2.ZERO
var press_start_pos: Vector2 = Vector2.ZERO

var golge_node: Control = null
var golge_baslangic_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	baslangic_yerel_pos = position
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	call_deferred("_golgeyi_bul")

func _golgeyi_bul() -> void:
	var p = get_parent()
	if p:
		var ad = "GolgeRed" if damga_tipi == "REDDEDİLDİ" else "GolgeOnay"
		golge_node = p.find_child(ad)
		if golge_node:
			golge_baslangic_pos = golge_node.position

func _process(_delta: float) -> void:
	if is_dragging:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		return
	var ana = _get_ana()
	var fis = ana.find_child("TalepFisi") if ana else null
	if fis and fis.visible and fis.get("masada_acik") and ana and ana.get("gisede_mahkum_var"):
		var fis_rect = Rect2(fis.global_position, fis.size * fis.scale)
		var damga_rect = Rect2(global_position, size).grow(-6.0)
		if fis_rect.intersects(damga_rect):
			modulate = Color(1.18, 1.15, 1.04, 1.0)
			return
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func _get_ana() -> Node:
	if get_tree().current_scene:
		return get_tree().current_scene
	if owner:
		return owner
	var n = get_parent()
	while n:
		if n.name == "masa" or n.has_method("bildirim_goster"):
			return n
		n = n.get_parent()
	return null

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var ana = _get_ana()
			if ana and not ana.get("gisede_mahkum_var"):
				if ana.has_method("bildirim_goster"):
					ana.bildirim_goster("Gişede mahkum yok! Önce KIRMIZI DÜĞMEYE basarak mahkum çağırın.", Color.YELLOW)
				return
			if ana and ana.get("cekmece_acik") == false and ana.has_method("_on_cekmece_kol_basildi"):
				ana._on_cekmece_kol_basildi()

			is_dragging = true
			press_start_pos = get_global_mouse_position()
			drag_offset = get_global_mouse_position() - global_position
			scale = Vector2(1.15, 1.15)
			pivot_offset = size * 0.5
			z_as_relative = false
			z_index = 65
			if golge_node:
				golge_node.z_as_relative = false
				golge_node.z_index = 63
				golge_node.scale = Vector2(1.15, 1.15)
			accept_event()
		else:
			if is_dragging:
				_birakildi()
				accept_event()

	elif event is InputEventMouseMotion and is_dragging:
		var yeni_pos = get_global_mouse_position() - drag_offset
		global_position = Vector2(clampf(yeni_pos.x, 10.0, 1024.0 - size.x), clampf(yeni_pos.y, 40.0, 571.0 - size.y))
		if golge_node:
			golge_node.global_position = global_position + Vector2(4.0, size.y * 0.65)
		accept_event()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_dragging:
			_birakildi()

func _birakildi() -> void:
	if not is_dragging: return
	is_dragging = false
	var ana = _get_ana()
	var dist = get_global_mouse_position().distance_to(press_start_pos)

	var fis = ana.find_child("TalepFisi") if ana else null
	var kagit_altta_mi: bool = false
	var yerel_vurus_pos: Vector2 = Vector2(-1, -1)

	if fis and fis.visible and fis.get("masada_acik") and ana and ana.get("gisede_mahkum_var"):
		var fis_rect = Rect2(fis.global_position, fis.size * fis.scale)
		var damga_rect = Rect2(global_position, size).grow(-6.0)
		var damga_taban = global_position + Vector2(size.x * 0.5, size.y * 0.78)
		var damga_merkez = global_position + size * 0.5

		# Kağıt mührün fiziksel olarak altında mı? (Çekmecede mührün altına sürüklendiyse veya mühür kağıda sürüklendiyse)
		if fis_rect.intersects(damga_rect) or fis_rect.has_point(damga_taban) or fis_rect.has_point(damga_merkez):
			kagit_altta_mi = true
			var vurus_noktasi = damga_taban if fis_rect.has_point(damga_taban) else damga_merkez
			vurus_noktasi.x = clampf(vurus_noktasi.x, fis_rect.position.x + 28.0, fis_rect.end.x - 28.0)
			vurus_noktasi.y = clampf(vurus_noktasi.y, fis_rect.position.y + 28.0, fis_rect.end.y - 28.0)
			yerel_vurus_pos = (vurus_noktasi - fis.global_position) / fis.scale

	# 1. Durum: Kağıt mührün ALTINDA -> Mühür basılır!
	if kagit_altta_mi:
		if ana and ana.has_method("ses_oynat") and ana.get("ses_damga"):
			ana.ses_oynat(ana.get("ses_damga"))
		if ana:
			ana.set("secilen_damga", damga_tipi)

		# Belgeye mühür bas
		if fis and fis.has_method("damga_bas"):
			fis.damga_bas(damga_tipi, yerel_vurus_pos)

		if ana and ana.has_method("bildirim_goster"):
			var renk = Color(0.2, 0.95, 0.4) if damga_tipi == "ONAYLANDI" else Color(1.0, 0.25, 0.25)
			ana.bildirim_goster("Evrak " + ("ONAYLANDI" if damga_tipi == "ONAYLANDI" else "REDDEDİLDİ") + " olarak mühürlendi.", renk)

		# Sürüklenerek basıldıysa slam darbe animasyonu yapıp çekmeceye dönsün
		if dist >= 8.0:
			var t_slam = create_tween()
			t_slam.tween_property(self, "scale", Vector2(0.88, 0.88), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			t_slam.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			if golge_node:
				var tg = create_tween()
				tg.tween_property(golge_node, "scale:y", 0.4, 0.08)
				tg.tween_property(golge_node, "scale:y", 1.0, 0.1)

			var t_don = create_tween()
			t_don.tween_interval(0.18)
			t_don.tween_property(self, "position", baslangic_yerel_pos, 0.26).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			t_don.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.26)
			t_don.tween_callback(func():
				z_index = 26
			)
			if golge_node:
				var t_gdon = create_tween()
				t_gdon.tween_interval(0.18)
				t_gdon.tween_property(golge_node, "position", golge_baslangic_pos, 0.26).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				t_gdon.parallel().tween_property(golge_node, "scale", Vector2(1.0, 1.0), 0.26)
				t_gdon.tween_callback(func():
					golge_node.z_index = 22
				)

		# Çekmecede kağıdın üzerine tıklanıp basıldıysa yuvasında dikey inip çıksın
		else:
			var t = create_tween()
			t.tween_property(self, "position:y", baslangic_yerel_pos.y + 16.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			t.tween_property(self, "position:y", baslangic_yerel_pos.y, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.12)
			t.tween_callback(func():
				z_index = 26
			)
			if golge_node:
				var tg = create_tween()
				tg.tween_property(golge_node, "scale:y", 0.45, 0.08)
				tg.tween_property(golge_node, "scale:y", 1.0, 0.12)

	# 2. Durum: Kağıt mührün altında DEĞİL -> OTOMATİK BASMAZ!
	else:
		# Çekmecede tıklandı ama kağıt mührün altına getirilmemiş
		if dist < 8.0:
			var t = create_tween()
			t.tween_property(self, "position:y", baslangic_yerel_pos.y + 14.0, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			t.tween_property(self, "position:y", baslangic_yerel_pos.y, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.12)
			t.tween_callback(func():
				z_index = 26
			)
			if golge_node:
				var tg = create_tween()
				tg.tween_property(golge_node, "scale:y", 0.5, 0.07)
				tg.tween_property(golge_node, "scale:y", 1.0, 0.12)

			if ana and ana.has_method("bildirim_goster"):
				ana.bildirim_goster("Evrak mührün altında değil! Mühür basmak için evrakı mührün altına getirin.", Color(1.0, 0.78, 0.25))

		# Masada boş yere bırakıldı -> çekmeceye geri dön
		else:
			if ana and ana.has_method("bildirim_goster"):
				ana.bildirim_goster("Evrak mührün altında değil! Mühür basmak için evrakı mührün altına getirin.", Color(0.95, 0.88, 0.55))
			var t_don = create_tween()
			t_don.tween_property(self, "position", baslangic_yerel_pos, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t_don.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.22)
			t_don.tween_callback(func():
				z_index = 26
			)
			if golge_node:
				var t_gdon = create_tween()
				t_gdon.tween_property(golge_node, "position", golge_baslangic_pos, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				t_gdon.parallel().tween_property(golge_node, "scale", Vector2(1.0, 1.0), 0.22)
				t_gdon.tween_callback(func():
					golge_node.z_index = 22
				)
