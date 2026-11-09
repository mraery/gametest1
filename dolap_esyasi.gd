extends TextureRect

@export var esya_kodu: String = "ilac"
@export var esya_adi: String = "Ağrı Kesici (İlaç)"

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var baslangic_pos: Vector2 = Vector2.ZERO
var baslangic_yerel_pos: Vector2 = Vector2.ZERO
var _press_pos: Vector2 = Vector2.ZERO
var _secili_basildi: bool = false
var masada_secili: bool = false
var yuva_indeksi: int = -1

func _ready() -> void:
	z_as_relative = false
	z_index = 16
	baslangic_yerel_pos = position
	baslangic_pos = global_position
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	await get_tree().process_frame
	if not is_dragging and not masada_secili:
		baslangic_pos = global_position

func _get_ana() -> Node:
	if get_tree() and get_tree().current_scene:
		return get_tree().current_scene
	if owner:
		return owner
	var n = get_parent()
	while n:
		if n.name == "masa" or n.has_method("dolap_esyalarini_kontrol_et"):
			return n
		n = n.get_parent()
	return null

func _kategori_id() -> String:
	if esya_kodu in ["ilac", "sargi", "ilac_yesil", "ilac_mavi", "ilac_kehribar"]:
		return "esya_ilac"
	elif esya_kodu in ["konserve", "cips"]:
		return "esya_yemek"
	return "esya_icecek"

func _gui_input(event: InputEvent) -> void:
	var ana = _get_ana()
	var inceleme_aktif: bool = (ana != null and ana.get("inceleme_modu_aktif") == true)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if masada_secili:
				rafina_don()
				if ana and ana.has_method("ses_oynat") and ana.get("ses_dugme"):
					ana.ses_oynat(ana.get("ses_dugme"), -4.0)
				if ana and ana.has_method("dolap_esyalarini_kontrol_et"):
					ana.dolap_esyalarini_kontrol_et()
				accept_event()
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if inceleme_aktif and ana and ana.has_method("inceleme_ogesi_secildi"):
					ana.inceleme_ogesi_secildi(_kategori_id(), "Dolap Eşyası: " + esya_adi, self)
					accept_event()
					return
				is_dragging = true
				_press_pos = get_global_mouse_position()
				_secili_basildi = masada_secili
				drag_offset = get_global_mouse_position() - global_position
				z_index = 40
				pivot_offset = size * 0.5
				scale = Vector2(1.25, 1.25)
				accept_event()
			else:
				if is_dragging:
					_surukleme_bitti()
					accept_event()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_dragging:
			_surukleme_bitti()

func _process(_delta: float) -> void:
	if is_dragging:
		var yeni_pos = get_global_mouse_position() - drag_offset
		yeni_pos.x = clampf(yeni_pos.x, 4.0, 1020.0 - size.x)
		yeni_pos.y = clampf(yeni_pos.y, 160.0, 565.0 - size.y)
		global_position = yeni_pos

func _surukleme_bitti() -> void:
	if not is_dragging:
		return
	is_dragging = false
	z_index = 16
	pivot_offset = size * 0.5
	var dist = get_global_mouse_position().distance_to(_press_pos)
	var merkez = global_position + size * 0.5
	var ana = _get_ana()

	# Zaten teslim bölmesindeyken üzerine tek tıklandıysa rafa geri dönsün
	if _secili_basildi and dist < 8.0:
		rafina_don()
		if ana and ana.has_method("ses_oynat") and ana.get("ses_dugme"):
			ana.ses_oynat(ana.get("ses_dugme"), -4.0)
		if ana and ana.has_method("dolap_esyalarini_kontrol_et"):
			ana.dolap_esyalarini_kontrol_et()
		return

	# Dolaptaki bir eşyaya tek tıklandıysa veya masaya/teslim bölmesine sürüklendiyse doğrudan Teslim Bölmesi yuvasına yerleşsin
	if (not _secili_basildi and dist < 8.0) or (merkez.x >= 280.0 and merkez.y >= 155.0):
		masada_secili = true
		var hedef_pos: Vector2 = Vector2(394.0, 217.0)
		if ana and ana.has_method("teslim_yuvasi_bul"):
			hedef_pos = ana.teslim_yuvasi_bul(self)
		var t = create_tween()
		t.tween_property(self, "global_position", hedef_pos, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(self, "scale", Vector2(1.12, 1.12), 0.14)
		if ana and ana.has_method("ses_oynat") and ana.get("ses_dugme"):
			ana.ses_oynat(ana.get("ses_dugme"), -4.0)
	else:
		rafina_don()

	if ana and ana.has_method("dolap_esyalarini_kontrol_et"):
		ana.dolap_esyalarini_kontrol_et()
	if ana and ana.has_method("_masa_katmanlarini_duzenle"):
		ana._masa_katmanlarini_duzenle()

func mahkuma_teslim_animasyonu() -> void:
	yuva_indeksi = -1
	z_index = 16
	var t = create_tween()
	t.tween_property(self, "global_position:y", 178.0, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(self, "scale", Vector2(0.45, 0.45), 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(self, "modulate:a", 0.0, 0.32)
	t.tween_callback(func():
		masada_secili = false
		position = baslangic_yerel_pos
		scale = Vector2(1.0, 1.0)
		modulate.a = 1.0
	)

func rafina_don() -> void:
	masada_secili = false
	yuva_indeksi = -1
	z_index = 16
	modulate.a = 1.0
	var t = create_tween()
	t.tween_property(self, "position", baslangic_yerel_pos, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_SINE)
