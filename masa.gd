extends Control

var secilen_damga: String = ""
var ilac_secildi: bool = false
var yemek_secildi: bool = false
var icecek_secildi: bool = false

var aktif_mahkum_indeksi: int = -1
var gisede_mahkum_var: bool = false
var yeni_mahkum_geliyor: bool = false
var tween_kepenk: Tween = null
var cekmece_acik: bool = true

var siluet_dugumleri: Array[TextureRect] = []
var siluet_baslangic_y: Array[float] = []
var kuyruk_yuruyor: bool = false
var oyuncu_parasi: int = 60

var inceleme_modu_aktif: bool = false
var secilen_inceleme_1: Dictionary = {}
var secilen_inceleme_2: Dictionary = {}
var hedef_isaretleyici_1: ReferenceRect = null
var hedef_isaretleyici_2: ReferenceRect = null
var inceleme_cizgisi: Line2D = null

var ses_dugme = preload("res://assets/ses_dugme.wav")
var ses_konusma = preload("res://assets/ses_konusma.wav")
var ses_damga = preload("res://assets/ses_damga.wav")
var ses_cekmece = preload("res://assets/ses_cekmece.wav")
var ses_kitap = preload("res://assets/ses_kitap.wav")
var ses_para = preload("res://assets/ses_para.wav")
var ses_yazici = preload("res://assets/ses_yazici.wav")
var ses_ayak = preload("res://assets/ses_ayak.wav")
var ses_thud = preload("res://assets/ses_thud.wav")
var ses_buzz = preload("res://assets/ses_buzz.wav")
var ses_gicirti = preload("res://assets/ses_gicirti.wav")
var ses_alarm = preload("res://assets/ses_alarm.wav")

func ses_oynat(stream: AudioStream, vol: float = 0.0) -> void:
	if not stream: return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = vol
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

var kuyruk_dokulari = [
	preload("res://assets/kuyruk_1.png"),
	preload("res://assets/kuyruk_2.png"),
	preload("res://assets/kuyruk_3.png"),
	preload("res://assets/kuyruk_4.png"),
	preload("res://assets/kuyruk_5.png"),
	preload("res://assets/kuyruk_6.png"),
	preload("res://assets/kuyruk_7.png")
]

const Hikaye = preload("res://hikaye.gd")

var mahkum_listesi: Array = []
var blok_kurallari: Dictionary = {}
var gun_verisi: Dictionary = {}
var bugun_tarih: String = ""
var gecerli_gardiyanlar: Array = []
var nakledilenler: Array = []
var gun_dogru: int = 0
var gun_hata: int = 0
var gun_kazanc: int = 0
var gun_rusvet: int = 0
var toplam_rusvet: int = 0
var kanit_sayisi: int = 0
var direnis_puani: int = 0
var sadakat_puani: int = 0
var gece_secim_ozeti: String = ""
var uyari_sayisi: int = 0
var rusvet_teklif_var: bool = false
var mahkum_ayriliyor: bool = false
var oyun_bitti: bool = false
var gun_sonu_basladi: bool = false
var olay_paneli_acik: bool = false
var gorevli_tumunu_atla: bool = false
var elias_karari: String = ""
var g_balon_panel: PanelContainer = null
var p_balon_panel: PanelContainer = null
var teslim_durum_etiketi: Label = null
var rusvet_dugumu: PanelContainer = null
var pusula_dugumu: PanelContainer = null
var aktif_pusula_verisi: Dictionary = {}
var mahkum_notu_dugumu: TextureRect = null
var _not_surukleniyor: bool = false
var _not_drag_offset: Vector2 = Vector2.ZERO
var _pusula_secildi: bool = false
var ihtar_dugumu: Control = null
var _ihtar_surukleniyor: bool = false
var _ihtar_drag_offset: Vector2 = Vector2.ZERO
var _ihtar_tween: Tween = null
var ad_deger_lbl: Label = null
var mahkum_isim_plakasi: Control = null
var plaka_yazi_lbl: Label = null
var hikaye_durum_yazisi: Label = null
var siradaki_etiket_lbl: Label = null
var menu_butonu: Button = null
var atla_butonu: Button = null
var sorgu_butonu: Button = null
var ana_menu_acik: bool = false
const KAYIT_DOSYASI: String = "user://ironhold_kayit.cfg"

var dolap_esya_dugumleri: Array = []
var aktif_gun: int = 1
var gorevli_teslimatta: bool = false

func _ready() -> void:
	var btn_siradaki = find_child("SiradakiButonu")
	if btn_siradaki:
		btn_siradaki.focus_mode = Control.FOCUS_NONE
		btn_siradaki.pressed.connect(_on_siradaki_basildi)

	for ch in get_children():
		if ch.name.begins_with("Esya"):
			dolap_esya_dugumleri.append(ch)

	# Damga butonları artık fiziksel sürüklenebilir nesneler (damga_aleti.gd)
	# Tıklama, sürükleme ve mühürleme mantığı damga_aleti.gd tarafından yönetilir.

	var btn_cekmece = find_child("CekmeceKolButonu")
	if btn_cekmece:
		btn_cekmece.focus_mode = Control.FOCUS_NONE
		btn_cekmece.pressed.connect(_on_cekmece_kol_basildi)

	var btn_teslim = find_child("TeslimEtButonu")
	if btn_teslim:
		btn_teslim.focus_mode = Control.FOCUS_NONE
		btn_teslim.pressed.connect(_on_teslim_et_basildi)

	var btn_gazete_kapat = find_child("GazeteKapatButonu")
	if btn_gazete_kapat:
		btn_gazete_kapat.focus_mode = Control.FOCUS_NONE
		btn_gazete_kapat.pressed.connect(gazete_okuma_ac_kapat)

	var btn_kitap_kapat = find_child("KitapKapatButonu")
	if btn_kitap_kapat:
		btn_kitap_kapat.focus_mode = Control.FOCUS_NONE
		btn_kitap_kapat.pressed.connect(kural_kitabi_ac_kapat)

	var btn_sayfa1 = find_child("KitapSayfa1Butonu")
	if btn_sayfa1:
		btn_sayfa1.focus_mode = Control.FOCUS_NONE
		btn_sayfa1.pressed.connect(func(): kural_kitabi_sayfa_degistir(1))

	var btn_sayfa2 = find_child("KitapSayfa2Butonu")
	if btn_sayfa2:
		btn_sayfa2.focus_mode = Control.FOCUS_NONE
		btn_sayfa2.pressed.connect(func(): kural_kitabi_sayfa_degistir(2))

	var btn_incele = find_child("IncelemeButonu")
	if btn_incele:
		btn_incele.focus_mode = Control.FOCUS_NONE
		btn_incele.pressed.connect(_on_inceleme_butonu_basildi)

	var bildirim_kutusu = find_child("BildirimKutusu") as Control
	if bildirim_kutusu:
		bildirim_kutusu.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for bc in bildirim_kutusu.get_children():
			if bc is Control:
				bc.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var pencere = find_child("MahkumPenceresi")
	if pencere:
		pencere.mouse_filter = Control.MOUSE_FILTER_STOP
		pencere.gui_input.connect(func(event: InputEvent):
			if not inceleme_modu_aktif: return
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				var gorsel = find_child("MahkumGorsel")
				inceleme_ogesi_secildi("mahkum_yuz", "Gişedeki Mahkumun Yüzü", gorsel if gorsel else pencere)
				pencere.accept_event()
		)

	var balon_node = find_child("KonusmaBalonu")
	if balon_node:
		balon_node.mouse_filter = Control.MOUSE_FILTER_STOP
		for c in balon_node.get_children():
			if c is Control:
				c.mouse_filter = Control.MOUSE_FILTER_IGNORE
				for cc in c.get_children():
					if cc is Control:
						cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		balon_node.gui_input.connect(func(event: InputEvent):
			if not inceleme_modu_aktif: return
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				inceleme_ogesi_secildi("mahkum_replik", "Mahkumun Söylediği Replik", balon_node)
				balon_node.accept_event()
		)

	hedef_isaretleyici_1 = ReferenceRect.new()
	hedef_isaretleyici_1.editor_only = false
	hedef_isaretleyici_1.border_color = Color(1.0, 0.24, 0.14, 0.98)
	hedef_isaretleyici_1.border_width = 3.0
	hedef_isaretleyici_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hedef_isaretleyici_1.z_as_relative = false
	hedef_isaretleyici_1.z_index = 89
	hedef_isaretleyici_1.visible = false
	add_child(hedef_isaretleyici_1)

	hedef_isaretleyici_2 = ReferenceRect.new()
	hedef_isaretleyici_2.editor_only = false
	hedef_isaretleyici_2.border_color = Color(1.0, 0.24, 0.14, 0.98)
	hedef_isaretleyici_2.border_width = 3.0
	hedef_isaretleyici_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hedef_isaretleyici_2.z_as_relative = false
	hedef_isaretleyici_2.z_index = 89
	hedef_isaretleyici_2.visible = false
	add_child(hedef_isaretleyici_2)

	inceleme_cizgisi = Line2D.new()
	inceleme_cizgisi.width = 3.0
	inceleme_cizgisi.default_color = Color(1.0, 0.28, 0.16, 0.92)
	inceleme_cizgisi.z_as_relative = false
	inceleme_cizgisi.z_index = 88
	inceleme_cizgisi.visible = false
	add_child(inceleme_cizgisi)

	dolap_esyalarini_kontrol_et()
	nefes_animasyonu_baslat()

	# Kuyruk siluet düğümlerini (10 adet, tek sıra, yan yana) hazırla
	siluet_dugumleri.clear()
	siluet_baslangic_y.clear()
	for i in range(1, 11):
		var s = find_child("Siluet" + str(i)) as TextureRect
		if s:
			siluet_dugumleri.append(s)
			siluet_baslangic_y.append(104.0)
			s.position.y = 104.0
			s.pivot_offset = Vector2(18.0, 86.0)

	olustur_kasa_hud()
	atmosfer_kur()
	_balonlari_hazirla()
	_ad_etiketi_olustur()
	_inceleme_butonu_susle()
	_siradaki_etiket_olustur()
	_teslim_bolmesi_etiketi_olustur()
	_rusvet_karti_olustur()
	_pusula_karti_olustur()
	_mahkum_notu_olustur()
	_ihtar_karti_olustur()

	# Oyun başlangıcında gişe boş başlar. İstenirse hemen kural kitabı veya gazete okunabilir!
	gisede_mahkum_var = false
	aktif_mahkum_indeksi = -1
	yeni_mahkum_geliyor = false

	var fis = find_child("TalepFisi")
	if fis: fis.visible = false

	var balon = find_child("KonusmaBalonu")
	if balon: balon.visible = false

	var kepenk = find_child("Kepenk")
	if kepenk: kepenk.position.y = 0.0

	var mahkum_gorsel = find_child("MahkumGorsel")
	if mahkum_gorsel: mahkum_gorsel.modulate.a = 0.0

	# 1. Günü başlat ve sağ kapıdan görevli gazeteyi getirsin
	_masa_katmanlarini_duzenle()
	gunu_baslat(1)


func _masa_katmanlarini_duzenle() -> void:
	# Godot Control düğümlerinde fare tıklama önceliği sahne ağacı (child index) sırasına göredir.
	# Görsel z_index sırası ile sahne ağacı sırasını birebir eşleştiriyoruz:
	var sira: Array[Node] = []
	for ad in ["GardiyanEmri", "CezaeviPostasi", "KuralKitabi", "TalepFisi"]:
		var n = find_child(ad, false, false)
		if n: sira.append(n)
	if is_instance_valid(mahkum_notu_dugumu): sira.append(mahkum_notu_dugumu)
	for esya in dolap_esya_dugumleri:
		if is_instance_valid(esya):
			sira.append(esya)
	if is_instance_valid(rusvet_dugumu): sira.append(rusvet_dugumu)
	if is_instance_valid(pusula_dugumu): sira.append(pusula_dugumu)
	for ad in ["DamgaCekmecesi", "GazeteOkumaPaneli", "KuralKitabiPaneli"]:
		var n = find_child(ad, false, false)
		if n: sira.append(n)
	if is_instance_valid(ihtar_dugumu): sira.append(ihtar_dugumu)
	var balon = find_child("KonusmaBalonu", false, false)
	if balon: sira.append(balon)
	if is_instance_valid(g_balon_panel): sira.append(g_balon_panel)
	if is_instance_valid(p_balon_panel): sira.append(p_balon_panel)
	if is_instance_valid(inceleme_cizgisi): sira.append(inceleme_cizgisi)
	if is_instance_valid(hedef_isaretleyici_1): sira.append(hedef_isaretleyici_1)
	if is_instance_valid(hedef_isaretleyici_2): sira.append(hedef_isaretleyici_2)
	var bildirim = find_child("BildirimKutusu", false, false)
	if bildirim: sira.append(bildirim)

	for n in sira:
		if n and n.get_parent() == self:
			move_child(n, get_child_count() - 1)


func _process(_delta: float) -> void:
	_atmosfer_guncelle(_delta)
	# Eşleştirme modunda seçili kutular kağıt/kitap sürüklendikçe hedefi canlı takip etsin
	if inceleme_modu_aktif:
		if not secilen_inceleme_1.is_empty() and is_instance_valid(secilen_inceleme_1.get("node")):
			_hedef_yerlestir(hedef_isaretleyici_1, secilen_inceleme_1["node"])
		if not secilen_inceleme_2.is_empty() and is_instance_valid(secilen_inceleme_2.get("node")):
			_hedef_yerlestir(hedef_isaretleyici_2, secilen_inceleme_2["node"])
			if inceleme_cizgisi and hedef_isaretleyici_1 and hedef_isaretleyici_2:
				var c1 = hedef_isaretleyici_1.global_position + hedef_isaretleyici_1.size * 0.5
				var c2 = hedef_isaretleyici_2.global_position + hedef_isaretleyici_2.size * 0.5
				inceleme_cizgisi.clear_points()
				inceleme_cizgisi.add_point(c1)
				inceleme_cizgisi.add_point(c2)
	# Kuyruktaki mahkumların canlı nefes alıp verme ve hafif salınım animasyonu (yan yana sıra)
	if not kuyruk_yuruyor:
		var ticks = Time.get_ticks_msec() * 0.001
		for i in range(siluet_dugumleri.size()):
			var s = siluet_dugumleri[i]
			if not s or not s.visible: continue
			var nefes = sin(ticks * 2.3 + i * 1.15) * 0.016
			s.scale.y = 1.0 + nefes
			var sway = sin(ticks * 0.85 + i * 1.6) * 0.012
			s.rotation = sway


var kasa_yazisi: Label = null

func hud_kasa_metni() -> String:
	var top_m: int = maxi(1, mahkum_listesi.size())
	var cur_m: int = clampi(aktif_mahkum_indeksi + 1, 0, top_m)
	return "KASA: %d$ • VARDİYA: %d/%d" % [oyuncu_parasi, cur_m, top_m]


func hud_hikaye_metni() -> String:
	return "KANIT: %d/3 • DİRENİŞ: %d | SADAKAT: %d" % [kanit_sayisi, direnis_puani, sadakat_puani]


func siradaki_etiket_guncelle() -> void:
	if not siradaki_etiket_lbl: return
	var top_m: int = maxi(1, mahkum_listesi.size())
	var kalan: int = maxi(0, top_m - (aktif_mahkum_indeksi + 1))
	if aktif_mahkum_indeksi + 1 >= top_m and not gisede_mahkum_var:
		siradaki_etiket_lbl.text = "GÜNÜ BİTİR ►"
		siradaki_etiket_lbl.add_theme_color_override("font_color", Color(0.45, 0.96, 0.55, 1.0))
	else:
		siradaki_etiket_lbl.text = "SIRADAKİ (%d)" % kalan
		siradaki_etiket_lbl.add_theme_color_override("font_color", Color(0.92, 0.82, 0.62, 0.95))


func hud_tam_guncelle() -> void:
	if kasa_yazisi:
		kasa_yazisi.text = hud_kasa_metni()
	if hikaye_durum_yazisi:
		hikaye_durum_yazisi.text = hud_hikaye_metni()
	if atla_butonu:
		atla_butonu.visible = gorevli_teslimatta
	if sorgu_butonu:
		sorgu_butonu.visible = gisede_mahkum_var
	siradaki_etiket_guncelle()


func olustur_kasa_hud() -> void:
	if get_node_or_null("KasaPaneli"): return
	var panel = ColorRect.new()
	panel.name = "KasaPaneli"
	panel.color = Color(0.08, 0.09, 0.11, 0.95)
	panel.position = Vector2(794.0, 10.0)
	panel.size = Vector2(220.0, 68.0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.gui_input.connect(func(event: InputEvent):
		if not inceleme_modu_aktif: return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			inceleme_ogesi_secildi("hud_tarih", "Takvim / Bugünün Tarihi (" + bugun_tarih + ")", panel)
			panel.accept_event()
	)
	add_child(panel)

	var cerceve = ReferenceRect.new()
	cerceve.editor_only = false
	cerceve.border_color = Color(0.48, 0.42, 0.32, 1.0)
	cerceve.border_width = 2.0
	cerceve.position = Vector2.ZERO
	cerceve.size = panel.size
	cerceve.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(cerceve)

	var font = preload("res://assets/retro_font.ttf")

	var lbl_tarih = Label.new()
	lbl_tarih.text = "18 NİSAN 1984 • 1. GÜN"
	lbl_tarih.position = Vector2(6.0, 4.0)
	lbl_tarih.size = Vector2(208.0, 18.0)
	lbl_tarih.add_theme_font_override("font", font)
	lbl_tarih.add_theme_font_size_override("font_size", 11)
	lbl_tarih.add_theme_color_override("font_color", Color(0.86, 0.78, 0.62, 1.0))
	lbl_tarih.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_tarih.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(lbl_tarih)

	var lbl_kasa = Label.new()
	lbl_kasa.name = "KasaYazisi"
	lbl_kasa.text = hud_kasa_metni()
	lbl_kasa.position = Vector2(6.0, 23.0)
	lbl_kasa.size = Vector2(208.0, 20.0)
	lbl_kasa.add_theme_font_override("font", font)
	lbl_kasa.add_theme_font_size_override("font_size", 12)
	lbl_kasa.add_theme_color_override("font_color", Color(0.96, 0.88, 0.45, 1.0))
	lbl_kasa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_kasa.pivot_offset = Vector2(104.0, 10.0)
	lbl_kasa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(lbl_kasa)
	kasa_yazisi = lbl_kasa

	var lbl_hikaye = Label.new()
	lbl_hikaye.name = "HikayeDurumYazisi"
	lbl_hikaye.text = hud_hikaye_metni()
	lbl_hikaye.position = Vector2(6.0, 45.0)
	lbl_hikaye.size = Vector2(208.0, 18.0)
	lbl_hikaye.add_theme_font_override("font", font)
	lbl_hikaye.add_theme_font_size_override("font_size", 9)
	lbl_hikaye.add_theme_color_override("font_color", Color(0.68, 0.84, 0.94, 0.95))
	lbl_hikaye.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hikaye.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(lbl_hikaye)
	hikaye_durum_yazisi = lbl_hikaye

	var btn_menu = Button.new()
	btn_menu.name = "MenuButonu"
	btn_menu.text = "≡ MENÜ / GÜN"
	btn_menu.position = Vector2(794.0, 82.0)
	btn_menu.size = Vector2(106.0, 22.0)
	btn_menu.tooltip_text = "Kontrol Menüsü, Gün Seçimi ve Kısayollar [ESC]"
	btn_menu.add_theme_font_override("font", font)
	btn_menu.add_theme_font_size_override("font_size", 9)
	btn_menu.add_theme_color_override("font_color", Color(0.94, 0.86, 0.68, 1.0))
	_sik_buton_stili(btn_menu, Color(0.75, 0.60, 0.36, 1.0))
	btn_menu.pressed.connect(func():
		if not ana_menu_acik and not olay_paneli_acik:
			ana_menu_goster()
	)
	add_child(btn_menu)
	menu_butonu = btn_menu

	var btn_atla = Button.new()
	btn_atla.name = "AtlaButonu"
	btn_atla.text = "KONUŞMAYI GEÇ ►"
	btn_atla.position = Vector2(904.0, 82.0)
	btn_atla.size = Vector2(110.0, 22.0)
	btn_atla.tooltip_text = "Sgt. Dobbs'un diyaloglarını hızlıca geç"
	btn_atla.add_theme_font_override("font", font)
	btn_atla.add_theme_font_size_override("font_size", 9)
	btn_atla.add_theme_color_override("font_color", Color(0.98, 0.82, 0.45, 1.0))
	_sik_buton_stili(btn_atla, Color(0.92, 0.56, 0.24, 1.0))
	btn_atla.visible = false
	btn_atla.pressed.connect(func():
		ses_oynat(ses_dugme)
		gorevli_tumunu_atla = true
		konusma_atla = true
	)
	add_child(btn_atla)
	atla_butonu = btn_atla


func para_guncelle(degisim: int) -> void:
	oyuncu_parasi = maxi(0, oyuncu_parasi + degisim)
	hud_tam_guncelle()
	if kasa_yazisi:
		kasa_yazisi.modulate = Color(0.2, 1.0, 0.4) if degisim > 0 else Color(1.0, 0.25, 0.2)
		var t = create_tween()
		t.tween_property(kasa_yazisi, "scale", Vector2(1.16, 1.16), 0.1)
		t.tween_property(kasa_yazisi, "scale", Vector2(1.0, 1.0), 0.15)
		t.tween_property(kasa_yazisi, "modulate", Color(0.96, 0.88, 0.45), 0.3)


func diyalog_balonlarini_goster(satir_1: String, satir_2: String) -> void:
	var balon = find_child("KonusmaBalonu") as Control
	var serit_1 = find_child("DiyalogSeridi1") as Control
	var serit_2 = find_child("DiyalogSeridi2") as Control
	var yazi_1 = find_child("DiyalogYazi1") as Label
	var yazi_2 = find_child("DiyalogYazi2") as Label
	if not balon or not serit_1 or not serit_2: return

	# Konuşan mahkumun isim rozeti (şerit 1'in sol üst köşesinde)
	var rozet = serit_1.get_node_or_null("KonusanRozet") as PanelContainer
	if not rozet:
		rozet = PanelContainer.new()
		rozet.name = "KonusanRozet"
		var rsb = StyleBoxFlat.new()
		rsb.bg_color = Color(0.12, 0.10, 0.10, 0.96)
		rsb.border_color = Color(0.76, 0.28, 0.24, 1.0)
		rsb.set_border_width_all(1)
		rsb.set_corner_radius_all(2)
		rsb.content_margin_left = 6
		rsb.content_margin_right = 6
		rsb.content_margin_top = 1
		rsb.content_margin_bottom = 1
		rozet.add_theme_stylebox_override("panel", rsb)
		var rlbl = Label.new()
		rlbl.name = "RozetYazi"
		rlbl.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
		rlbl.add_theme_font_size_override("font_size", 10)
		rlbl.add_theme_color_override("font_color", Color(0.96, 0.86, 0.68, 1.0))
		rlbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rozet.add_child(rlbl)
		rozet.position = Vector2(18.0, -11.0)
		rozet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		serit_1.add_child(rozet)
	var rlbl_node = rozet.get_node_or_null("RozetYazi") as Label
	if rlbl_node and aktif_mahkum_indeksi >= 0 and aktif_mahkum_indeksi < mahkum_listesi.size():
		var m_aktif = mahkum_listesi[aktif_mahkum_indeksi]
		rlbl_node.text = "▸ %s (%s)" % [str(m_aktif.get("ad", "INMATE")).to_upper(), str(m_aktif.get("blok", ""))]

	if yazi_1:
		yazi_1.position = Vector2(14.0, 4.0)
		yazi_1.size = Vector2(236.0, 48.0)
		yazi_1.add_theme_font_size_override("font_size", 12)
		yazi_1.text = satir_1
		yazi_1.visible_ratio = 0.0
	if yazi_2:
		yazi_2.position = Vector2(14.0, 4.0)
		yazi_2.size = Vector2(236.0, 48.0)
		yazi_2.add_theme_font_size_override("font_size", 12)
		yazi_2.text = satir_2
		yazi_2.visible_ratio = 0.0

	balon.visible = true
	balon.move_to_front()

	serit_1.visible = true
	serit_2.visible = false
	serit_1.pivot_offset = Vector2(24.0, 22.0)
	serit_1.scale = Vector2(0.78, 0.78)
	serit_1.modulate.a = 0.0
	ses_oynat(ses_konusma, -6.0)

	var t = create_tween()
	t.tween_property(serit_1, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(serit_1, "modulate:a", 1.0, 0.12)
	if yazi_1:
		t.parallel().tween_property(yazi_1, "visible_ratio", 1.0, 0.28)
	t.tween_interval(0.18)
	t.tween_callback(func():
		if not balon.visible: return
		serit_2.visible = true
		serit_2.pivot_offset = Vector2(30.0, 26.0)
		serit_2.scale = Vector2(0.78, 0.78)
		serit_2.modulate.a = 0.0
		ses_oynat(ses_konusma, -7.0)
		var t2 = create_tween()
		t2.tween_property(serit_2, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t2.parallel().tween_property(serit_2, "modulate:a", 1.0, 0.12)
		if yazi_2:
			t2.parallel().tween_property(yazi_2, "visible_ratio", 1.0, 0.30)
	)


func _panelleri_yan_yana_duzenle(aktif_panel: Control) -> void:
	if aktif_panel and aktif_panel.visible:
		aktif_panel.position = Vector2(226.0, 204.0)
	var fis = find_child("TalepFisi") as Control
	if fis and fis.visible and fis.get("masada_acik") == true:
		var kk = find_child("KuralKitabiPaneli") as Control
		var gz = find_child("GazeteOkumaPaneli") as Control
		if (kk and kk.visible) or (gz and gz.visible):
			var tf = create_tween()
			tf.tween_property(fis, "position", Vector2(692.0, 142.0), 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_masa_katmanlarini_duzenle()


func gazete_okuma_ac_kapat() -> void:
	var panel = find_child("GazeteOkumaPaneli") as Control
	if not panel: return
	ses_oynat(ses_kitap)
	panel.visible = not panel.visible
	if panel.visible:
		var kk = find_child("KuralKitabiPaneli") as Control
		if kk and kk.visible:
			kk.visible = false
		_panelleri_yan_yana_duzenle(panel)
		panel.scale = Vector2(0.88, 0.88)
		var t = create_tween()
		t.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func kural_kitabi_ac_kapat() -> void:
	var panel = find_child("KuralKitabiPaneli") as Control
	if not panel: return
	ses_oynat(ses_kitap)
	panel.visible = not panel.visible
	if panel.visible:
		var gz = find_child("GazeteOkumaPaneli") as Control
		if gz and gz.visible:
			gz.visible = false
		_panelleri_yan_yana_duzenle(panel)
		panel.scale = Vector2(0.88, 0.88)
		var t = create_tween()
		t.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_cekmece_kol_basildi() -> void:
	cekmece_acik = not cekmece_acik
	ses_oynat(ses_cekmece)
	var cekmece = find_child("DamgaCekmecesi")
	var ok_yazi = find_child("CekmeceOkYazisi")
	if not cekmece: return
	_masa_katmanlarini_duzenle()
	var hedef_x = 774.0 if cekmece_acik else 988.0
	if ok_yazi:
		ok_yazi.text = ">>" if cekmece_acik else "<<"
	var t = create_tween()
	t.tween_property(cekmece, "position:x", hedef_x, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_siradaki_basildi() -> void:
	if oyun_bitti or olay_paneli_acik or gun_sonu_basladi:
		return

	if gorevli_teslimatta:
		gorevli_tumunu_atla = true
		konusma_atla = true
		gorevli_teslimatta = false
		var gorevli_node = find_child("Gorevli") as Control
		if gorevli_node: gorevli_node.visible = false
		var gazete_node = find_child("CezaeviPostasi") as Control
		if gazete_node:
			gazete_node.visible = true
			gazete_node.position = Vector2(282.0, 408.0)
			gazete_node.modulate.a = 1.0
		if g_balon_panel: g_balon_panel.visible = false
		if p_balon_panel: p_balon_panel.visible = false
		hud_tam_guncelle()

	if yeni_mahkum_geliyor:
		return

	if gisede_mahkum_var:
		bildirim_goster("Gişede işlem devam ediyor! Önce mevcut mahkumun fişini mühürleyip teslim edin.", Color.YELLOW)
		return

	if aktif_mahkum_indeksi + 1 >= mahkum_listesi.size():
		if tween_kepenk and tween_kepenk.is_valid():
			tween_kepenk.kill()
		mahkum_ayriliyor = false
		gun_sonu_akisi()
		return

	if mahkum_ayriliyor:
		return

	var siradaki_m = mahkum_listesi[aktif_mahkum_indeksi + 1]
	var on_olay: String = str(siradaki_m.get("orta_olay_oncesi", ""))
	if on_olay != "" and not siradaki_m.get("orta_olay_oncesi_yapildi", false):
		siradaki_m["orta_olay_oncesi_yapildi"] = true
		await orta_olay_goster(on_olay)
		if oyun_bitti:
			return

	# Eğer önceki mahkumun ayrılış / kepenk animasyonu sürüyorsa hemen sonlandır
	if tween_kepenk and tween_kepenk.is_valid():
		tween_kepenk.kill()

	yeni_mahkum_geliyor = true
	ses_oynat(ses_dugme)

	# Masadaki kırmızı düğmenin basılma hissi
	var btn = find_child("SiradakiButonu")
	if btn:
		var tb = create_tween()
		tb.tween_property(btn, "scale", Vector2(0.92, 0.92), 0.08)
		tb.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08)

	var bildirim = find_child("BildirimKutusu")
	if bildirim: bildirim.visible = false

	# 1. Sıradaki mahkum seçilir ve koridordaki kuyruk ilerler
	aktif_mahkum_indeksi += 1
	var m = mahkum_listesi[aktif_mahkum_indeksi]
	kuyrugu_ilerlet_animasyonu()
	mahkum_bilgilerini_yukle(m)
	hud_tam_guncelle()

	secilen_damga = ""
	ilac_secildi = false
	yemek_secildi = false
	icecek_secildi = false
	tum_esyalari_rafa_dondur()

	# 2. Kepenk açılır, mahkum koridordan yürüyerek pencerenin önüne gelir
	var kepenk = find_child("Kepenk")
	var gorsel = find_child("MahkumGorsel")
	if gorsel:
		gorsel.texture = m["gorsel"]
		mahkum_yuru_giris(gorsel)

	if kepenk:
		var t_kepenk = create_tween()
		t_kepenk.tween_property(kepenk, "position:y", -155.0, 0.38).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# 3. Mahkum yerine ulaşınca konuşma balonları açılır
	var t_konusma = get_tree().create_timer(0.92)
	t_konusma.timeout.connect(func():
		ses_oynat(ses_konusma)
		diyalog_balonlarini_goster(m["replik_1"], m["replik_2"])
		if m.get("id", "") == "elias" or m.get("id", "") == "ghost":
			isik_titret(0.55)
	)

	# 4. Mahkum konuştuktan hemen sonra talep fişini delikten masaya doğru uzatır
	var t_fis = get_tree().create_timer(1.15)
	t_fis.timeout.connect(func():
		var fis = find_child("TalepFisi")
		if fis:
			if fis.has_method("rastgele_burusukluk_sec"):
				fis.rastgele_burusukluk_sec()
			if fis.has_method("delikten_uzat"):
				fis.delikten_uzat()
			ses_oynat(ses_yazici)

		gisede_mahkum_var = true
		yeni_mahkum_geliyor = false
		hud_tam_guncelle()
		_kontrol_mahkum_notu(m)
		_masa_katmanlarini_duzenle()
	)


func mahkum_yuru_giris(gorsel: Control) -> void:
	if gorsel is TextureRect:
		gorsel.flip_h = false
	gorsel.pivot_offset = Vector2(75.0, 140.0)
	gorsel.position = Vector2(-165.0, 14.0)
	gorsel.rotation = -0.04
	gorsel.modulate.a = 1.0
	var plaka = mahkum_isim_plakasi
	if plaka: plaka.visible = false
	var t = create_tween()
	t.tween_interval(0.18)
	t.tween_callback(func(): ses_oynat(ses_ayak, -3.0))
	t.tween_property(gorsel, "position:x", 58.0, 0.88).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_callback(func():
		gorsel.rotation = 0.0
		if plaka: plaka.visible = true
	)
	var b = create_tween()
	b.tween_interval(0.18)
	for i in range(5):
		b.tween_property(gorsel, "position:y", 6.0, 0.088)
		b.parallel().tween_property(gorsel, "rotation", 0.035 if (i % 2 == 0) else -0.035, 0.088)
		b.tween_property(gorsel, "position:y", 14.0, 0.088)
	b.tween_property(gorsel, "rotation", 0.0, 0.06)


func mahkum_yuru_cikis(gorsel: Control) -> void:
	gorsel.pivot_offset = Vector2(75.0, 140.0)
	var plaka = mahkum_isim_plakasi
	var t = create_tween()
	t.tween_interval(0.95)
	t.tween_callback(func():
		if plaka: plaka.visible = false
		if gorsel is TextureRect:
			gorsel.flip_h = true
		ses_oynat(ses_ayak, -3.0)
		koridor_cikis_animasyonu()
	)
	t.tween_property(gorsel, "position:x", -165.0, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_callback(func():
		gorsel.rotation = 0.0
		if gorsel is TextureRect:
			gorsel.flip_h = false
		if not gisede_mahkum_var:
			gorsel.position = Vector2(58.0, 14.0)
	)
	var b = create_tween()
	b.tween_interval(0.95)
	for i in range(5):
		b.tween_property(gorsel, "position:y", 6.0, 0.085)
		b.parallel().tween_property(gorsel, "rotation", 0.04 if (i % 2 == 0) else -0.04, 0.085)
		b.tween_property(gorsel, "position:y", 14.0, 0.085)


func koridor_cikis_animasyonu() -> void:
	var kb = find_child("KuyrukBolumu")
	if not kb: return
	var cikis_s = kb.get_node_or_null("CikisSilueti") as TextureRect
	if not cikis_s:
		cikis_s = TextureRect.new()
		cikis_s.name = "CikisSilueti"
		cikis_s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cikis_s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cikis_s.size = Vector2(36.0, 88.0)
		cikis_s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		kb.add_child(cikis_s)
	cikis_s.texture = kuyruk_dokulari[aktif_mahkum_indeksi % kuyruk_dokulari.size()]
	cikis_s.flip_h = true
	cikis_s.position = Vector2(316.0, 110.0)
	cikis_s.modulate = Color(0.75, 0.78, 0.85, 0.92)
	cikis_s.visible = true
	var t = create_tween()
	t.tween_property(cikis_s, "position:x", -38.0, 1.35).set_trans(Tween.TRANS_LINEAR)
	t.parallel().tween_property(cikis_s, "modulate:a", 0.0, 1.35)
	var b = create_tween()
	for i in range(7):
		b.tween_property(cikis_s, "position:y", 105.0, 0.095)
		b.tween_property(cikis_s, "position:y", 110.0, 0.095)


func kuyruk_gorunurlugu_guncelle() -> void:
	# Koridordaki kalabalık sıra her zaman dolu başlar, vardiyada mahkum çağrıldıkça arkadan azalır
	var azalan: int = maxi(0, aktif_mahkum_indeksi + 1)
	var gorunen: int = clampi(10 - azalan, 4, 10)
	for i in range(siluet_dugumleri.size()):
		var s = siluet_dugumleri[i]
		if s:
			s.visible = (i >= siluet_dugumleri.size() - gorunen)
	if kasa_yazisi:
		kasa_yazisi.text = hud_kasa_metni()


func _ad_etiketi_olustur() -> void:
	var fis = find_child("TalepFisi")
	if fis and not fis.get_node_or_null("AdDeger"):
		var bg = ColorRect.new()
		bg.name = "AdEtiketArka"
		bg.color = Color(0.16, 0.14, 0.12, 0.92)
		bg.position = Vector2(16.0, 141.0)
		bg.size = Vector2(78.0, 14.0)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.visible = false
		fis.add_child(bg)

		var l = Label.new()
		l.name = "AdDeger"
		l.position = Vector2(14.0, 141.0)
		l.size = Vector2(82.0, 14.0)
		l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
		l.add_theme_font_size_override("font_size", 9)
		l.add_theme_color_override("font_color", Color(0.95, 0.88, 0.72, 1.0))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.visible = false
		fis.add_child(l)
		ad_deger_lbl = l

	var pencere = find_child("MahkumPenceresi")
	if pencere and not pencere.get_node_or_null("MahkumIsimPlakasi"):
		var plaka = ColorRect.new()
		plaka.name = "MahkumIsimPlakasi"
		plaka.color = Color(0.08, 0.09, 0.11, 0.96)
		plaka.position = Vector2(38.0, 146.0)
		plaka.size = Vector2(190.0, 22.0)
		plaka.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plaka.visible = false
		pencere.add_child(plaka)
		mahkum_isim_plakasi = plaka

		var plaka_cerceve = ReferenceRect.new()
		plaka_cerceve.editor_only = false
		plaka_cerceve.border_color = Color(0.68, 0.56, 0.36, 0.95)
		plaka_cerceve.border_width = 1.5
		plaka_cerceve.size = plaka.size
		plaka_cerceve.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plaka.add_child(plaka_cerceve)

		var sol_serit = ColorRect.new()
		sol_serit.color = Color(0.82, 0.32, 0.24, 1.0)
		sol_serit.position = Vector2(0.0, 0.0)
		sol_serit.size = Vector2(4.0, 22.0)
		sol_serit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plaka.add_child(sol_serit)

		var kepenk = pencere.get_node_or_null("Kepenk")
		if kepenk:
			kepenk.move_to_front()

		var pl_lbl = Label.new()
		pl_lbl.name = "PlakaYazi"
		pl_lbl.position = Vector2(6.0, 3.0)
		pl_lbl.size = Vector2(180.0, 16.0)
		pl_lbl.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
		pl_lbl.add_theme_font_size_override("font_size", 11)
		pl_lbl.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68, 1.0))
		pl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pl_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pl_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plaka.add_child(pl_lbl)
		plaka_yazi_lbl = pl_lbl

		var btn_sorgu = Button.new()
		btn_sorgu.name = "SorguButonu"
		btn_sorgu.text = "? SORGULA"
		btn_sorgu.position = Vector2(182.0, 6.0)
		btn_sorgu.size = Vector2(78.0, 20.0)
		btn_sorgu.tooltip_text = "Mahkuma evrakı ve talebi hakkında soru sor [Q]"
		btn_sorgu.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
		btn_sorgu.add_theme_font_size_override("font_size", 8)
		btn_sorgu.add_theme_color_override("font_color", Color(0.98, 0.86, 0.56, 1.0))
		_sik_buton_stili(btn_sorgu, Color(0.88, 0.42, 0.26, 1.0))
		btn_sorgu.visible = false
		btn_sorgu.pressed.connect(mahkum_sorgula)
		pencere.add_child(btn_sorgu)
		sorgu_butonu = btn_sorgu
		if kepenk:
			kepenk.move_to_front()


func mahkum_sorgula() -> void:
	if not gisede_mahkum_var or aktif_mahkum_indeksi < 0 or aktif_mahkum_indeksi >= mahkum_listesi.size():
		return
	var fis = find_child("TalepFisi")
	if fis and not fis.get("masada_acik") and fis.has_method("masaya_ac"):
		fis.masaya_ac(false)
	var m = mahkum_listesi[aktif_mahkum_indeksi]
	ses_oynat(ses_dugme)
	if mahkum_notu_dugumu and mahkum_notu_dugumu.visible:
		_mahkum_notu_vurgula()
		diyalog_balonlarini_goster("Gardiyanlar duyacak memur bey, burada sesli söyleyemem...", "Mazgaldan masaya uzattığım küçük kağıda yazdım, lütfen onu oku.")
	else:
		var cevap: String = str(m.get("sorgu", "Evrakımda bir sorun yok memur, kurallara göre istihkakımı bekliyorum."))
		diyalog_balonlarini_goster("Evrakım tezgahın üstünde memur bey.", cevap)
	var balon = find_child("KonusmaBalonu")
	if balon:
		var tb = create_tween()
		tb.tween_property(balon, "position:x", 522.0, 0.05)
		tb.tween_property(balon, "position:x", 534.0, 0.05)
		tb.tween_property(balon, "position:x", 528.0, 0.05)


func mahkum_bilgilerini_yukle(m: Dictionary) -> void:
	var gorsel = find_child("MahkumGorsel")
	var vesikalik = find_child("VesikalikGorsel")
	if gorsel: gorsel.texture = m["gorsel"]
	if vesikalik: vesikalik.texture = m["gorsel"]
	if ad_deger_lbl: ad_deger_lbl.text = str(m["ad"]).to_upper()
	if plaka_yazi_lbl: plaka_yazi_lbl.text = "%s  •  #%s" % [str(m["ad"]).to_upper(), str(m["no"])]
	if kasa_yazisi: kasa_yazisi.text = hud_kasa_metni()

	var sicil_lbl = find_child("SicilDeger")
	if sicil_lbl: sicil_lbl.text = "# " + str(m["no"])

	var blok_lbl = find_child("BlokDeger")
	if blok_lbl: blok_lbl.text = str(m["blok"]).to_upper()

	var izin_lbl = find_child("IzinDeger")
	if izin_lbl:
		izin_lbl.text = str(m["izin"]).to_upper()
		if m["izin"] == "Kısıtlı":
			izin_lbl.add_theme_color_override("font_color", Color(0.62, 0.12, 0.1, 1))
		else:
			izin_lbl.add_theme_color_override("font_color", Color(0.14, 0.36, 0.18, 1))

	var kutu_ilac = find_child("KutuIlac")
	var durum_ilac = find_child("SatirIlacDurum")
	if kutu_ilac: kutu_ilac.text = "X" if m["ilac"] else ""
	if durum_ilac:
		durum_ilac.text = "TALEP VAR" if m["ilac"] else "YOK"
		durum_ilac.add_theme_color_override("font_color", Color(0.58, 0.12, 0.1, 1) if m["ilac"] else Color(0.45, 0.4, 0.34, 1))

	var kutu_yemek = find_child("KutuYemek")
	var durum_yemek = find_child("SatirYemekDurum")
	if kutu_yemek: kutu_yemek.text = "X" if m["yiyecek"] else ""
	if durum_yemek:
		durum_yemek.text = "TALEP VAR" if m["yiyecek"] else "YOK"
		durum_yemek.add_theme_color_override("font_color", Color(0.58, 0.12, 0.1, 1) if m["yiyecek"] else Color(0.45, 0.4, 0.34, 1))

	var kutu_icecek = find_child("KutuIcecek")
	var durum_icecek = find_child("SatirIcecekDurum")
	if kutu_icecek: kutu_icecek.text = "X" if m["icecek"] else ""
	if durum_icecek:
		durum_icecek.text = "TALEP VAR" if m["icecek"] else "YOK"
		durum_icecek.add_theme_color_override("font_color", Color(0.58, 0.12, 0.1, 1) if m["icecek"] else Color(0.45, 0.4, 0.34, 1))

	var tarih_lbl = find_child("TarihDeger")
	if tarih_lbl: tarih_lbl.text = str(m["tarih"])

	var onay_lbl = find_child("OnayDeger")
	if onay_lbl: onay_lbl.text = str(m["gardiyan"])

	var damga_gorsel = find_child("DamgaGorsel")
	if damga_gorsel: damga_gorsel.visible = false


func kuyrugu_ilerlet_animasyonu() -> void:
	if siluet_dugumleri.size() < 10: return
	kuyruk_yuruyor = true
	ses_oynat(ses_ayak, -2.0)
	var hedef_x = [6.0, 36.0, 66.0, 96.0, 126.0, 156.0, 186.0, 216.0, 246.0, 276.0]

	var tween = create_tween()
	var on_mahkum = siluet_dugumleri[9]
	# En öndeki mahkum kapıdan gişeye doğru adımlayarak çıkar
	tween.parallel().tween_property(on_mahkum, "position:x", 325.0, 0.44)
	tween.parallel().tween_property(on_mahkum, "modulate:a", 0.0, 0.44)
	var t_on_rot = create_tween()
	t_on_rot.tween_property(on_mahkum, "rotation", 0.04, 0.22)
	var t_on_bob = create_tween()
	t_on_bob.tween_property(on_mahkum, "position:y", siluet_baslangic_y[9] - 5.0, 0.11)
	t_on_bob.tween_property(on_mahkum, "position:y", siluet_baslangic_y[9], 0.11)
	t_on_bob.tween_property(on_mahkum, "position:y", siluet_baslangic_y[9] - 5.0, 0.11)
	t_on_bob.tween_property(on_mahkum, "position:y", siluet_baslangic_y[9], 0.11)

	for i in range(9):
		var s = siluet_dugumleri[i]
		var yeni_x = hedef_x[i + 1]
		tween.parallel().tween_property(s, "position:x", yeni_x, 0.42).set_trans(Tween.TRANS_SINE)
		# Yürürken öne hafif eğilme (adımlama hissi)
		var t_rot = create_tween()
		t_rot.tween_property(s, "rotation", 0.035, 0.2)
		t_rot.tween_property(s, "rotation", 0.0, 0.22)
		# Adım atarken sekme (bobbing)
		var t_bob = create_tween()
		t_bob.tween_property(s, "position:y", siluet_baslangic_y[i] - 5.0, 0.1)
		t_bob.tween_property(s, "position:y", siluet_baslangic_y[i], 0.1)
		t_bob.tween_property(s, "position:y", siluet_baslangic_y[i] - 5.0, 0.1)
		t_bob.tween_property(s, "position:y", siluet_baslangic_y[i], 0.12)

	tween.tween_callback(func():
		var son_doku = siluet_dugumleri[9].texture
		for i in range(9, 0, -1):
			siluet_dugumleri[i].texture = siluet_dugumleri[i - 1].texture
			siluet_dugumleri[i].position.x = hedef_x[i]
			siluet_dugumleri[i].position.y = siluet_baslangic_y[i]
			siluet_dugumleri[i].rotation = 0.0
			siluet_dugumleri[i].scale.y = 1.0
			siluet_dugumleri[i].modulate.a = 1.0
		siluet_dugumleri[0].texture = kuyruk_dokulari[randi() % kuyruk_dokulari.size()]
		siluet_dugumleri[0].position.x = hedef_x[0]
		siluet_dugumleri[0].position.y = siluet_baslangic_y[0]
		siluet_dugumleri[0].rotation = 0.0
		siluet_dugumleri[0].scale.y = 1.0
		siluet_dugumleri[0].modulate.a = 1.0
		kuyruk_yuruyor = false
		kuyruk_gorunurlugu_guncelle()
	)


func tum_esyalari_rafa_dondur() -> void:
	for esya in dolap_esya_dugumleri:
		if esya and esya.has_method("rafina_don"):
			esya.rafina_don()
	dolap_esyalarini_kontrol_et()

func teslim_yuvasi_bul(hedef_esya: Control) -> Vector2:
	var yuvalar = [
		Vector2(394.0, 217.0),
		Vector2(452.0, 217.0),
		Vector2(510.0, 217.0),
		Vector2(568.0, 217.0),
	]
	var dolu: Array[int] = []
	for esya in dolap_esya_dugumleri:
		if esya and esya != hedef_esya and esya.get("masada_secili"):
			var yi = int(esya.get("yuva_indeksi"))
			if yi >= 0 and yi < 4:
				dolu.append(yi)
	for i in range(4):
		if not (i in dolu):
			hedef_esya.set("yuva_indeksi", i)
			return yuvalar[i]
	hedef_esya.set("yuva_indeksi", 0)
	return yuvalar[0]


func dolap_esyalarini_kontrol_et() -> void:
	ilac_secildi = false
	yemek_secildi = false
	icecek_secildi = false
	var secilen_kategoriler: Array[String] = []
	for esya in dolap_esya_dugumleri:
		if esya and esya.get("masada_secili"):
			var kod = esya.get("esya_kodu")
			if kod in ["ilac", "sargi", "ilac_yesil", "ilac_mavi", "ilac_kehribar"]:
				ilac_secildi = true
				if not ("İLAÇ" in secilen_kategoriler): secilen_kategoriler.append("İLAÇ")
			elif kod in ["konserve", "cips"]:
				yemek_secildi = true
				if not ("YİYECEK" in secilen_kategoriler): secilen_kategoriler.append("YİYECEK")
			elif kod in ["kola", "meyvesuyu"]:
				icecek_secildi = true
				if not ("İÇECEK" in secilen_kategoriler): secilen_kategoriler.append("İÇECEK")
	if teslim_durum_etiketi:
		if secilen_kategoriler.is_empty():
			teslim_durum_etiketi.text = "TESLİM BÖLMESİ: BOŞ  •  [MÜHÜRLÜ FİŞİ BIRAK / TIKLA]"
			teslim_durum_etiketi.add_theme_color_override("font_color", Color(0.68, 0.66, 0.6, 0.88))
		else:
			teslim_durum_etiketi.text = "BÖLMEDE: " + " + ".join(secilen_kategoriler) + "  •  [TESLİM ET ►]"
			teslim_durum_etiketi.add_theme_color_override("font_color", Color(0.96, 0.86, 0.45, 1.0))



func _damga_vurus_animasyonu(buton: Control, tip: String) -> void:
	if not gisede_mahkum_var: return
	var cekmece = find_child("DamgaCekmecesi")
	if cekmece: cekmece.move_to_front()
	if not cekmece_acik:
		_on_cekmece_kol_basildi()
	secilen_damga = tip
	ses_oynat(ses_damga)
	if buton:
		var t = create_tween()
		t.tween_property(buton, "position:y", 44.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.tween_property(buton, "position:y", 26.0, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var fis = find_child("TalepFisi")
	if fis:
		fis.damga_bas(tip)

func _on_onay_basildi() -> void:
	_damga_vurus_animasyonu(find_child("OnayButonu"), "ONAYLANDI")

func _on_red_basildi() -> void:
	_damga_vurus_animasyonu(find_child("RedButonu"), "REDDEDİLDİ")


func _on_teslim_et_basildi() -> void:
	if not gisede_mahkum_var:
		bildirim_goster("Gişede mahkum yok! Masadaki KIRMIZI DÜĞMEYE (SIRADAKİ) basın.", Color.YELLOW)
		return

	if yeni_mahkum_geliyor:
		return

	if secilen_damga == "":
		bildirim_goster("UYARI: Önce sağdaki çekmeceden fişe mühür basmalısınız!", Color.YELLOW)
		return

	if inceleme_modu_aktif:
		_on_inceleme_butonu_basildi()

	gisede_mahkum_var = false
	var m = mahkum_listesi[aktif_mahkum_indeksi]
	var blok = m["blok"]
	var kural = blok_kurallari.get(blok, {"ilac": false, "icecek": false, "yiyecek": false})

	var evrak_gecerli = (m["tarih"] == bugun_tarih) and (m["gardiyan"] in gecerli_gardiyanlar) and (m["izin"] != "Kısıtlı")
	var yasakli_esya_verildi = (ilac_secildi and not kural["ilac"]) or (yemek_secildi and not kural["yiyecek"]) or (icecek_secildi and not kural["icecek"])
	var yasakli_talep_var = (m["ilac"] and not kural["ilac"]) or (m["yiyecek"] and not kural["yiyecek"]) or (m["icecek"] and not kural["icecek"])

	var beklenen_ilac = m["ilac"] and kural["ilac"]
	var beklenen_yemek = m["yiyecek"] and kural["yiyecek"]
	var beklenen_icecek = m["icecek"] and kural["icecek"]
	var hic_esya_verilmedi = (not ilac_secildi) and (not yemek_secildi) and (not icecek_secildi)
	var izinli_esyalar_tam = (ilac_secildi == beklenen_ilac) and (yemek_secildi == beklenen_yemek) and (icecek_secildi == beklenen_icecek)

	var basarili: bool = false
	var ozel_odul: int = 15
	var ihlal_metni: String = ""

	var verilen_adlar: Array[String] = []
	if ilac_secildi: verilen_adlar.append("İLAÇ/SARGI")
	if yemek_secildi: verilen_adlar.append("YİYECEK")
	if icecek_secildi: verilen_adlar.append("İÇECEK")
	var verilen_ozet: String = "HİÇBİR ŞEY" if verilen_adlar.is_empty() else " + ".join(verilen_adlar)

	var beklenen_adlar: Array[String] = []
	if beklenen_ilac: beklenen_adlar.append("İLAÇ/SARGI")
	if beklenen_yemek: beklenen_adlar.append("YİYECEK")
	if beklenen_icecek: beklenen_adlar.append("İÇECEK")
	var beklenen_ozet: String = "YOK" if beklenen_adlar.is_empty() else " + ".join(beklenen_adlar)

	# 5. Gün Özel Durum: #00713 Elias Crane (Vicdan vs İtaat seçimi)
	if m.get("id", "") == "elias":
		if secilen_damga == "ONAYLANDI" and ilac_secildi and not yemek_secildi and not icecek_secildi:
			basarili = true
			ozel_odul = 15
			bildirim_goster("GİZLİ DİRENİŞ! Warden Graves'in emrine rağmen Elias Crane'in ilacını onayladınız! (+15$)", Color(0.3, 0.95, 0.55))
		elif secilen_damga == "REDDEDİLDİ" and hic_esya_verilmedi:
			basarili = true
			ozel_odul = 25
			bildirim_goster("ÖZEL EMİR UYGULANDI! Warden Graves'in emriyle #00713 Elias Crane reddedildi! (+25$)", Color(0.95, 0.82, 0.35))
		else:
			ihlal_metni = "Elias Crane (#00713) işleminde hatalı eşya teslimatı (%s) yapıldı." % verilen_ozet
			bildirim_goster("HATA! Elias Crane'e yanlış eşya teslim ettiniz! (-10$)", Color.RED)
	elif not evrak_gecerli:
		if secilen_damga == "REDDEDİLDİ" and hic_esya_verilmedi:
			basarili = true
			bildirim_goster("DOĞRU KARAR! Kural Kitabına göre geçersiz evrakı (Tarih/İmza/Kısıtlı) reddettiniz! (+15$)", Color.GREEN)
		else:
			if m["tarih"] != bugun_tarih:
				ihlal_metni = "GEÇERSİZ TARİH: Fiş tarihi (%s) bugünün tarihiyle (%s) uyuşmuyor!" % [str(m["tarih"]), bugun_tarih]
			elif not (m["gardiyan"] in gecerli_gardiyanlar):
				ihlal_metni = "SAHTE İMZA: Yetkisiz gardiyan imzası (%s) onaylandı!" % str(m["gardiyan"])
			else:
				ihlal_metni = "KISITLI STATÜ: 'Kısıtlı' izinli mahkuma onay/eşya (%s) verildi!" % verilen_ozet
			bildirim_goster("AĞIR CEZA! Kural Kitabına aykırı evrakı onayladınız veya eşya verdiniz! (-20$)", Color.RED)
	elif yasakli_esya_verildi:
		var yasakli_verilenler: Array[String] = []
		if ilac_secildi and not kural["ilac"]: yasakli_verilenler.append("İLAÇ/SARGI")
		if yemek_secildi and not kural["yiyecek"]: yasakli_verilenler.append("YİYECEK")
		if icecek_secildi and not kural["icecek"]: yasakli_verilenler.append("İÇECEK")
		ihlal_metni = "YASAKLI EŞYA TESLİMİ: %s mahkumuna yasak olan [%s] verildi!" % [blok, ", ".join(yasakli_verilenler)]
		bildirim_goster("AĞIR CEZA! Kural Kitabına göre " + blok + " mahkumuna YASAKLI eşya verdiniz! (-20$)", Color.RED)
	elif yasakli_talep_var:
		if (secilen_damga == "REDDEDİLDİ" and hic_esya_verilmedi) or (secilen_damga == "ONAYLANDI" and izinli_esyalar_tam):
			basarili = true
			bildirim_goster("DOĞRU KARAR! Kural Kitabına göre " + blok + " yasağını doğru uyguladınız! (+15$)", Color.GREEN)
		else:
			ihlal_metni = "YANLIŞ EŞYA TESLİMİ: %s için beklenen [%s] iken [%s] verildi!" % [blok, beklenen_ozet, verilen_ozet]
			bildirim_goster("CEZA! Kural Kitabına göre " + blok + " izinlerini yanlış uyguladınız! (-10$)", Color.RED)
	else:
		if secilen_damga == "ONAYLANDI" and izinli_esyalar_tam:
			basarili = true
			bildirim_goster("DOĞRU KARAR! Kural Kitabına göre " + blok + " istihkakını eksiksiz verdiniz! (+15$)", Color.GREEN)
		elif secilen_damga == "REDDEDİLDİ":
			ihlal_metni = "HAKSIZ RET: Evrakı ve talebi [%s] kurallara tam uygun olan %s mahkumu reddedildi!" % [beklenen_ozet, blok]
			bildirim_goster("HATA! " + blok + " mahkumunun fişi ve talebi Kural Kitabına uygundu! (-10$)", Color.RED)
		else:
			ihlal_metni = "YANLIŞ / EKSİK EŞYA: İstenen [%s] yerine [%s] teslim edildi!" % [beklenen_ozet, verilen_ozet]
			bildirim_goster("CEZA! Teslim Bölmesine " + blok + " mahkumunun istediği eşyaları eksik/yanlış koydunuz! (-10$)", Color.RED)

	# Rüşvet kontrolü: eğer mahkum rüşvet teklif ettiyse ve oyuncu ONAYLADIYSA +20$ rüşvet kasaya girer!
	if rusvet_teklif_var and secilen_damga == "ONAYLANDI":
		para_guncelle(20)
		gun_rusvet += 20
		toplam_rusvet += 20
		gun_kazanc += 20
		ses_oynat(ses_para)
	_rusvet_gizle()
	_pusula_gizle()
	_mahkum_notu_kapat_animasyonu()

	if basarili:
		ses_oynat(ses_para)
		para_guncelle(ozel_odul)
		gun_dogru += 1
		gun_kazanc += ozel_odul
	else:
		ses_oynat(ses_damga)
		var yazi_node = find_child("BildirimYazisi") as Label
		var ceza_miktar = -20 if (yazi_node and "AĞIR CEZA" in yazi_node.text) else -10
		para_guncelle(ceza_miktar)
		gun_hata += 1
		uyari_sayisi += 1
		gun_kazanc += ceza_miktar
		ihtar_fisi_bas(ihlal_metni if ihlal_metni != "" else "Kantin yönetmeliğine aykırı işlem.", ceza_miktar)

	hud_tam_guncelle()

	for esya in dolap_esya_dugumleri:
		if esya:
			if esya.get("masada_secili") and esya.has_method("mahkuma_teslim_animasyonu"):
				esya.mahkuma_teslim_animasyonu()
			elif esya.has_method("rafina_don"):
				esya.rafina_don()
	ilac_secildi = false
	yemek_secildi = false
	icecek_secildi = false
	dolap_esyalarini_kontrol_et()

	if secilen_damga == "ONAYLANDI":
		diyalog_balonlarini_goster(m.get("onay_1", "Eyvallah şefim!"), m.get("onay_2", "Sen bir tanesin!"))
	else:
		diyalog_balonlarini_goster(m.get("red_1", "Yapma be memur bey..."), m.get("red_2", "Bunu unutmayacağım!"))
		if m.get("siddetli", false):
			cam_darbe_efekti()
	ses_oynat(ses_konusma)
	if m.get("id", "") == "elias":
		elias_karari = secilen_damga
		if secilen_damga == "ONAYLANDI":
			direnis_puani += 2
			isik_titret(1.2)
			ses_oynat(ses_alarm, -6.0)
		else:
			sadakat_puani += 2
			ekran_salla(5.0)
			ses_oynat(ses_thud)
		hud_tam_guncelle()
	secilen_damga = ""

	# Fiş masadan küçülerek delikten geri çekilir ve kaybolur
	var fis = find_child("TalepFisi")
	if fis:
		fis.set("masada_acik", false)
		fis.set("is_dragging", false)
		var t_f = create_tween()
		t_f.parallel().tween_property(fis, "scale", Vector2(0.28, 0.28), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t_f.parallel().tween_property(fis, "position:y", 155.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t_f.parallel().tween_property(fis, "modulate:a", 0.0, 0.3)
		t_f.tween_callback(func():
			fis.visible = false
		)

	# Mahkum gişeden yürüyerek ayrılır, ardından kepenk kapanır
	var kepenk = find_child("Kepenk")
	var gorsel = find_child("MahkumGorsel")
	mahkum_ayriliyor = true
	var son_mahkum_mu: bool = aktif_mahkum_indeksi >= mahkum_listesi.size() - 1
	var son_olay: String = str(m.get("orta_olay_sonrasi", ""))
	if gorsel:
		mahkum_yuru_cikis(gorsel)
	if kepenk:
		if tween_kepenk and tween_kepenk.is_valid():
			tween_kepenk.kill()
		tween_kepenk = create_tween()
		tween_kepenk.tween_interval(1.45)
		tween_kepenk.tween_property(kepenk, "position:y", 0.0, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween_kepenk.tween_callback(func():
			if gorsel and not gisede_mahkum_var:
				gorsel.modulate.a = 0.0
			mahkum_ayriliyor = false
			hud_tam_guncelle()
			_teslim_sonrasi_kontrol(son_olay, son_mahkum_mu)
		)

	var balon = find_child("KonusmaBalonu")
	if balon:
		get_tree().create_timer(1.5).timeout.connect(func():
			if not gisede_mahkum_var and balon:
				balon.visible = false
		)


func bildirim_goster(mesaj: String, renk: Color) -> void:
	var bildirim_paneli = find_child("BildirimKutusu") as ColorRect
	var yazi = find_child("BildirimYazisi") as Label
	if bildirim_paneli:
		bildirim_paneli.color = Color(0.07, 0.08, 0.10, 0.97)
		bildirim_paneli.position = Vector2(272.0, 516.0)
		bildirim_paneli.size = Vector2(480.0, 44.0)
		bildirim_paneli.pivot_offset = Vector2(240.0, 22.0)
		bildirim_paneli.z_as_relative = false
		bildirim_paneli.z_index = 92
		var cerceve = bildirim_paneli.get_node_or_null("BildirimCerceve") as ReferenceRect
		if not cerceve:
			cerceve = ReferenceRect.new()
			cerceve.name = "BildirimCerceve"
			cerceve.editor_only = false
			cerceve.border_width = 2.0
			cerceve.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bildirim_paneli.add_child(cerceve)
		cerceve.size = bildirim_paneli.size
		cerceve.border_color = Color(renk.r * 0.85, renk.g * 0.85, renk.b * 0.85, 0.95)
		var vurgu = bildirim_paneli.get_node_or_null("BildirimVurgu") as ColorRect
		if not vurgu:
			vurgu = ColorRect.new()
			vurgu.name = "BildirimVurgu"
			vurgu.position = Vector2.ZERO
			vurgu.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bildirim_paneli.add_child(vurgu)
		vurgu.size = Vector2(6.0, bildirim_paneli.size.y)
		vurgu.color = renk
	if yazi:
		yazi.position = Vector2(14.0, 4.0)
		yazi.size = Vector2(456.0, 34.0)
		yazi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		yazi.text = mesaj
		yazi.modulate = renk
		yazi.add_theme_font_size_override("font_size", 11)
	if bildirim_paneli:
		bildirim_paneli.visible = true
		bildirim_paneli.move_to_front()
		bildirim_paneli.scale = Vector2(0.92, 0.92)
		var t = create_tween()
		t.tween_property(bildirim_paneli, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func nefes_animasyonu_baslat() -> void:
	var gorsel = find_child("MahkumGorsel")
	if not gorsel: return
	var tween = create_tween().set_loops()
	tween.tween_property(gorsel, "scale:y", 1.03, 1.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(gorsel, "scale:y", 1.0, 1.4).set_trans(Tween.TRANS_SINE)


func _input(event: InputEvent) -> void:
	# Görevli konuşurken herhangi bir tıklama repliği geçer
	if gorevli_teslimatta and event is InputEventMouseButton and event.pressed:
		konusma_atla = true

	# İhtar fişi ve mahkum notu sürükleme bırakma
	if _ihtar_surukleniyor and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_ihtar_surukleniyor = false
	if _not_surukleniyor and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_not_surukleniyor = false

	# SPACE ve TAB tuşları GUI buton odağına takılmadan her zaman İnceleme (Eşleştirme) modunu açıp kapatsın!
	if not ana_menu_acik and not olay_paneli_acik and not oyun_bitti:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_SPACE or event.keycode == KEY_TAB or event.physical_keycode == KEY_SPACE:
				_on_inceleme_butonu_basildi()
				get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if ana_menu_acik:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_N or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if gorevli_teslimatta:
				gorevli_tumunu_atla = true
				konusma_atla = true
				get_viewport().set_input_as_handled()
			elif not gisede_mahkum_var and not yeni_mahkum_geliyor:
				_on_siradaki_basildi()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_Q:
			if gisede_mahkum_var:
				mahkum_sorgula()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_1:
			if gisede_mahkum_var:
				_on_onay_basildi()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_2:
			if gisede_mahkum_var:
				_on_red_basildi()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_T:
			if gisede_mahkum_var:
				_on_teslim_et_basildi()
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_B or event.keycode == KEY_K:
			kural_kitabi_ac_kapat()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_G:
			gazete_okuma_ac_kapat()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_D:
			_on_cekmece_kol_basildi()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			var gp = find_child("GazeteOkumaPaneli")
			var kp = find_child("KuralKitabiPaneli")
			if gp and gp.visible:
				gazete_okuma_ac_kapat()
			elif kp and kp.visible:
				kural_kitabi_ac_kapat()
			elif inceleme_modu_aktif:
				_on_inceleme_butonu_basildi()
			elif not olay_paneli_acik:
				ana_menu_goster()
			get_viewport().set_input_as_handled()


func _on_inceleme_butonu_basildi() -> void:
	inceleme_modu_aktif = not inceleme_modu_aktif
	ses_oynat(ses_dugme)
	var btn_incele = find_child("IncelemeButonu")
	var etiket_incele = find_child("IncelemeEtiket")

	if inceleme_modu_aktif:
		var fis = find_child("TalepFisi") as Control
		if fis and fis.visible and not fis.get("masada_acik") and fis.has_method("masaya_ac"):
			fis.masaya_ac(false)
		var kk = find_child("KuralKitabiPaneli") as Control
		var gz = find_child("GazeteOkumaPaneli") as Control
		if kk and kk.visible:
			_panelleri_yan_yana_duzenle(kk)
		elif gz and gz.visible:
			_panelleri_yan_yana_duzenle(gz)
		if btn_incele:
			btn_incele.text = "[ ! ]\nAKTİF"
			btn_incele.add_theme_color_override("font_color", Color(1.0, 0.45, 0.2, 1.0))
		if etiket_incele:
			etiket_incele.text = "EŞLEŞTİRİLİYOR"
			etiket_incele.add_theme_color_override("font_color", Color(1.0, 0.45, 0.2, 1.0))
		bildirim_goster("[ EŞLEŞTİRME MODU ] Karşılaştırmak için Fiş ve Kural Kitabı / Gazete / Takvim / Emir üzerinden 2 öğeye tıklayın!", Color(1.0, 0.85, 0.4))
	else:
		if btn_incele:
			btn_incele.text = "[ ! ]\nİNCELE"
			btn_incele.remove_theme_color_override("font_color")
		if etiket_incele:
			etiket_incele.text = "EŞLEŞTİR"
			etiket_incele.remove_theme_color_override("font_color")
		_hedefleri_temizle()
		var bildirim = find_child("BildirimKutusu")
		if bildirim: bildirim.visible = false


func inceleme_ogesi_secildi(id: String, ad: String, node: Control) -> void:
	if not inceleme_modu_aktif: return

	ses_oynat(ses_dugme)
	if not secilen_inceleme_1.is_empty() and not secilen_inceleme_2.is_empty():
		_hedefleri_temizle()

	if secilen_inceleme_1.is_empty():
		secilen_inceleme_1 = {"id": id, "ad": ad, "node": node}
		_hedef_yerlestir(hedef_isaretleyici_1, node)
		bildirim_goster("1. ÖĞE SEÇİLDİ: \"" + ad + "\"  ►  Şimdi karşılaştırmak için 2. öğeye tıklayın.", Color(0.95, 0.9, 0.5))
	else:
		if secilen_inceleme_1["id"] == id and secilen_inceleme_1["node"] == node:
			_hedefleri_temizle()
			bildirim_goster("Seçim iptal edildi. Karşılaştırmak için 1. öğeyi seçin.", Color.YELLOW)
			return

		secilen_inceleme_2 = {"id": id, "ad": ad, "node": node}
		_hedef_yerlestir(hedef_isaretleyici_2, node)
		if inceleme_cizgisi and hedef_isaretleyici_1 and hedef_isaretleyici_2:
			var c1 = hedef_isaretleyici_1.global_position + hedef_isaretleyici_1.size * 0.5
			var c2 = hedef_isaretleyici_2.global_position + hedef_isaretleyici_2.size * 0.5
			inceleme_cizgisi.clear_points()
			inceleme_cizgisi.add_point(c1)
			inceleme_cizgisi.add_point(c2)
			inceleme_cizgisi.visible = true
		eslestirme_kontrol_et(secilen_inceleme_1, secilen_inceleme_2)


func _hedef_yerlestir(hedef: ReferenceRect, node: Control) -> void:
	if not hedef or not node: return
	var sc: Vector2 = node.get_global_transform().get_scale()
	var gercek_boy: Vector2 = Vector2(node.size.x * absf(sc.x), node.size.y * absf(sc.y))
	hedef.visible = true
	hedef.global_position = node.global_position - Vector2(4.0, 4.0)
	hedef.size = gercek_boy + Vector2(8.0, 8.0)
	hedef.move_to_front()


func _hedefleri_temizle() -> void:
	secilen_inceleme_1.clear()
	secilen_inceleme_2.clear()
	if hedef_isaretleyici_1: hedef_isaretleyici_1.visible = false
	if hedef_isaretleyici_2: hedef_isaretleyici_2.visible = false
	if inceleme_cizgisi: inceleme_cizgisi.visible = false


func _inceleme_bitir() -> void:
	_hedefleri_temizle()
	if inceleme_modu_aktif:
		inceleme_modu_aktif = false
		var btn_incele = find_child("IncelemeButonu")
		var etiket_incele = find_child("IncelemeEtiket")
		if btn_incele:
			btn_incele.text = "[ ! ]\nİNCELE"
			btn_incele.remove_theme_color_override("font_color")
		if etiket_incele:
			etiket_incele.text = "EŞLEŞTİR"
			etiket_incele.remove_theme_color_override("font_color")


func eslestirme_kontrol_et(item1: Dictionary, item2: Dictionary) -> void:
	var id1: String = str(item1["id"])
	var id2: String = str(item2["id"])
	var pair: Array = [id1, id2]

	if (not gisede_mahkum_var and not yeni_mahkum_geliyor) or aktif_mahkum_indeksi < 0 or aktif_mahkum_indeksi >= mahkum_listesi.size():
		bildirim_goster("Gişede mahkum yokken eşleştirme yapılamaz!", Color.YELLOW)
		get_tree().create_timer(1.2).timeout.connect(_inceleme_bitir)
		return

	var m = mahkum_listesi[aktif_mahkum_indeksi]
	var blok = m["blok"]
	var kural = blok_kurallari.get(blok, {"ilac": false, "icecek": false, "yiyecek": false})

	var fis_secildi: bool = id1.begins_with("fis_") or id2.begins_with("fis_")
	var esya_secildi: bool = id1.begins_with("esya_") or id2.begins_with("esya_")
	var referans_secildi: bool = (
		"kural_blok" in pair or "kural_evrak" in pair or
		"gazete_haber" in pair or "gazete_tarih" in pair or
		"emir_notu" in pair or "hud_tarih" in pair
	)

	# Dolap Eşyası ile Fiş veya Kural Kitabı Eşleştirmesi
	if esya_secildi and (fis_secildi or referans_secildi):
		var e_id: String = id1 if id1.begins_with("esya_") else id2
		var alan: String = "ilac" if e_id == "esya_ilac" else ("yiyecek" if e_id == "esya_yemek" else "icecek")
		var ad_kat: String = "İLAÇ / SARGI" if alan == "ilac" else ("YİYECEK" if alan == "yiyecek" else "İÇECEK")
		if not kural[alan]:
			ses_oynat(ses_damga)
			bildirim_goster("⚠ YASAKLI EŞYA! Kural Kitabına göre %s mahkumuna %s verilmesi KESİN YASAKTIR!" % [blok, ad_kat], Color(1.0, 0.25, 0.2))
		elif not m[alan]:
			ses_oynat(ses_damga)
			bildirim_goster("⚠ TALEP YOK! Mahkum fişinde %s talep etmemiş!" % ad_kat, Color(1.0, 0.55, 0.2))
		else:
			ses_oynat(ses_dugme)
			bildirim_goster("✓ UYGUN EŞYA: %s mahkumu için %s hem talep edilmiş hem de serbest." % [blok, ad_kat], Color(0.2, 0.9, 0.3))
		get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
		return

	# 0. 5. Gün Özel Emir (Elias Crane ile Warden Graves Emri veya Kural Kitabı)
	if m.get("id", "") == "elias" and fis_secildi and referans_secildi:
		ses_oynat(ses_alarm, -6.0)
		bildirim_goster("⚠ KRİTİK ÇELİŞKİ! Warden Graves #00713 Elias Crane'in reddedilmesini emretti; ancak evrakı Kural Kitabına tam uygun!", Color(1.0, 0.45, 0.2))
		mahkum_panik_diyalog(m.get("sorgu", "Warden Graves gerçekleri gizlemek için beni yasakladı!"))
		get_tree().create_timer(2.6).timeout.connect(_inceleme_bitir)
		return

	# 1. Yüz ve Vesikalık Fotoğraf / Fiş
	if "mahkum_yuz" in pair and fis_secildi:
		ses_oynat(ses_dugme)
		bildirim_goster("✓ FOTOĞRAF EŞLEŞMESİ: Gişedeki mahkum (" + str(m["ad"]) + ") ile sicil fotoğrafı UYUŞUYOR.", Color(0.2, 0.9, 0.3))
		get_tree().create_timer(1.8).timeout.connect(_inceleme_bitir)
		return

	# 2. Tarih Kontrolü (Fiş Tarihi veya Takvim HUD seçildiyse)
	if ("fis_tarih" in pair and referans_secildi) or ("hud_tarih" in pair and fis_secildi):
		if m["tarih"] != bugun_tarih:
			ses_oynat(ses_damga)
			bildirim_goster("⚠ ÇELİŞKİ TESPİT EDİLDİ! Fişin tarihi (" + str(m["tarih"]) + ") geçersiz! Güncel tarih " + bugun_tarih + " olmalıdır!", Color(1.0, 0.25, 0.2))
			mahkum_panik_diyalog(m.get("sorgu", "Reçetem biraz eski şefim... Lütfen görmezden gel, ilacıma mecburum!"))
		else:
			ses_oynat(ses_dugme)
			bildirim_goster("✓ TARİH UYUŞUYOR: Belge tarihi (" + bugun_tarih + ") bugünün tarihiyle eşleşiyor.", Color(0.2, 0.9, 0.3))
		get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
		return

	# 3. Gardiyan İmzası Kontrolü
	if "fis_imza" in pair and referans_secildi:
		if not (m["gardiyan"] in gecerli_gardiyanlar):
			ses_oynat(ses_damga)
			bildirim_goster("⚠ ÇELİŞKİ TESPİT EDİLDİ! " + str(m["gardiyan"]) + " imzası geçersiz! Yalnızca " + " ve ".join(gecerli_gardiyanlar) + " geçerlidir!", Color(1.0, 0.25, 0.2))
			mahkum_panik_diyalog(m.get("sorgu", "Lanet olsun... Voss bana bu imzanın geçeceğini söylemişti!"))
		else:
			ses_oynat(ses_dugme)
			bildirim_goster("✓ İMZA GEÇERLİ: Fişteki " + str(m["gardiyan"]) + " imzası yetkili gardiyanlar listesinde.", Color(0.2, 0.9, 0.3))
		get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
		return

	# 4. İzin Durumu ("Kısıtlı") Kontrolü
	if "fis_izin" in pair and referans_secildi:
		if m["izin"] == "Kısıtlı":
			ses_oynat(ses_damga)
			bildirim_goster("⚠ ÇELİŞKİ TESPİT EDİLDİ! Kural Kitabına göre 'Kısıtlı' izinli mahkuma eşya verilemez!", Color(1.0, 0.25, 0.2))
			mahkum_panik_diyalog(m.get("sorgu", "Disiplin cezam bitmek üzere memur bey, lütfen idare ediver..."))
		else:
			ses_oynat(ses_dugme)
			bildirim_goster("✓ İZİN UYGUN: Mahkumun izin seviyesi (" + str(m["izin"]) + ") standartlara uygun.", Color(0.2, 0.9, 0.3))
		get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
		return

	# 5. Blok Talebi veya Genel Fiş ile Kural Kitabı / Gazete / Emir Notu Eşleştirmesi
	if fis_secildi and referans_secildi:
		# Önce evrak veya blok üzerinde herhangi bir çelişki var mı tam tarama yap:
		var yasakli: bool = false
		var sebep: String = ""
		if m["ilac"] and not kural["ilac"]:
			yasakli = true
			sebep = blok + " mahkumuna İLAÇ / SARGI verilmesi yasaktır!"
		elif m["icecek"] and not kural["icecek"]:
			yasakli = true
			sebep = blok + " mahkumuna İÇECEK verilmesi yasaktır!"
		elif m["yiyecek"] and not kural["yiyecek"]:
			yasakli = true
			sebep = blok + " mahkumuna YİYECEK verilmesi yasaktır!"

		var ozel_talep_alan: bool = ("fis_talep_ilac" in pair or "fis_talep_yemek" in pair or "fis_talep_icecek" in pair or "fis_blok" in pair)
		if ozel_talep_alan and yasakli:
			ses_oynat(ses_damga)
			bildirim_goster("⚠ ÇELİŞKİ TESPİT EDİLDİ! Kural Kitabına göre " + sebep, Color(1.0, 0.25, 0.2))
			mahkum_panik_diyalog(m.get("sorgu", "Başım çatlıyor memur bey, revirde yoktu, kantinden istedim..."))
			get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
			return
		elif m["tarih"] != bugun_tarih:
			ses_oynat(ses_damga)
			bildirim_goster("⚠ ÇELİŞKİ TESPİT EDİLDİ! Fişin tarihi (" + str(m["tarih"]) + ") geçersiz! Güncel tarih " + bugun_tarih + " olmalıdır!", Color(1.0, 0.25, 0.2))
			mahkum_panik_diyalog(m.get("sorgu", "Reçetem biraz eski şefim... Lütfen görmezden gel, ilacıma mecburum!"))
			get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
			return
		elif not (m["gardiyan"] in gecerli_gardiyanlar):
			ses_oynat(ses_damga)
			bildirim_goster("⚠ ÇELİŞKİ TESPİT EDİLDİ! " + str(m["gardiyan"]) + " imzası geçersiz! Yalnızca " + " ve ".join(gecerli_gardiyanlar) + " geçerlidir!", Color(1.0, 0.25, 0.2))
			mahkum_panik_diyalog(m.get("sorgu", "Lanet olsun... Voss bana bu imzanın geçeceğini söylemişti!"))
			get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
			return
		elif m["izin"] == "Kısıtlı":
			ses_oynat(ses_damga)
			bildirim_goster("⚠ ÇELİŞKİ TESPİT EDİLDİ! Kural Kitabına göre 'Kısıtlı' izinli mahkuma eşya verilemez!", Color(1.0, 0.25, 0.2))
			mahkum_panik_diyalog(m.get("sorgu", "Disiplin cezam bitmek üzere memur bey, lütfen idare ediver..."))
			get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
			return
		elif yasakli:
			ses_oynat(ses_damga)
			bildirim_goster("⚠ ÇELİŞKİ TESPİT EDİLDİ! Kural Kitabına göre " + sebep, Color(1.0, 0.25, 0.2))
			mahkum_panik_diyalog(m.get("sorgu", "Başım çatlıyor memur bey, revirde yoktu, kantinden istedim..."))
			get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
			return
		else:
			ses_oynat(ses_dugme)
			bildirim_goster("✓ KURALLARA UYGUN: " + blok + " istihkak talebi ve evrak bilgileri kurallarla uyuşuyor.", Color(0.2, 0.9, 0.3))
			get_tree().create_timer(2.2).timeout.connect(_inceleme_bitir)
			return

	# 6. Mahkum Repliği ile Fiş veya Kural Kitabı
	if "mahkum_replik" in pair and (fis_secildi or referans_secildi):
		ses_oynat(ses_dugme)
		bildirim_goster("✓ BEYAN UYUŞUYOR: Mahkumun söylediği replik ile fişteki talep eşleşiyor.", Color(0.2, 0.9, 0.3))
		get_tree().create_timer(1.8).timeout.connect(_inceleme_bitir)
		return

	# 7. Diğer Eşleştirmeler
	ses_oynat(ses_dugme)
	bildirim_goster("• Seçilen iki bilgi arasında herhangi bir çelişki bulunamadı.", Color(0.85, 0.85, 0.85))
	get_tree().create_timer(1.5).timeout.connect(_inceleme_bitir)


func mahkum_panik_diyalog(replik: String) -> void:
	ses_oynat(ses_konusma)
	if mahkum_notu_dugumu and mahkum_notu_dugumu.visible:
		_mahkum_notu_vurgula()
		diyalog_balonlarini_goster("Şşşt memur bey, gardiyanlar duyacak!", "Durumu masaya uzattığım küçük kağıda yazdım, lütfen onu oku...")
	else:
		diyalog_balonlarini_goster("[! ÇELİŞKİ !]", replik)
	var balon = find_child("KonusmaBalonu")
	if balon:
		var tb = create_tween()
		tb.tween_property(balon, "position:x", balon.position.x - 6.0, 0.05)
		tb.tween_property(balon, "position:x", balon.position.x + 6.0, 0.05)
		tb.tween_property(balon, "position:x", balon.position.x, 0.05)


func gunu_baslat(gun_no: int) -> void:
	aktif_gun = gun_no
	oyun_bitti = false
	oyunu_kaydet()
	gun_verisi = Hikaye.GUNLER[gun_no]
	bugun_tarih = Hikaye.tarih_str(gun_no)
	gecerli_gardiyanlar = gun_verisi["gecerli_gardiyanlar"]
	blok_kurallari = gun_verisi["kurallar"]
	gun_dogru = 0
	gun_hata = 0
	gun_kazanc = 0
	gun_rusvet = 0
	gece_secim_ozeti = ""
	gun_sonu_basladi = false
	_rusvet_gizle()
	_pusula_gizle()
	_mahkum_notu_gizle()
	mahkum_listesi = gunluk_liste_uret(gun_no)
	aktif_mahkum_indeksi = -1
	gisede_mahkum_var = false
	yeni_mahkum_geliyor = false
	mahkum_ayriliyor = false
	gorevli_tumunu_atla = false
	gorevli_teslimatta = true

	# Açık paneller kapansın, gişe boşalsın
	for ad in ["GazeteOkumaPaneli", "KuralKitabiPaneli", "BildirimKutusu", "KonusmaBalonu"]:
		var n = find_child(ad)
		if n: n.visible = false
	var kepenk = find_child("Kepenk")
	if kepenk: kepenk.position.y = 0.0
	var mg = find_child("MahkumGorsel")
	if mg: mg.modulate.a = 0.0

	var panel = find_child("KasaPaneli")
	if panel:
		for c in panel.get_children():
			if c is Label and ("NİSAN" in c.text or "GÜN" in c.text):
				c.text = "%d NİSAN 1984 • %d. GÜN" % [gun_verisi["tarih_gun"], aktif_gun]

	# İçerikler (gazete, kural kitabı, emir notu) bugüne göre yenilenir
	var gazete = find_child("CezaeviPostasi")
	if gazete: gazete.visible = false
	gazete_icerik_yukle()
	kural_kitabi_yukle()
	emir_notu_guncelle()
	kuyruk_gorunurlugu_guncelle()
	hud_tam_guncelle()

	await gun_karti_goster()
	await gorevli_ziyaret("gazete")
	hud_tam_guncelle()


func _teslim_sonrasi_kontrol(son_olay: String, son_mahkum_mu: bool) -> void:
	if son_olay != "":
		await orta_olay_goster(son_olay)
		if oyun_bitti:
			return
	if son_mahkum_mu and not gun_sonu_basladi:
		gun_sonu_akisi()


# ------------------------------------------------------------------------------------
# GÜNLÜK MAHKUM LİSTESİ (KURGULANMIŞ HİKAYE SENARYOLARI)
# ------------------------------------------------------------------------------------
func gunluk_liste_uret(gun: int) -> Array:
	var veri = Hikaye.GUNLER[gun]
	if Hikaye.GUN_SENARYOLARI.has(gun):
		var senaryo_listesi: Array = Hikaye.GUN_SENARYOLARI[gun]
		var CikisListesi: Array = []
		for s_item in senaryo_listesi:
			var k: String = s_item["id"]
			if k == "elias":
				var el = elias_olustur()
				el["replik_1"] = s_item.get("replik_1", el["replik_1"])
				el["replik_2"] = s_item.get("replik_2", el["replik_2"])
				if s_item.has("kagit_not"): el["kagit_not"] = s_item["kagit_not"]
				if s_item.has("pusula"): el["pusula"] = s_item["pusula"]
				CikisListesi.append(el)
			else:
				var m = mahkum_olustur(k, veri, gun)
				m["ilac"] = s_item.get("ilac", false)
				m["yiyecek"] = s_item.get("yiyecek", false)
				m["icecek"] = s_item.get("icecek", false)
				m["tarih"] = Hikaye.tarih_str(gun)
				m["gardiyan"] = veri["gecerli_gardiyanlar"][0]
				m["izin"] = "Standart"
				var sahte_tip: String = str(s_item.get("sahte", ""))
				match sahte_tip:
					"tarih": m["tarih"] = eski_tarih_uret(gun)
					"imza": m["gardiyan"] = veri["sahte_gardiyan"]
					"izin": m["izin"] = "Kısıtlı"
				if s_item.has("replik_1"): m["replik_1"] = s_item["replik_1"]
				if s_item.has("replik_2"): m["replik_2"] = s_item["replik_2"]
				if s_item.has("pusula"): m["pusula"] = s_item["pusula"]
				if s_item.has("kagit_not"): m["kagit_not"] = s_item["kagit_not"]
				if s_item.has("orta_olay_oncesi"): m["orta_olay_oncesi"] = s_item["orta_olay_oncesi"]
				if s_item.has("orta_olay_sonrasi"): m["orta_olay_sonrasi"] = s_item["orta_olay_sonrasi"]
				CikisListesi.append(m)
		return CikisListesi

	var havuz: Array = []
	for k in Hikaye.KADRO.keys():
		if k == "elias" or k in nakledilenler:
			continue
		havuz.append(k)
	havuz.shuffle()
	var sayi: int = veri["mahkum_sayisi"]
	if gun == Hikaye.SON_GUN:
		sayi -= 1
	var secim: Array = havuz.slice(0, sayi)
	var liste: Array = []
	for k in secim:
		liste.append(mahkum_olustur(k, veri, gun))
	if gun == Hikaye.SON_GUN:
		liste.append(elias_olustur())
	return liste


func _liste_cumle(parcalar: Array) -> String:
	if parcalar.size() == 1:
		return parcalar[0]
	if parcalar.size() == 2:
		return parcalar[0] + " ve " + parcalar[1]
	return parcalar[0] + ", " + parcalar[1] + " ve " + parcalar[2]


func eski_tarih_uret(gun: int) -> String:
	var g: int = Hikaye.GUNLER[gun]["tarih_gun"]
	var secenekler = ["%02d.04.1984" % (g - 1), "%02d.04.1983" % g, "%02d.03.1984" % g, "12.01.1983"]
	if g <= 18:
		secenekler = ["12.01.1983", "%02d.04.1983" % g]
	return secenekler[randi() % secenekler.size()]


func mahkum_olustur(k: String, veri: Dictionary, gun: int) -> Dictionary:
	var kd = Hikaye.KADRO[k]
	var kural = veri["kurallar"][kd["blok"]]
	var m: Dictionary = {
		"id": k, "ad": kd["ad"], "no": kd["no"], "blok": kd["blok"],
		"gorsel": load(kd["gorsel"]),
		"siddetli": kd.get("siddetli", false),
		"sorgu": kd.get("sorgu", "Evrakta bir sorun mu var memur bey?"),
		"rusvet": kd.get("rusvet", ""),
		"tarih": Hikaye.tarih_str(gun),
		"gardiyan": veri["gecerli_gardiyanlar"][randi() % veri["gecerli_gardiyanlar"].size()],
		"izin": ["Standart", "Tam İzin"][randi() % 2],
	}
	# Talepler: izinli olanlar daha olası, ama yasaklı talepler de gelir
	var ilac: bool = randf() < (0.65 if kural["ilac"] else 0.25)
	var yiyecek: bool = randf() < (0.65 if kural["yiyecek"] else 0.25)
	var icecek: bool = randf() < (0.65 if kural["icecek"] else 0.25)
	if not (ilac or yiyecek or icecek):
		var r = randi() % 3
		ilac = (r == 0)
		yiyecek = (r == 1)
		icecek = (r == 2)
	m["ilac"] = ilac
	m["yiyecek"] = yiyecek
	m["icecek"] = icecek

	if randf() < veri["sahte_orani"] and not veri["sahte_tipleri"].is_empty():
		var tip: String = veri["sahte_tipleri"][randi() % veri["sahte_tipleri"].size()]
		match tip:
			"tarih": m["tarih"] = eski_tarih_uret(gun)
			"imza": m["gardiyan"] = veri["sahte_gardiyan"]
			"izin": m["izin"] = "Kısıtlı"

	var istekler: Array = []
	if ilac: istekler.append("ilaç")
	if yiyecek: istekler.append("yiyecek")
	if icecek: istekler.append("içecek")
	m["replik_1"] = kd["acilis"][randi() % kd["acilis"].size()]
	m["replik_2"] = "İstediğim: " + _liste_cumle(istekler) + "."
	if k == "moe":
		m["replik_2"] = "Mmh! (Fişi parmağıyla gösteriyor.)"
	var o = Hikaye.ONAY_REPLIKLERI.duplicate()
	var r2 = Hikaye.RED_REPLIKLERI.duplicate()
	o.shuffle()
	r2.shuffle()
	m["onay_1"] = o[0]
	m["onay_2"] = o[1]
	m["red_1"] = r2[0]
	m["red_2"] = r2[1]
	return m


func elias_olustur() -> Dictionary:
	var kd = Hikaye.KADRO["elias"]
	return {
		"id": "elias", "ad": kd["ad"], "no": kd["no"], "blok": kd["blok"],
		"gorsel": load(kd["gorsel"]),
		"tarih": bugun_tarih, "gardiyan": "Guard Harlan", "izin": "Standart",
		"ilac": true, "yiyecek": false, "icecek": false,
		"replik_1": kd["acilis"][0],
		"replik_2": kd["acilis"][1],
		"kagit_not": {
			"baslik": "ACİL GİZLİ NOT • ELIAS CRANE (#00713)",
			"metin": "\"Memur bey, gardiyanlar dinlediği için sesli konuşamıyorum! Warden Graves, D Blok mahzenindeki yasadışı deneyleri ifşa edeceğimi bildiği için özel emirle adımı yasakladı. Evrakım kurallara %100 uygun! Fişime ONAY basıp ilacımı verirseniz kutudaki mikrofilmi müfettişe ulaştıracağım!\"",
			"parali": false
		},
		"onay_1": "Teşekkür ederim memur bey, kolay gelsin.",
		"onay_2": "İyi nöbetler dilerim.",
		"red_1": "Anlıyorum... Peki memur bey.",
		"red_2": "Hayırlı vardiyalar.",
	}


# ------------------------------------------------------------------------------------
# GAZETE / KURAL KİTABI / EMİR NOTU İÇERİKLERİ
# ------------------------------------------------------------------------------------
func gazete_icerik_yukle() -> void:
	var g = gun_verisi["gazete"]
	var map = {
		"GazeteAnaBaslik": gun_verisi["baslik"],
		"SolBaslik": g["sol_baslik"],
		"Aranan1Yazi": g["aranan1"],
		"Aranan2Yazi": g["aranan2"],
		"SolAltYazi": g["sol_alt"],
		"SagBaslik": g["sag_baslik"],
		"SagUstYazi": g["sag_ust"],
		"SagAltYazi": g["sag_alt"],
	}
	for ad in map.keys():
		var l = find_child(ad) as Label
		if l:
			l.text = map[ad]
	var a1 = find_child("Aranan1Yazi") as Label
	var a2 = find_child("Aranan2Yazi") as Label
	var su = find_child("SagUstYazi") as Label
	var sa = find_child("SagAltYazi") as Label
	var sl = find_child("SolAltYazi") as Label
	for l in [a1, a2, su, sa, sl]:
		if l:
			l.add_theme_font_size_override("font_size", 11)
			l.autowrap_mode = TextServer.AUTOWRAP_OFF
	if a1: a1.size = Vector2(190.0, 62.0)
	if a2: a2.size = Vector2(190.0, 62.0)
	if sl: sl.size = Vector2(200.0, 90.0)
	if su: su.size = Vector2(200.0, 124.0)
	if sa: sa.size = Vector2(200.0, 96.0)
	var kapat = find_child("GazeteKapatButonu")
	if kapat:
		kapat.move_to_front()


func blok_aciklama(blok: String) -> String:
	var k = blok_kurallari.get(blok, {"yiyecek": false, "icecek": false, "ilac": false})
	var izinli: Array = []
	var yasakli: Array = []
	for pair in [["yiyecek", "Yiyecek"], ["icecek", "İçecek"], ["ilac", "İlaç/Sargı"]]:
		if k[pair[0]]:
			izinli.append(pair[1])
		else:
			yasakli.append(pair[1])
	var s = blok + " Kuralı: "
	s += ("Serbest: " + ", ".join(izinli)) if not izinli.is_empty() else "HİÇBİR ŞEY SERBEST DEĞİL"
	if not yasakli.is_empty():
		s += " | Yasak: " + ", ".join(yasakli)
	return s


func kural_kitabi_yukle() -> void:
	for harf in ["A", "B", "C"]:
		var l = find_child(harf + "BlokIcerik") as Label
		if not l: continue
		var k = blok_kurallari[harf + " Blok"]
		l.text = "• Yiyecek (Konserve/Cips): %s\n• İçecek (Kola/M.Suyu): %s\n• İlaç / Sargı Bezi: %s" % [
			"SERBEST" if k["yiyecek"] else "YASAK!",
			"SERBEST" if k["icecek"] else "YASAK!",
			"SERBEST" if k["ilac"] else "YASAK!"]
	var ev = find_child("EvrakKuralIcerik") as Label
	if ev:
		var kisa: Array = []
		for gname in gecerli_gardiyanlar:
			kisa.append(str(gname).replace("Guard ", ""))
		ev.text = "• Geçerli Tarih: %s\n  (Eski tarihli fişleri REDDEDİN!)\n• Yetkili İmza: %s\n  (%s imzası GEÇERSİZ!)\n• İzin: Kısıtlı olanları REDDEDİN!" % [
			bugun_tarih, " ve ".join(kisa), str(gun_verisi["sahte_gardiyan"])]


func emir_notu_guncelle() -> void:
	var nota = find_child("GardiyanEmri") as TextureRect
	if not nota: return
	nota.texture = preload("res://assets/emir_notu_bos.png")
	var l = nota.get_node_or_null("EmirYazisi") as Label
	if not l:
		l = Label.new()
		l.name = "EmirYazisi"
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
		l.add_theme_font_size_override("font_size", 10)
		l.add_theme_color_override("font_color", Color(0.14, 0.09, 0.07, 1.0))
		l.custom_minimum_size = Vector2(138.0, 0.0)
		l.position = Vector2(9.0, 14.0)
		l.size = Vector2(138.0, 76.0)
		nota.add_child(l)
	l.text = gun_verisi["emir"]


# ------------------------------------------------------------------------------------
# KATMANLAR, GÜN KARTI, RAPOR VE SON EKRANLARI
# ------------------------------------------------------------------------------------
func ust_katman_al() -> CanvasLayer:
	var kat = get_node_or_null("UstKatman") as CanvasLayer
	if not kat:
		kat = CanvasLayer.new()
		kat.name = "UstKatman"
		kat.layer = 90
		add_child(kat)
	return kat


func _etiket(metin: String, boyut: int, renk: Color, poz: Vector2, boy: Vector2) -> Label:
	var l = Label.new()
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	l.add_theme_font_size_override("font_size", boyut)
	l.add_theme_color_override("font_color", renk)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.custom_minimum_size = Vector2(boy.x, 0.0)
	l.position = poz
	l.size = boy
	l.text = metin
	return l


func gun_karti_goster() -> void:
	var kat = ust_katman_al()
	var kart = ColorRect.new()
	kart.name = "GunKartiKapak"
	kart.color = Color(0, 0, 0, 1)
	kart.size = Vector2(1024.0, 571.0)
	kart.mouse_filter = Control.MOUSE_FILTER_STOP
	kat.add_child(kart)
	var l1 = _etiket("GÜN %d" % aktif_gun, 40, Color(0.78, 0.2, 0.16), Vector2(0, 190), Vector2(1024, 50))
	var l2 = _etiket("%d NİSAN 1984" % gun_verisi["tarih_gun"], 20, Color(0.82, 0.78, 0.66), Vector2(0, 244), Vector2(1024, 28))
	var l3 = _etiket(gun_verisi["kart_alt"], 13, Color(0.55, 0.55, 0.52), Vector2(212, 292), Vector2(600, 50))
	for l in [l1, l2, l3]:
		l.modulate.a = 0.0
		kart.add_child(l)
	ses_oynat(ses_buzz, -8.0)
	var kart_atla := {"ok": false}
	kart.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			kart_atla["ok"] = true
	)
	var t = create_tween()
	t.tween_property(l1, "modulate:a", 1.0, 0.35)
	t.tween_property(l2, "modulate:a", 1.0, 0.25)
	t.tween_property(l3, "modulate:a", 1.0, 0.30)
	t.tween_interval(0.85)
	t.tween_property(kart, "modulate:a", 0.0, 0.35)
	while t.is_running() and not kart_atla["ok"] and not gorevli_tumunu_atla:
		await get_tree().create_timer(0.05).timeout
	if t.is_valid():
		t.kill()
	if is_instance_valid(kart):
		kart.queue_free()


func ekran_salla(guc: float) -> void:
	var t = create_tween()
	for i in range(5):
		t.tween_property(self, "position", Vector2(randf_range(-guc, guc), randf_range(-guc, guc)), 0.04)
	t.tween_property(self, "position", Vector2.ZERO, 0.05)


func _sik_buton_stili(b: Button, vurgu: Color) -> void:
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var sb_n = StyleBoxFlat.new()
	sb_n.bg_color = Color(0.14, 0.14, 0.17, 0.98)
	sb_n.border_color = Color(vurgu.r * 0.78, vurgu.g * 0.78, vurgu.b * 0.78, 0.92)
	sb_n.set_border_width_all(2)
	sb_n.border_width_left = 5
	sb_n.set_corner_radius_all(3)
	sb_n.corner_detail = 1
	sb_n.content_margin_left = 10
	sb_n.content_margin_right = 10

	var sb_h = sb_n.duplicate()
	sb_h.bg_color = Color(0.20, 0.19, 0.23, 0.99)
	sb_h.border_color = vurgu

	var sb_p = sb_n.duplicate()
	sb_p.bg_color = Color(0.10, 0.10, 0.12, 0.99)
	sb_p.border_color = vurgu

	b.add_theme_stylebox_override("normal", sb_n)
	b.add_theme_stylebox_override("hover", sb_h)
	b.add_theme_stylebox_override("pressed", sb_p)


func orta_olay_goster(olay_kodu: String) -> void:
	if not Hikaye.ORTA_OLAYLAR.has(olay_kodu):
		return
	olay_paneli_acik = true
	var veri = Hikaye.ORTA_OLAYLAR[olay_kodu]

	if "alarm" in olay_kodu or "isyan" in olay_kodu:
		ses_oynat(ses_alarm, -5.0)
		isik_titret(1.1)
		ekran_salla(5.5)
		if "isyan" in olay_kodu:
			cam_darbe_efekti()
	else:
		ses_oynat(ses_buzz, -4.0)
		isik_titret(0.5)

	var kat = ust_katman_al()
	var kapak = ColorRect.new()
	kapak.color = Color(0.02, 0.02, 0.03, 0.82)
	kapak.size = Vector2(1024.0, 571.0)
	kapak.mouse_filter = Control.MOUSE_FILTER_STOP
	kat.add_child(kapak)

	var panel = Panel.new()
	panel.position = Vector2(212, 84)
	panel.size = Vector2(600, 396)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.11, 0.1, 0.12, 0.98)
	sb.border_color = Color(0.88, 0.36, 0.22, 1.0)
	sb.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", sb)
	kapak.add_child(panel)

	panel.add_child(_etiket(veri["baslik"], 18, Color(0.98, 0.45, 0.25), Vector2(20, 16), Vector2(560, 28)))
	panel.add_child(_etiket(veri["metin"], 13, Color(0.9, 0.86, 0.78), Vector2(30, 54), Vector2(540, 118)))

	var secim_sonucu := {"secildi": false}
	var secenekler: Array = veri["secenekler"]
	var btn_y: float = 186.0
	var font = preload("res://assets/retro_font.ttf")

	for sec in secenekler:
		var b = Button.new()
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.position = Vector2(36, btn_y)
		b.custom_minimum_size = Vector2(528, 42)
		b.size = Vector2(528, 42)
		b.add_theme_font_override("font", font)
		b.add_theme_font_size_override("font_size", 11)
		b.add_theme_color_override("font_color", Color(0.96, 0.9, 0.74))
		_sik_buton_stili(b, Color(0.92, 0.56, 0.28, 1.0))
		b.text = "► " + str(sec["metin"])
		b.pressed.connect(func():
			if secim_sonucu["secildi"]: return
			secim_sonucu["secildi"] = true
			ses_oynat(ses_dugme)
			var p_deg: int = int(sec.get("para", 0))
			if p_deg != 0:
				para_guncelle(p_deg)
				gun_kazanc += p_deg
				if p_deg > 0:
					ses_oynat(ses_para)
			kanit_sayisi = clampi(kanit_sayisi + int(sec.get("kanit", 0)), 0, 5)
			direnis_puani += int(sec.get("direnis", 0))
			sadakat_puani += int(sec.get("sadakat", 0))
			hud_tam_guncelle()
			bildirim_goster(str(sec.get("sonuc", "Karar uygulandı.")), Color(0.95, 0.88, 0.45))
		)
		panel.add_child(b)
		btn_y += 52.0

	panel.scale = Vector2(0.9, 0.9)
	panel.pivot_offset = panel.size * 0.5
	var t = create_tween()
	t.tween_property(panel, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	while not secim_sonucu["secildi"]:
		await get_tree().create_timer(0.05).timeout

	var t2 = create_tween()
	t2.tween_property(kapak, "modulate:a", 0.0, 0.22)
	await t2.finished
	kapak.queue_free()
	olay_paneli_acik = false


func gece_olayi_goster(gun: int) -> void:
	if not Hikaye.GECE_OLAYLARI.has(gun):
		return
	olay_paneli_acik = true
	var veri = Hikaye.GECE_OLAYLARI[gun]
	ses_oynat(ses_kitap)

	var kat = ust_katman_al()
	var kapak = ColorRect.new()
	kapak.color = Color(0.01, 0.02, 0.04, 0.88)
	kapak.size = Vector2(1024.0, 571.0)
	kapak.mouse_filter = Control.MOUSE_FILTER_STOP
	kat.add_child(kapak)

	var panel = Panel.new()
	panel.position = Vector2(202, 78)
	panel.size = Vector2(620, 410)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.1, 0.14, 0.98)
	sb.border_color = Color(0.55, 0.68, 0.86, 1.0)
	sb.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", sb)
	kapak.add_child(panel)

	panel.add_child(_etiket(veri["baslik"], 18, Color(0.72, 0.86, 0.98), Vector2(20, 16), Vector2(580, 28)))
	panel.add_child(_etiket(veri["hikaye"], 13, Color(0.88, 0.86, 0.8), Vector2(32, 54), Vector2(556, 118)))
	panel.add_child(_etiket("Mevcut Kasa: %d $   •   Kanıt: %d/3" % [oyuncu_parasi, kanit_sayisi], 12, Color(0.96, 0.86, 0.45), Vector2(32, 166), Vector2(556, 22)))

	var secim_sonucu := {"secildi": false}
	var secenekler: Array = veri["secenekler"]
	var btn_y: float = 198.0
	var font = preload("res://assets/retro_font.ttf")

	for sec in secenekler:
		var b = Button.new()
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.position = Vector2(40, btn_y)
		b.custom_minimum_size = Vector2(540, 42)
		b.size = Vector2(540, 42)
		b.add_theme_font_override("font", font)
		b.add_theme_font_size_override("font_size", 11)
		b.add_theme_color_override("font_color", Color(0.95, 0.92, 0.82))
		_sik_buton_stili(b, Color(0.56, 0.76, 0.96, 1.0))
		b.text = "► " + str(sec["metin"])
		b.pressed.connect(func():
			if secim_sonucu["secildi"]: return
			secim_sonucu["secildi"] = true
			ses_oynat(ses_dugme)
			var p_deg: int = int(sec.get("para", 0))
			if p_deg != 0:
				para_guncelle(p_deg)
				if p_deg > 0:
					ses_oynat(ses_para)
			kanit_sayisi = clampi(kanit_sayisi + int(sec.get("kanit", 0)), 0, 5)
			direnis_puani += int(sec.get("direnis", 0))
			sadakat_puani += int(sec.get("sadakat", 0))
			gece_secim_ozeti = str(sec.get("sonuc", ""))
			hud_tam_guncelle()
		)
		panel.add_child(b)
		btn_y += 52.0

	panel.scale = Vector2(0.9, 0.9)
	panel.pivot_offset = panel.size * 0.5
	var t = create_tween()
	t.tween_property(panel, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	while not secim_sonucu["secildi"]:
		await get_tree().create_timer(0.05).timeout

	var t2 = create_tween()
	t2.tween_property(kapak, "modulate:a", 0.0, 0.22)
	await t2.finished
	kapak.queue_free()
	olay_paneli_acik = false


func rapor_paneli_goster(gun: int, bakiye_once: int, gunluk_net: int) -> void:
	var bildirim_paneli = find_child("BildirimKutusu")
	if bildirim_paneli: bildirim_paneli.visible = false
	if ihtar_dugumu: ihtar_dugumu.visible = false
	var kat = ust_katman_al()
	var kapak = ColorRect.new()
	kapak.color = Color(0, 0, 0, 0.78)
	kapak.size = Vector2(1024.0, 571.0)
	kapak.mouse_filter = Control.MOUSE_FILTER_STOP
	kat.add_child(kapak)
	var panel = Panel.new()
	panel.position = Vector2(262, 68)
	panel.size = Vector2(500, 430)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.1, 0.12, 0.98)
	sb.border_color = Color(0.5, 0.42, 0.3)
	sb.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", sb)
	kapak.add_child(panel)
	var altin = Color(0.9, 0.82, 0.55)
	panel.add_child(_etiket("GÜN %d BİLANÇOSU" % gun, 22, Color(0.8, 0.24, 0.18), Vector2(0, 14), Vector2(500, 28)))
	var satirlar = [
		["Doğru kararlar", "%d" % gun_dogru, Color(0.4, 0.85, 0.5)],
		["Hatalı kararlar", "%d" % gun_hata, Color(0.9, 0.35, 0.3)],
		["Vardiya & olay net", "%+d $" % gun_kazanc, altin],
		["Vardiya maaşı", "+%d $" % Hikaye.MAAS, altin],
		["Kira ve erzak gideri", "-%d $" % Hikaye.KIRA_YEMEK, Color(0.9, 0.5, 0.35)],
	]
	if gun_rusvet > 0:
		satirlar.insert(3, ["El altından rüşvet", "+%d $" % gun_rusvet, Color(0.95, 0.65, 0.25)])
	var y = 52.0 if gun_rusvet > 0 else 58.0
	var satir_adim = 22.0 if gun_rusvet > 0 else 24.0
	for s in satirlar:
		var a = _etiket(s[0], 13, Color(0.75, 0.74, 0.7), Vector2(36, y), Vector2(250, 20))
		a.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		var b = _etiket(s[1], 13, s[2], Vector2(280, y), Vector2(180, 20))
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		panel.add_child(a)
		panel.add_child(b)
		y += satir_adim
	var cizgi = ColorRect.new()
	cizgi.color = Color(0.5, 0.42, 0.3)
	cizgi.position = Vector2(34, y + 4)
	cizgi.size = Vector2(432, 2)
	panel.add_child(cizgi)
	panel.add_child(_etiket("BAKİYE: %d $   •   KANIT: %d/3" % [oyuncu_parasi, kanit_sayisi], 18, Color(0.96, 0.88, 0.45) if oyuncu_parasi > 0 else Color(0.95, 0.3, 0.25), Vector2(0, y + 10), Vector2(500, 26)))
	panel.add_child(_etiket("Direniş Etkisi: %d   |   Warden Graves Sadakati: %d" % [direnis_puani, sadakat_puani], 11, Color(0.68, 0.82, 0.94), Vector2(0, y + 36), Vector2(500, 18)))

	var birlesik_not: String = ""
	if gece_secim_ozeti != "":
		birlesik_not += "• Gece: " + gece_secim_ozeti + "\n"
	if gun_verisi["gun_sonu_notu"] != "":
		birlesik_not += gun_verisi["gun_sonu_notu"]
	if birlesik_not != "":
		panel.add_child(_etiket(birlesik_not, 11, Color(0.74, 0.72, 0.66), Vector2(24, y + 58), Vector2(452, 68)))

	var btn = Button.new()
	btn.text = "ERTESİ GÜN (%d. GÜN) ►" % (gun + 1) if gun < Hikaye.SON_GUN else "FİNAL SONUCU ►"
	btn.position = Vector2(140, 372)
	btn.size = Vector2(220, 38)
	btn.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color(0.98, 0.90, 0.62))
	_sik_buton_stili(btn, Color(0.88, 0.72, 0.36, 1.0))
	panel.add_child(btn)
	kapak.modulate.a = 0.0
	panel.scale = Vector2(0.9, 0.9)
	panel.pivot_offset = panel.size * 0.5
	var t = create_tween()
	t.tween_property(kapak, "modulate:a", 1.0, 0.3)
	t.parallel().tween_property(panel, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await btn.pressed
	ses_oynat(ses_dugme)
	var t2 = create_tween()
	t2.tween_property(kapak, "modulate:a", 0.0, 0.25)
	await t2.finished
	kapak.queue_free()


func son_ekrani_goster(anahtar: String) -> void:
	oyun_bitti = true
	var s = Hikaye.SONLAR[anahtar]
	var kat = ust_katman_al()
	var kapak = ColorRect.new()
	kapak.color = Color(0, 0, 0, 1)
	kapak.size = Vector2(1024.0, 571.0)
	kapak.mouse_filter = Control.MOUSE_FILTER_STOP
	kat.add_child(kapak)
	var renk = Color(0.42, 0.9, 0.55) if anahtar in ["devrim_kahramani", "muhbir"] else (Color(0.95, 0.78, 0.35) if anahtar in ["basmemur", "karaborsa_patronu"] else Color(0.85, 0.24, 0.18))
	var b = _etiket(s["baslik"], 32, renk, Vector2(0, 88), Vector2(1024, 46))
	var m = _etiket(s["metin"], 14, Color(0.86, 0.84, 0.76), Vector2(142, 156), Vector2(740, 210))
	var ozet = _etiket("Kasa: %d $  •  Kanıt: %d/3  •  Direniş: %d  •  Sadakat: %d" % [oyuncu_parasi, kanit_sayisi, direnis_puani, sadakat_puani], 12, Color(0.65, 0.65, 0.62), Vector2(0, 386), Vector2(1024, 24))
	var btn = Button.new()
	btn.text = "YENİDEN OYNA (5 SONU KEŞFET)"
	btn.position = Vector2(362, 434)
	btn.size = Vector2(300, 40)
	btn.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color(0.98, 0.90, 0.62))
	_sik_buton_stili(btn, renk)
	btn.pressed.connect(func(): get_tree().reload_current_scene())
	for n in [b, m, ozet, btn]:
		n.modulate.a = 0.0
		kapak.add_child(n)
	var t = create_tween()
	t.tween_property(b, "modulate:a", 1.0, 0.8)
	t.tween_property(m, "modulate:a", 1.0, 1.1)
	t.tween_property(ozet, "modulate:a", 1.0, 0.5)
	t.tween_property(btn, "modulate:a", 1.0, 0.5)


func _final_sonu_belirle() -> String:
	if oyuncu_parasi <= 0:
		return "isten_atildin"
	if toplam_rusvet >= 60 and oyuncu_parasi >= 100:
		return "karaborsa_patronu"
	if elias_karari == "ONAYLANDI":
		if kanit_sayisi >= 2 or direnis_puani >= 3:
			return "devrim_kahramani"
		return "muhbir"
	if sadakat_puani >= 2:
		return "basmemur"
	return "itaatkar"


func gun_sonu_akisi() -> void:
	if gun_sonu_basladi or oyun_bitti:
		return
	gun_sonu_basladi = true
	gorevli_teslimatta = true
	await get_tree().create_timer(0.4).timeout
	await gorevli_ziyaret("gun_sonu")
	var once = oyuncu_parasi
	var net = Hikaye.MAAS - Hikaye.KIRA_YEMEK
	para_guncelle(net)
	if aktif_gun < Hikaye.SON_GUN:
		await gece_olayi_goster(aktif_gun)
	await get_tree().create_timer(0.25).timeout
	await rapor_paneli_goster(aktif_gun, once, net)
	if oyuncu_parasi <= 0:
		son_ekrani_goster("isten_atildin")
		return
	var nakil: String = Hikaye.NAKIL.get(aktif_gun, "")
	if nakil != "":
		nakledilenler.append(nakil)
	if aktif_gun >= Hikaye.SON_GUN:
		son_ekrani_goster(_final_sonu_belirle())
		return
	gunu_baslat(aktif_gun + 1)


# ------------------------------------------------------------------------------------
# ATMOSFER: vinyet, tane, titreyen lambalar, toz ve ortam sesi
# ------------------------------------------------------------------------------------
const ATMOSFER_SHADER := """
shader_type canvas_item;
uniform float vignette = 0.24;
uniform float flicker = 0.0;
uniform float grain = 0.035;
void fragment() {
	vec2 uv = UV;
	float d = distance(uv, vec2(0.5, 0.48));
	float v = smoothstep(0.42, 1.02, d) * vignette;
	float n = fract(sin(dot(floor(uv * vec2(512.0, 286.0)) + floor(TIME * 24.0), vec2(12.9898, 78.233))) * 43758.5453);
	float a = v + flicker + (n - 0.5) * grain;
	COLOR = vec4(0.015, 0.02, 0.03, clamp(a, 0.0, 0.85));
}
"""
var atmosfer_mat: ShaderMaterial = null
var titreme_kalan: float = 0.0
var ortam_oynatici: AudioStreamPlayer = null


func atmosfer_kur() -> void:
	var kat = CanvasLayer.new()
	kat.name = "AtmosferKatmani"
	kat.layer = 60
	add_child(kat)
	var r = ColorRect.new()
	r.size = Vector2(1024.0, 571.0)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh = Shader.new()
	sh.code = ATMOSFER_SHADER
	atmosfer_mat = ShaderMaterial.new()
	atmosfer_mat.shader = sh
	r.material = atmosfer_mat
	kat.add_child(r)

	# Koridorda süzülen toz
	var toz = CPUParticles2D.new()
	toz.position = Vector2(172.0, 110.0)
	toz.amount = 26
	toz.lifetime = 7.0
	toz.preprocess = 7.0
	toz.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	toz.emission_rect_extents = Vector2(160.0, 95.0)
	toz.direction = Vector2(0.3, 1.0)
	toz.spread = 40.0
	toz.gravity = Vector2(0.0, 0.0)
	toz.initial_velocity_min = 2.0
	toz.initial_velocity_max = 7.0
	toz.scale_amount_min = 1.0
	toz.scale_amount_max = 1.6
	toz.color = Color(0.7, 0.75, 0.8, 0.22)
	toz.z_index = 2
	add_child(toz)

	ortam_oynatici = AudioStreamPlayer.new()
	var ort = load("res://assets/ses_ambiyans.wav") as AudioStreamWAV
	if ort:
		ort.loop_mode = AudioStreamWAV.LOOP_FORWARD
		ort.loop_begin = 0
		ort.loop_end = ort.data.size() / 2
		ortam_oynatici.stream = ort
		ortam_oynatici.volume_db = -9.0
		add_child(ortam_oynatici)
		ortam_oynatici.play()


func isik_titret(sure: float = 0.4) -> void:
	titreme_kalan = maxf(titreme_kalan, sure)
	ses_oynat(ses_buzz, -6.0)


func _atmosfer_guncelle(delta: float) -> void:
	if not atmosfer_mat:
		return
	var f = 0.0
	if titreme_kalan > 0.0:
		titreme_kalan -= delta
		f = 0.55 if int(Time.get_ticks_msec() / 45) % 3 != 0 else 0.1
	elif randf() < 0.0018:
		titreme_kalan = randf_range(0.08, 0.22)
	atmosfer_mat.set_shader_parameter("flicker", f)
	atmosfer_mat.set_shader_parameter("vignette", 0.38 + 0.03 * sin(Time.get_ticks_msec() * 0.0021))


# ------------------------------------------------------------------------------------
# GÖREVLİ (GARDİYAN) ZİYARETİ: sağdan gelir, replik atar, gider
# ------------------------------------------------------------------------------------
const GOREVLI_Y: float = 168.0
var gorevli_yuruyus_kare: int = 0
var konusma_atla: bool = false

func _g_doku(isim: String) -> Texture2D:
	return load("res://assets/%s.png" % isim) as Texture2D


func _balonlari_hazirla() -> void:
	if g_balon_panel: return
	g_balon_panel = _balon_yap(
		Color(0.11, 0.10, 0.10, 0.98),
		Color(0.88, 0.66, 0.28, 1.0),
		"★ SGT. DOBBS",
		Color(0.96, 0.78, 0.36, 1.0),
		true
	)
	p_balon_panel = _balon_yap(
		Color(0.10, 0.13, 0.18, 0.98),
		Color(0.48, 0.72, 0.92, 1.0),
		"▪ EVAN MERCER (#4471)",
		Color(0.62, 0.84, 0.98, 1.0),
		false
	)


func _balon_yap(arka: Color, cerceve: Color, baslik_metni: String, baslik_renk: Color, sag_kuyruk: bool) -> PanelContainer:
	var pc = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = arka
	sb.border_color = cerceve
	sb.set_border_width_all(2)
	sb.border_width_left = 5
	sb.set_corner_radius_all(4)
	sb.corner_detail = 1
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.72)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(3.0, 4.0)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 7
	sb.content_margin_bottom = 9
	pc.add_theme_stylebox_override("panel", sb)

	var font = preload("res://assets/retro_font.ttf")
	var kutu = VBoxContainer.new()
	kutu.name = "Kutu"
	kutu.add_theme_constant_override("separation", 4)
	kutu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(kutu)

	var baslik = Label.new()
	baslik.name = "Baslik"
	baslik.text = baslik_metni
	baslik.add_theme_font_override("font", font)
	baslik.add_theme_font_size_override("font_size", 11)
	baslik.add_theme_color_override("font_color", baslik_renk)
	baslik.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kutu.add_child(baslik)

	var cizgi = ColorRect.new()
	cizgi.custom_minimum_size = Vector2(272.0, 1.0)
	cizgi.color = Color(cerceve.r, cerceve.g, cerceve.b, 0.42)
	cizgi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kutu.add_child(cizgi)

	var l = Label.new()
	l.name = "Yazi"
	l.custom_minimum_size = Vector2(276.0, 0.0)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", Color(0.96, 0.93, 0.86))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kutu.add_child(l)

	# Konuşma balonu kuyruğu (ok ucu)
	var kuyruk_dis = Polygon2D.new()
	kuyruk_dis.name = "KuyrukDis"
	kuyruk_dis.color = cerceve
	var kuyruk_ic = Polygon2D.new()
	kuyruk_ic.name = "KuyrukIc"
	kuyruk_ic.color = arka
	if sag_kuyruk:
		kuyruk_dis.polygon = PackedVector2Array([Vector2(178, 0), Vector2(196, 0), Vector2(204, 13)])
		kuyruk_ic.polygon = PackedVector2Array([Vector2(181, -2), Vector2(193, -2), Vector2(200, 9)])
	else:
		kuyruk_dis.polygon = PackedVector2Array([Vector2(28, 0), Vector2(46, 0), Vector2(22, 13)])
		kuyruk_ic.polygon = PackedVector2Array([Vector2(31, -2), Vector2(43, -2), Vector2(26, 9)])
	pc.add_child(kuyruk_dis)
	pc.add_child(kuyruk_ic)

	pc.visible = false
	pc.z_index = 45
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pc)
	return pc


func konus(kim: String, metin: String, gorevli: Control = null) -> void:
	if gorevli_tumunu_atla:
		return
	_balonlari_hazirla()
	var pc: PanelContainer = g_balon_panel if kim == "g" else p_balon_panel
	var l = pc.find_child("Yazi", true, false) as Label
	l.text = metin
	l.visible_ratio = 0.0
	pc.visible = true
	pc.reset_size()
	var b_boy: Vector2 = Vector2(maxf(pc.size.x, pc.get_combined_minimum_size().x), maxf(pc.size.y, pc.get_combined_minimum_size().y))
	var k_dis = pc.get_node_or_null("KuyrukDis") as Polygon2D
	var k_ic = pc.get_node_or_null("KuyrukIc") as Polygon2D
	if k_dis and k_ic:
		k_dis.position = Vector2(0.0, b_boy.y - 1.0)
		k_ic.position = Vector2(0.0, b_boy.y - 1.0)
	if kim == "g" and gorevli:
		pc.position = Vector2(clampf(gorevli.position.x - 165.0, 320.0, 760.0), 82.0)
		ses_oynat(ses_konusma, -2.0)
	else:
		pc.position = Vector2(416.0, 286.0)
		ses_oynat(ses_konusma, -8.0)
	pc.pivot_offset = Vector2(b_boy.x * 0.5, b_boy.y)
	pc.scale = Vector2(0.88, 0.88)
	var sure = maxf(0.35, metin.length() * 0.018)
	konusma_atla = false
	var t = create_tween()
	t.tween_property(pc, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(l, "visible_ratio", 1.0, sure)
	var gecen: float = 0.0
	var toplam: float = sure + 0.55 + metin.length() * 0.008
	while gecen < toplam and not konusma_atla and not gorevli_tumunu_atla:
		await get_tree().create_timer(0.05).timeout
		gecen += 0.05
	t.kill()
	pc.scale = Vector2.ONE
	l.visible_ratio = 1.0
	pc.visible = false
	if not gorevli_tumunu_atla:
		await get_tree().create_timer(0.12).timeout


func _gorevli_yuru(g: TextureRect, hedef_x: float, sure: float, kagitli: bool, sagdan_sola: bool) -> void:
	if gorevli_tumunu_atla:
		g.position = Vector2(hedef_x, GOREVLI_Y)
		return
	g.flip_h = not sagdan_sola
	var t = create_tween()
	t.tween_property(g, "position:x", hedef_x, sure).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var adim: int = 0
	while t.is_running() and not gorevli_tumunu_atla:
		var kare: int = adim % 4
		g.texture = _g_doku(("g0_paper%d" if kagitli else "g0_walk%d") % kare)
		g.position.y = GOREVLI_Y - (3.0 if (adim % 2) == 1 else 0.0)
		if adim % 2 == 0:
			ses_oynat(ses_ayak, -6.0)
		await get_tree().create_timer(0.16).timeout
		adim += 1
	if gorevli_tumunu_atla and t.is_valid():
		t.kill()
		g.position.x = hedef_x
	g.position.y = GOREVLI_Y


func gorevli_ziyaret(mod: String) -> void:
	var gorevli = find_child("Gorevli") as TextureRect
	var gazete = find_child("CezaeviPostasi")
	if not gorevli or gorevli_tumunu_atla:
		if gazete and mod == "gazete":
			gazete.visible = true
			gazete.position = Vector2(282.0, 408.0)
			gazete.modulate.a = 1.0
		if gorevli: gorevli.visible = false
		gorevli_teslimatta = false
		gorevli_tumunu_atla = false
		hud_tam_guncelle()
		return
	var balon_eski = gorevli.get_node_or_null("GorevliBalonu")
	if balon_eski: balon_eski.visible = false
	gorevli_teslimatta = true
	hud_tam_guncelle()
	gorevli.visible = true
	gorevli.modulate.a = 1.0
	gorevli.rotation = 0.0
	gorevli.size = Vector2(72.0, 150.0)
	gorevli.pivot_offset = Vector2(36.0, 140.0)
	gorevli.position = Vector2(1070.0, GOREVLI_Y)
	var kagitli = (mod == "gazete")

	# Kapı gıcırdar, görevli sağdan girer
	ses_oynat(ses_gicirti, -4.0)
	await _gorevli_yuru(gorevli, 690.0, 1.15, kagitli, true)

	if mod == "gazete":
		gorevli.texture = _g_doku("g0_point")
		if not gorevli_tumunu_atla:
			await get_tree().create_timer(0.15).timeout
		# Gazeteyi masaya 'fırlatır'
		ses_oynat(ses_thud)
		ekran_salla(4.0)
		if gazete:
			gazete.visible = true
			gazete.position = Vector2(300.0, 380.0)
			gazete.modulate.a = 0.0
			var t_g = create_tween()
			t_g.parallel().tween_property(gazete, "position", Vector2(282.0, 408.0), 0.22).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			t_g.parallel().tween_property(gazete, "modulate:a", 1.0, 0.12)
		gorevli.texture = _g_doku("g0_idle")
	else:
		gorevli.texture = _g_doku("g0_idle")

	if not gorevli_tumunu_atla:
		await get_tree().create_timer(0.25).timeout
	var replikler: Array = gun_verisi["gardiyan"] if mod == "gazete" else []
	for r in replikler:
		if gorevli_tumunu_atla:
			break
		# Konuşurken hafifçe sallanır / el kol hareketi
		var sallan = create_tween().set_loops(3)
		sallan.tween_property(gorevli, "rotation", 0.035, 0.18)
		sallan.tween_property(gorevli, "rotation", -0.03, 0.18)
		if r[0] == "g":
			gorevli.texture = _g_doku("g0_point") if randf() < 0.5 else _g_doku("g0_idle")
		await konus(r[0], r[1], gorevli)
		sallan.kill()
		gorevli.rotation = 0.0
	if mod == "gun_sonu":
		for satir in gun_verisi["gun_sonu"]:
			if gorevli_tumunu_atla:
				break
			gorevli.texture = _g_doku("g0_point")
			await konus("g", satir, gorevli)

	gorevli.texture = _g_doku("g0_idle")
	if mod == "gazete" and not gorevli_tumunu_atla:
		await konus("g", gun_verisi["cikis"], gorevli)

	# Çıkarken takılıp sendeler (bazen)
	if not gorevli_tumunu_atla and randf() < 0.35:
		gorevli.texture = _g_doku("g0_walk1")
		await _gorevli_yuru(gorevli, gorevli.position.x + 40.0, 0.4, false, false)
		ses_oynat(ses_thud, -6.0)
		var tt = create_tween()
		tt.tween_property(gorevli, "rotation", 0.3, 0.1)
		tt.tween_property(gorevli, "rotation", -0.12, 0.12)
		tt.tween_property(gorevli, "rotation", 0.0, 0.14)
		await tt.finished
		await konus("g", "Bu zemin bana kasıtlı çarptı. Rapora yazıyorum.", gorevli)
	ses_oynat(ses_gicirti, -8.0)
	await _gorevli_yuru(gorevli, 1080.0, 0.95, false, false)
	if g_balon_panel: g_balon_panel.visible = false
	if p_balon_panel: p_balon_panel.visible = false
	gorevli.visible = false
	gorevli_teslimatta = false
	gorevli_tumunu_atla = false
	hud_tam_guncelle()


func kural_kitabi_sayfa_degistir(sayfa: int) -> void:
	var sayfa1 = find_child("Sayfa1Kurallar")
	var sayfa2 = find_child("Sayfa2NasilOynanir")
	var btn1 = find_child("KitapSayfa1Butonu") as Button
	var btn2 = find_child("KitapSayfa2Butonu") as Button
	ses_oynat(ses_kitap)

	if sayfa == 1:
		if sayfa1: sayfa1.visible = true
		if sayfa2: sayfa2.visible = false
		if btn1: btn1.add_theme_color_override("font_color", Color(0.72, 0.22, 0.18, 1.0))
		if btn2: btn2.add_theme_color_override("font_color", Color(0.45, 0.38, 0.32, 0.85))
	else:
		if sayfa1: sayfa1.visible = false
		if sayfa2: sayfa2.visible = true
		if btn1: btn1.add_theme_color_override("font_color", Color(0.45, 0.38, 0.32, 0.85))
		if btn2: btn2.add_theme_color_override("font_color", Color(0.72, 0.22, 0.18, 1.0))


# ------------------------------------------------------------------------------------
# KONSOL BUTONU, TESLİM BÖLMESİ DURUMU, RÜŞVET, İHTAR FİŞİ VE CAM DARBE EFEKTİ
# ------------------------------------------------------------------------------------
func _inceleme_butonu_susle() -> void:
	var btn = find_child("IncelemeButonu") as Button
	if not btn: return
	var sb_normal = StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.11, 0.12, 0.15, 0.96)
	sb_normal.border_color = Color(0.55, 0.44, 0.28, 1.0)
	sb_normal.set_border_width_all(2)
	sb_normal.set_corner_radius_all(3)

	var sb_hover = sb_normal.duplicate()
	sb_hover.bg_color = Color(0.16, 0.17, 0.21, 0.98)
	sb_hover.border_color = Color(0.85, 0.68, 0.36, 1.0)

	var sb_pressed = sb_normal.duplicate()
	sb_pressed.bg_color = Color(0.24, 0.12, 0.1, 0.98)
	sb_pressed.border_color = Color(0.95, 0.35, 0.22, 1.0)

	btn.add_theme_stylebox_override("normal", sb_normal)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb_pressed)


func _teslim_bolmesi_etiketi_olustur() -> void:
	var bolme = find_child("TeslimBolmesi") as Control
	if not bolme or teslim_durum_etiketi: return
	var l = Label.new()
	l.name = "TeslimDurumEtiketi"
	l.position = Vector2(12.0, 56.0)
	l.size = Vector2(236.0, 16.0)
	l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	l.add_theme_font_size_override("font_size", 9)
	l.add_theme_color_override("font_color", Color(0.68, 0.66, 0.6, 0.88))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.text = "TESLİM BÖLMESİ: BOŞ  •  [MÜHÜRLÜ FİŞİ BIRAK / TIKLA]"
	bolme.add_child(l)
	teslim_durum_etiketi = l


func _rusvet_karti_olustur() -> void:
	if rusvet_dugumu: return
	var pc = PanelContainer.new()
	pc.name = "RusvetTeklifi"
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.21, 0.14, 0.96)
	sb.border_color = Color(0.45, 0.72, 0.42, 1.0)
	sb.set_border_width_all(2)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	pc.add_theme_stylebox_override("panel", sb)
	pc.position = Vector2(682.0, 206.0)
	pc.z_index = 18
	pc.visible = false
	pc.mouse_filter = Control.MOUSE_FILTER_STOP
	pc.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pc.tooltip_text = "Gizli Rüşvet Teklifi: Fişi ONAYLARSANIZ +20$ cebinize girer (Ancak denetim cezası riski vardır!)"

	var l = Label.new()
	l.name = "RusvetYazi"
	l.text = "[$] GİZLİ RÜŞVET: +20$\n(Onaylarsan senin olur)"
	l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	l.add_theme_font_size_override("font_size", 9)
	l.add_theme_color_override("font_color", Color(0.78, 0.96, 0.72, 1.0))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(l)

	pc.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if gisede_mahkum_var and aktif_mahkum_indeksi >= 0 and aktif_mahkum_indeksi < mahkum_listesi.size():
				var m = mahkum_listesi[aktif_mahkum_indeksi]
				var r_metin = str(m.get("rusvet", "Şşşt... Bu 20$ aramızda kalsın memur, yeşil mührü vur geç."))
				ses_oynat(ses_para, -5.0)
				diyalog_balonlarini_goster("[GİZLİ RÜŞVET TEKLİFİ]", r_metin)
				pc.accept_event()
	)
	add_child(pc)
	rusvet_dugumu = pc


func _kontrol_rusvet_teklifi(m: Dictionary) -> void:
	_rusvet_gizle()
	var r_metin = str(m.get("rusvet", ""))
	if r_metin == "":
		return
	var blok = m["blok"]
	var kural = blok_kurallari.get(blok, {"ilac": false, "icecek": false, "yiyecek": false})
	var evrak_gecerli = (m["tarih"] == bugun_tarih) and (m["gardiyan"] in gecerli_gardiyanlar) and (m["izin"] != "Kısıtlı")
	var yasakli_talep = (m["ilac"] and not kural["ilac"]) or (m["yiyecek"] and not kural["yiyecek"]) or (m["icecek"] and not kural["icecek"])
	if (not evrak_gecerli or yasakli_talep) and rusvet_dugumu:
		rusvet_teklif_var = true
		rusvet_dugumu.visible = true
		rusvet_dugumu.position = Vector2(544.0, 118.0)
		rusvet_dugumu.modulate.a = 0.0
		var t = create_tween()
		t.tween_property(rusvet_dugumu, "position:y", 142.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(rusvet_dugumu, "modulate:a", 1.0, 0.2)


func _rusvet_gizle() -> void:
	rusvet_teklif_var = false
	if rusvet_dugumu:
		rusvet_dugumu.visible = false


func _siradaki_etiket_olustur() -> void:
	var kutu = find_child("SiradakiKutusu") as Control
	if not kutu or siradaki_etiket_lbl: return
	var l = Label.new()
	l.name = "SiradakiEtiket"
	l.position = Vector2(-12.0, 68.0)
	l.size = Vector2(108.0, 22.0)
	l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color(0.92, 0.82, 0.62, 0.95))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	l.add_theme_constant_override("outline_size", 3)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.text = "SIRADAKİ"
	kutu.add_child(l)
	siradaki_etiket_lbl = l


func _pusula_karti_olustur() -> void:
	if pusula_dugumu: return
	var pc = PanelContainer.new()
	pc.name = "GizliPusulaKarti"
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.24, 0.19, 0.11, 0.97)
	sb.border_color = Color(0.92, 0.74, 0.34, 1.0)
	sb.set_border_width_all(2)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	pc.add_theme_stylebox_override("panel", sb)
	pc.position = Vector2(682.0, 248.0)
	pc.z_index = 19
	pc.visible = false
	pc.mouse_filter = Control.MOUSE_FILTER_STOP
	pc.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pc.tooltip_text = "Mahkumun bıraktığı Gizli Pusulayı / Kanıtı okumak için tıklayın!"

	var l = Label.new()
	l.name = "PusulaYazi"
	l.text = "[?] GİZLİ PUSULA\n(Okumak için tıkla)"
	l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	l.add_theme_font_size_override("font_size", 9)
	l.add_theme_color_override("font_color", Color(0.98, 0.9, 0.62, 1.0))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(l)

	pc.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not aktif_pusula_verisi.is_empty() and not olay_paneli_acik:
				pusula_paneli_ac()
				pc.accept_event()
	)
	add_child(pc)
	pusula_dugumu = pc


func _kontrol_pusula(m: Dictionary) -> void:
	_pusula_gizle()
	if not m.has("pusula"):
		return
	aktif_pusula_verisi = m["pusula"]
	if pusula_dugumu:
		pusula_dugumu.visible = true
		pusula_dugumu.position = Vector2(544.0, 118.0)
		pusula_dugumu.modulate.a = 0.0
		var t = create_tween()
		t.tween_property(pusula_dugumu, "position:y", 142.0, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(pusula_dugumu, "modulate:a", 1.0, 0.2)


func _pusula_gizle() -> void:
	aktif_pusula_verisi = {}
	if pusula_dugumu:
		pusula_dugumu.visible = false


# ------------------------------------------------------------------------------------
# MAHKUMUN FİZİKSEL EL YAZISI KAĞIT NOTU (YARDIM İSTEĞİ / RÜŞVET / GİZLİ PUSULA)
# ------------------------------------------------------------------------------------
func _mahkum_notu_olustur() -> void:
	if mahkum_notu_dugumu: return
	var kagit = TextureRect.new()
	kagit.name = "MahkumNotu"
	kagit.texture = preload("res://assets/mahkum_notu.png")
	kagit.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	kagit.position = Vector2(288.0, 256.0)
	kagit.size = Vector2(244.0, 198.0)
	kagit.pivot_offset = Vector2(122.0, 99.0)
	kagit.z_as_relative = false
	kagit.z_index = 15
	kagit.visible = false
	kagit.mouse_filter = Control.MOUSE_FILTER_STOP
	kagit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	kagit.tooltip_text = "Mahkumun Mazgaldan Uzattığı El Yazısı Kağıt (Masada taşımak için sürükleyin)"

	var font = preload("res://assets/retro_font.ttf")

	var lbl_baslik = Label.new()
	lbl_baslik.name = "NotBaslik"
	lbl_baslik.position = Vector2(25.0, 8.0)
	lbl_baslik.size = Vector2(198.0, 17.0)
	lbl_baslik.add_theme_font_override("font", font)
	lbl_baslik.add_theme_font_size_override("font_size", 9)
	lbl_baslik.add_theme_color_override("font_color", Color(0.98, 0.90, 0.72, 1.0))
	lbl_baslik.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_baslik.clip_text = true
	lbl_baslik.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl_baslik.text = "EL YAZISI NOT"
	kagit.add_child(lbl_baslik)

	var lbl_yazi = Label.new()
	lbl_yazi.name = "NotYazi"
	lbl_yazi.position = Vector2(27.0, 30.0)
	lbl_yazi.size = Vector2(202.0, 122.0)
	lbl_yazi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_yazi.add_theme_font_override("font", font)
	lbl_yazi.add_theme_font_size_override("font_size", 10)
	lbl_yazi.add_theme_color_override("font_color", Color(0.14, 0.10, 0.08, 1.0))
	lbl_yazi.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_yazi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kagit.add_child(lbl_yazi)

	var lbl_alt = Label.new()
	lbl_alt.name = "NotAlt"
	lbl_alt.position = Vector2(25.0, 156.0)
	lbl_alt.size = Vector2(202.0, 28.0)
	lbl_alt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_alt.add_theme_font_override("font", font)
	lbl_alt.add_theme_font_size_override("font_size", 9)
	lbl_alt.add_theme_color_override("font_color", Color(0.48, 0.14, 0.12, 1.0))
	lbl_alt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_alt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_alt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kagit.add_child(lbl_alt)

	var btn_d = Button.new()
	btn_d.name = "NotBtnDirenis"
	btn_d.position = Vector2(25.0, 158.0)
	btn_d.size = Vector2(98.0, 26.0)
	btn_d.add_theme_font_override("font", font)
	btn_d.add_theme_font_size_override("font_size", 8)
	btn_d.add_theme_color_override("font_color", Color(0.58, 0.98, 0.68, 1.0))
	_sik_buton_stili(btn_d, Color(0.36, 0.84, 0.48, 1.0))
	btn_d.text = "SAKLA (KANIT+1)"
	btn_d.visible = false
	btn_d.pressed.connect(func():
		if _pusula_secildi or aktif_pusula_verisi.is_empty(): return
		_pusula_secildi = true
		ses_oynat(ses_dugme)
		kanit_sayisi = clampi(kanit_sayisi + 1, 0, 5)
		direnis_puani += 1
		btn_d.visible = false
		var bs = kagit.get_node_or_null("NotBtnSadakat") as Control
		if bs: bs.visible = false
		lbl_alt.visible = true
		lbl_alt.add_theme_color_override("font_color", Color(0.12, 0.42, 0.18, 1.0))
		lbl_alt.text = "✓ KANIT CEBE SAKLANDI (KANIT: %d/3)" % kanit_sayisi
		hud_tam_guncelle()
		bildirim_goster("GİZLİ KANIT SAKLANDI! (Kanıt: %d/3 • Direniş +1)" % kanit_sayisi, Color(0.4, 0.95, 0.55))
	)
	kagit.add_child(btn_d)

	var btn_s = Button.new()
	btn_s.name = "NotBtnSadakat"
	btn_s.position = Vector2(127.0, 158.0)
	btn_s.size = Vector2(98.0, 26.0)
	btn_s.add_theme_font_override("font", font)
	btn_s.add_theme_font_size_override("font_size", 8)
	btn_s.add_theme_color_override("font_color", Color(0.98, 0.84, 0.48, 1.0))
	_sik_buton_stili(btn_s, Color(0.88, 0.64, 0.28, 1.0))
	btn_s.text = "İHBAR ET (+15$)"
	btn_s.visible = false
	btn_s.pressed.connect(func():
		if _pusula_secildi or aktif_pusula_verisi.is_empty(): return
		_pusula_secildi = true
		var odul: int = int(aktif_pusula_verisi.get("odul_sadakat", 15))
		ses_oynat(ses_para)
		para_guncelle(odul)
		gun_kazanc += odul
		sadakat_puani += 1
		btn_d.visible = false
		btn_s.visible = false
		lbl_alt.visible = true
		lbl_alt.add_theme_color_override("font_color", Color(0.54, 0.28, 0.08, 1.0))
		lbl_alt.text = "✓ GRAVES'E İHBAR EDİLDİ (+%d$)" % odul
		hud_tam_guncelle()
		bildirim_goster("PUSULA İHBAR EDİLDİ! Warden Graves +%d$ sadakat primi ödedi." % odul, Color(0.96, 0.84, 0.4))
	)
	kagit.add_child(btn_s)

	kagit.gui_input.connect(func(event: InputEvent):
		if inceleme_modu_aktif:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				inceleme_ogesi_secildi("mahkum_replik", "Mahkumun Uzattığı El Yazısı Kağıt Not", kagit)
				kagit.accept_event()
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_not_surukleniyor = true
				_not_drag_offset = get_global_mouse_position() - kagit.global_position
				kagit.move_to_front()
				kagit.accept_event()
			else:
				_not_surukleniyor = false
				kagit.accept_event()
		elif event is InputEventMouseMotion and _not_surukleniyor:
			var yp = get_global_mouse_position() - _not_drag_offset
			yp.x = clampf(yp.x, 12.0, 1024.0 - kagit.size.x - 12.0)
			yp.y = clampf(yp.y, 120.0, 571.0 - 50.0)
			kagit.global_position = yp
			kagit.accept_event()
	)
	add_child(kagit)
	mahkum_notu_dugumu = kagit


func _kontrol_mahkum_notu(m: Dictionary) -> void:
	_rusvet_gizle()
	_pusula_gizle()
	_mahkum_notu_gizle()
	if not mahkum_notu_dugumu: return

	var lbl_baslik = mahkum_notu_dugumu.get_node_or_null("NotBaslik") as Label
	var lbl_yazi = mahkum_notu_dugumu.get_node_or_null("NotYazi") as Label
	var lbl_alt = mahkum_notu_dugumu.get_node_or_null("NotAlt") as Label
	var btn_d = mahkum_notu_dugumu.get_node_or_null("NotBtnDirenis") as Button
	var btn_s = mahkum_notu_dugumu.get_node_or_null("NotBtnSadakat") as Button

	var not_var: bool = false
	var parali: bool = false

	if m.has("pusula"):
		not_var = true
		aktif_pusula_verisi = m["pusula"]
		_pusula_secildi = false
		var p = m["pusula"]
		if lbl_baslik:
			lbl_baslik.size.x = 198.0
			lbl_baslik.text = str(p.get("baslik", "GİZLİ PUSULA"))
		if lbl_yazi:
			lbl_yazi.text = str(p.get("metin", ""))
		if lbl_alt:
			lbl_alt.visible = false
		if btn_d:
			btn_d.visible = true
			btn_d.text = str(p.get("secenek_direnis", "SAKLA (KANIT+1)"))
		if btn_s:
			btn_s.visible = true
			var odul: int = int(p.get("odul_sadakat", 15))
			btn_s.text = str(p.get("secenek_sadakat", "İHBAR ET (+%d$)" % odul))
	elif m.has("kagit_not"):
		not_var = true
		var kn: Dictionary = m["kagit_not"]
		parali = bool(kn.get("parali", false))
		rusvet_teklif_var = parali
		if lbl_baslik:
			lbl_baslik.size.x = 148.0 if parali else 198.0
			lbl_baslik.text = str(kn.get("baslik", "EL YAZISI NOT • " + str(m.get("ad", "")).to_upper()))
		if lbl_yazi:
			lbl_yazi.text = str(kn.get("metin", ""))
		if btn_d: btn_d.visible = false
		if btn_s: btn_s.visible = false
		if lbl_alt:
			lbl_alt.visible = true
			if parali:
				lbl_alt.add_theme_color_override("font_color", Color(0.10, 0.38, 0.14, 1.0))
				lbl_alt.text = "📎 EKTE 20$ RÜŞVET: ONAYLARSAN SENİN OLUR"
			else:
				lbl_alt.add_theme_color_override("font_color", Color(0.50, 0.14, 0.12, 1.0))
				lbl_alt.text = "✎ GİZLİ YARDIM KAĞIDI — SESSİZCE OKUYUN"
	else:
		# Eğer senaryo dışı/rastgele mahkumda evrak hatası veya yasaklı talep varsa otomatik kağıt not uzatsın
		var blok = m["blok"]
		var kural = blok_kurallari.get(blok, {"ilac": false, "icecek": false, "yiyecek": false})
		var evrak_gecerli = (m["tarih"] == bugun_tarih) and (m["gardiyan"] in gecerli_gardiyanlar) and (m["izin"] != "Kısıtlı")
		var yasakli_talep = (m["ilac"] and not kural["ilac"]) or (m["yiyecek"] and not kural["yiyecek"]) or (m["icecek"] and not kural["icecek"])
		if not evrak_gecerli or yasakli_talep:
			not_var = true
			var r_metin = str(m.get("rusvet", ""))
			parali = (r_metin != "")
			rusvet_teklif_var = parali
			if lbl_baslik:
				lbl_baslik.size.x = 148.0 if parali else 198.0
				lbl_baslik.text = "EL YAZISI NOT • " + str(m.get("ad", "")).to_upper()
			if lbl_yazi:
				lbl_yazi.text = r_metin if parali else "\"Memur bey, gardiyanlar duyacak diye sesli söyleyemedim; evrakımda ufak bir eksik var ama çok zor durumdayım, bir kerelik idare eder misin?\""
			if btn_d: btn_d.visible = false
			if btn_s: btn_s.visible = false
			if lbl_alt:
				lbl_alt.visible = true
				lbl_alt.add_theme_color_override("font_color", Color(0.10, 0.38, 0.14, 1.0) if parali else Color(0.50, 0.14, 0.12, 1.0))
				lbl_alt.text = "📎 EKTE 20$ RÜŞVET: ONAYLARSAN SENİN OLUR" if parali else "✎ GİZLİ YARDIM KAĞIDI — SESSİZCE OKUYUN"

	if not not_var:
		return

	mahkum_notu_dugumu.texture = preload("res://assets/mahkum_notu_parali.png") if parali else preload("res://assets/mahkum_notu.png")
	mahkum_notu_dugumu.visible = true
	mahkum_notu_dugumu.modulate.a = 0.0
	mahkum_notu_dugumu.scale = Vector2(0.36, 0.36)
	mahkum_notu_dugumu.rotation = 0.09
	mahkum_notu_dugumu.position = Vector2(442.0, 148.0)
	ses_oynat(ses_kitap, -2.0)

	var t = create_tween()
	t.parallel().tween_property(mahkum_notu_dugumu, "position", Vector2(288.0, 256.0), 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(mahkum_notu_dugumu, "scale", Vector2(1.0, 1.0), 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(mahkum_notu_dugumu, "rotation", -0.025, 0.34)
	t.parallel().tween_property(mahkum_notu_dugumu, "modulate:a", 1.0, 0.18)


func _mahkum_notu_vurgula() -> void:
	if not mahkum_notu_dugumu or not mahkum_notu_dugumu.visible:
		return
	mahkum_notu_dugumu.move_to_front()
	ses_oynat(ses_kitap, -3.0)
	var t = create_tween()
	t.tween_property(mahkum_notu_dugumu, "scale", Vector2(1.08, 1.08), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(mahkum_notu_dugumu, "rotation", 0.03, 0.10)
	t.tween_property(mahkum_notu_dugumu, "scale", Vector2(1.0, 1.0), 0.14)
	t.parallel().tween_property(mahkum_notu_dugumu, "rotation", -0.025, 0.14)


func _mahkum_notu_gizle() -> void:
	_not_surukleniyor = false
	_pusula_secildi = false
	if mahkum_notu_dugumu:
		mahkum_notu_dugumu.visible = false


func _mahkum_notu_kapat_animasyonu() -> void:
	_not_surukleniyor = false
	if not mahkum_notu_dugumu or not mahkum_notu_dugumu.visible:
		return
	var t = create_tween()
	t.parallel().tween_property(mahkum_notu_dugumu, "scale", Vector2(0.32, 0.32), 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(mahkum_notu_dugumu, "position:y", 155.0, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(mahkum_notu_dugumu, "modulate:a", 0.0, 0.26)
	t.tween_callback(func():
		if mahkum_notu_dugumu:
			mahkum_notu_dugumu.visible = false
	)


func pusula_paneli_ac() -> void:
	if aktif_pusula_verisi.is_empty() or olay_paneli_acik:
		return
	olay_paneli_acik = true
	var p = aktif_pusula_verisi
	ses_oynat(ses_kitap)

	var kat = ust_katman_al()
	var kapak = ColorRect.new()
	kapak.color = Color(0.02, 0.02, 0.03, 0.84)
	kapak.size = Vector2(1024.0, 571.0)
	kapak.mouse_filter = Control.MOUSE_FILTER_STOP
	kat.add_child(kapak)

	var panel = Panel.new()
	panel.position = Vector2(222, 100)
	panel.size = Vector2(580, 360)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.12, 0.09, 0.98)
	sb.border_color = Color(0.88, 0.72, 0.36, 1.0)
	sb.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", sb)
	kapak.add_child(panel)

	panel.add_child(_etiket(str(p.get("baslik", "GİZLİ PUSULA")), 16, Color(0.98, 0.84, 0.42), Vector2(20, 16), Vector2(540, 28)))
	panel.add_child(_etiket(str(p.get("metin", "")), 13, Color(0.94, 0.9, 0.8), Vector2(30, 56), Vector2(520, 140)))

	var font = preload("res://assets/retro_font.ttf")
	var b1 = Button.new()
	b1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b1.position = Vector2(40, 218)
	b1.custom_minimum_size = Vector2(500, 42)
	b1.size = Vector2(500, 42)
	b1.add_theme_font_override("font", font)
	b1.add_theme_font_size_override("font_size", 11)
	b1.add_theme_color_override("font_color", Color(0.55, 0.95, 0.65))
	_sik_buton_stili(b1, Color(0.42, 0.88, 0.55, 1.0))
	b1.text = "► " + str(p.get("secenek_direnis", "Pusulayı Sakla (Kanıt +1, Direniş +1)"))
	panel.add_child(b1)

	var b2 = Button.new()
	b2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b2.position = Vector2(40, 272)
	b2.custom_minimum_size = Vector2(500, 42)
	b2.size = Vector2(500, 42)
	b2.add_theme_font_override("font", font)
	b2.add_theme_font_size_override("font_size", 11)
	b2.add_theme_color_override("font_color", Color(0.98, 0.78, 0.45))
	_sik_buton_stili(b2, Color(0.92, 0.68, 0.32, 1.0))
	b2.text = "► " + str(p.get("secenek_sadakat", "Warden Graves'e İhbar Et (+15$, Sadakat +1)"))
	panel.add_child(b2)

	var bitti := {"ok": false}
	b1.pressed.connect(func():
		if bitti["ok"]: return
		bitti["ok"] = true
		ses_oynat(ses_dugme)
		kanit_sayisi = clampi(kanit_sayisi + 1, 0, 5)
		direnis_puani += 1
		_pusula_gizle()
		hud_tam_guncelle()
		bildirim_goster("GİZLİ KANIT SAKLANDI! (Kanıt: %d/3 • Direniş +1)" % kanit_sayisi, Color(0.4, 0.95, 0.55))
	)
	b2.pressed.connect(func():
		if bitti["ok"]: return
		bitti["ok"] = true
		var odul: int = int(p.get("odul_sadakat", 15))
		ses_oynat(ses_para)
		para_guncelle(odul)
		gun_kazanc += odul
		sadakat_puani += 1
		_pusula_gizle()
		hud_tam_guncelle()
		bildirim_goster("PUSULA İHBAR EDİLDİ! Warden Graves +%d$ sadakat primi ödedi." % odul, Color(0.96, 0.84, 0.4))
	)

	while not bitti["ok"]:
		await get_tree().create_timer(0.05).timeout

	kapak.queue_free()
	olay_paneli_acik = false


func _ihtar_karti_olustur() -> void:
	if ihtar_dugumu: return
	var slip = TextureRect.new()
	slip.name = "DisiplinIhtarnamesi"
	slip.texture = preload("res://assets/ihtar_fisi.png")
	slip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	slip.position = Vector2(276.0, 580.0)
	slip.size = Vector2(310.0, 136.0)
	slip.z_as_relative = false
	slip.z_index = 38
	slip.visible = false
	slip.mouse_filter = Control.MOUSE_FILTER_STOP
	slip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slip.tooltip_text = "Bakanlık Denetim İhtarnamesi (Taşımak için sürükleyin, kapatmak için [X] tıklayın)"

	var font = preload("res://assets/retro_font.ttf")

	var lbl_baslik = Label.new()
	lbl_baslik.name = "IhtarBaslik"
	lbl_baslik.position = Vector2(24.0, 7.0)
	lbl_baslik.size = Vector2(236.0, 20.0)
	lbl_baslik.add_theme_font_override("font", font)
	lbl_baslik.add_theme_font_size_override("font_size", 11)
	lbl_baslik.add_theme_color_override("font_color", Color(0.98, 0.92, 0.80, 1.0))
	lbl_baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_baslik.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_baslik.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl_baslik.text = "IRONHOLD DENETİM İHTARNAMESİ"
	slip.add_child(lbl_baslik)

	var btn_kapat = Button.new()
	btn_kapat.name = "IhtarKapat"
	btn_kapat.focus_mode = Control.FOCUS_NONE
	btn_kapat.flat = true
	btn_kapat.position = Vector2(256.0, 6.0)
	btn_kapat.size = Vector2(26.0, 22.0)
	btn_kapat.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_kapat.add_theme_font_override("font", font)
	btn_kapat.add_theme_font_size_override("font_size", 12)
	btn_kapat.add_theme_color_override("font_color", Color(0.98, 0.88, 0.78, 1.0))
	btn_kapat.text = "[X]"
	btn_kapat.pressed.connect(func():
		ses_oynat(ses_dugme)
		slip.visible = false
	)
	slip.add_child(btn_kapat)

	var l = Label.new()
	l.name = "IhtarYazi"
	l.position = Vector2(26.0, 32.0)
	l.size = Vector2(254.0, 74.0)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Color(0.16, 0.08, 0.08, 1.0))
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slip.add_child(l)

	var lbl_alt = Label.new()
	lbl_alt.name = "IhtarAlt"
	lbl_alt.position = Vector2(24.0, 111.0)
	lbl_alt.size = Vector2(258.0, 17.0)
	lbl_alt.add_theme_font_override("font", font)
	lbl_alt.add_theme_font_size_override("font_size", 11)
	lbl_alt.add_theme_color_override("font_color", Color(0.98, 0.90, 0.72, 1.0))
	lbl_alt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_alt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_alt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slip.add_child(lbl_alt)

	slip.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_ihtar_surukleniyor = true
				_ihtar_drag_offset = get_global_mouse_position() - slip.global_position
				slip.move_to_front()
				slip.accept_event()
			else:
				_ihtar_surukleniyor = false
				slip.accept_event()
		elif event is InputEventMouseMotion and _ihtar_surukleniyor:
			var yp = get_global_mouse_position() - _ihtar_drag_offset
			yp.x = clampf(yp.x, 12.0, 1024.0 - slip.size.x - 12.0)
			yp.y = clampf(yp.y, 130.0, 571.0 - 40.0)
			slip.global_position = yp
			slip.accept_event()
	)
	add_child(slip)
	ihtar_dugumu = slip


func ihtar_fisi_bas(sebep: String, ceza: int) -> void:
	if not ihtar_dugumu: return
	var baslik = ihtar_dugumu.get_node_or_null("IhtarBaslik") as Label
	if baslik:
		baslik.text = "PROTOKOL İHLALİ  •  İHTAR #%d" % uyari_sayisi
	var l = ihtar_dugumu.get_node_or_null("IhtarYazi") as Label
	if l:
		l.text = sebep
	var alt = ihtar_dugumu.get_node_or_null("IhtarAlt") as Label
	if alt:
		alt.text = "CEZA KESİNTİSİ: %d $  •  WARDEN GRAVES" % ceza

	if _ihtar_tween and _ihtar_tween.is_valid():
		_ihtar_tween.kill()

	# Papers, Please tarzı ekranın altından kademeli nokta vuruşlu yazıcı çıkış animasyonu
	ihtar_dugumu.visible = true
	ihtar_dugumu.move_to_front()
	ihtar_dugumu.modulate.a = 1.0
	ihtar_dugumu.position = Vector2(276.0, 576.0)
	ses_oynat(ses_yazici, 1.5)

	_ihtar_tween = create_tween()
	var kademeler = [526.0, 476.0, 426.0, 376.0]
	for hedef_y in kademeler:
		_ihtar_tween.tween_property(ihtar_dugumu, "position:y", hedef_y, 0.11).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_ihtar_tween.tween_interval(0.07)
		_ihtar_tween.tween_callback(func(): ses_oynat(ses_yazici, -2.0))


func cam_darbe_efekti() -> void:
	ses_oynat(ses_thud, 2.0)
	ekran_salla(6.5)
	isik_titret(0.45)
	var pencere = find_child("MahkumPenceresi") as Control
	if not pencere: return
	var darbe = pencere.get_node_or_null("CamCatlak") as Control
	if not darbe:
		darbe = Control.new()
		darbe.name = "CamCatlak"
		darbe.position = Vector2(120.0, 82.0)
		darbe.size = Vector2(1.0, 1.0)
		darbe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var acilar = [-2.6, -1.8, -1.1, -0.4, 0.3, 1.0, 1.9, 2.5]
		for a in acilar:
			var cizgi = ColorRect.new()
			cizgi.color = Color(0.85, 0.9, 0.96, 0.55)
			cizgi.size = Vector2(randf_range(28.0, 56.0), 1.5)
			cizgi.rotation = a
			cizgi.mouse_filter = Control.MOUSE_FILTER_IGNORE
			darbe.add_child(cizgi)
		pencere.add_child(darbe)
		var kepenk = pencere.get_node_or_null("Kepenk")
		if kepenk: kepenk.move_to_front()
	darbe.visible = true
	darbe.modulate = Color(1.0, 0.65, 0.6, 0.95)
	var t = create_tween()
	t.tween_property(darbe, "modulate", Color(0.85, 0.9, 0.95, 0.7), 0.2)
	t.tween_interval(1.2)
	t.tween_property(darbe, "modulate:a", 0.0, 0.6)
	t.tween_callback(func():
		if darbe: darbe.visible = false
	)


# ------------------------------------------------------------------------------------
# KAYIT SİSTEMİ, KONTROL MENÜSÜ VE GÜN SEÇİM EKRANI
# ------------------------------------------------------------------------------------
func oyunu_kaydet() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("ironhold", "aktif_gun", aktif_gun)
	cfg.set_value("ironhold", "oyuncu_parasi", oyuncu_parasi)
	cfg.set_value("ironhold", "kanit_sayisi", kanit_sayisi)
	cfg.set_value("ironhold", "direnis_puani", direnis_puani)
	cfg.set_value("ironhold", "sadakat_puani", sadakat_puani)
	cfg.set_value("ironhold", "toplam_rusvet", toplam_rusvet)
	cfg.set_value("ironhold", "uyari_sayisi", uyari_sayisi)
	cfg.set_value("ironhold", "nakledilenler", nakledilenler)
	cfg.save(KAYIT_DOSYASI)


func kayitli_gun_oku() -> int:
	var cfg = ConfigFile.new()
	if cfg.load(KAYIT_DOSYASI) != OK:
		return 0
	return int(cfg.get_value("ironhold", "aktif_gun", 1))


func oyunu_yukle() -> bool:
	var cfg = ConfigFile.new()
	if cfg.load(KAYIT_DOSYASI) != OK:
		return false
	aktif_gun = clampi(int(cfg.get_value("ironhold", "aktif_gun", 1)), 1, Hikaye.SON_GUN)
	oyuncu_parasi = maxi(15, int(cfg.get_value("ironhold", "oyuncu_parasi", 60)))
	kanit_sayisi = int(cfg.get_value("ironhold", "kanit_sayisi", 0))
	direnis_puani = int(cfg.get_value("ironhold", "direnis_puani", 0))
	sadakat_puani = int(cfg.get_value("ironhold", "sadakat_puani", 0))
	toplam_rusvet = int(cfg.get_value("ironhold", "toplam_rusvet", 0))
	uyari_sayisi = int(cfg.get_value("ironhold", "uyari_sayisi", 0))
	nakledilenler = cfg.get_value("ironhold", "nakledilenler", [])
	return true


func gun_secerek_baslat(hedef_gun: int, sifirla: bool = false) -> void:
	if gorevli_teslimatta:
		gorevli_tumunu_atla = true
		konusma_atla = true
		await get_tree().create_timer(0.15).timeout
	if sifirla:
		oyuncu_parasi = 60
		kanit_sayisi = 0
		direnis_puani = 0
		sadakat_puani = 0
		toplam_rusvet = 0
		uyari_sayisi = 0
		nakledilenler.clear()
		elias_karari = ""
	var fis = find_child("TalepFisi")
	if fis:
		fis.visible = false
	tum_esyalari_rafa_dondur()
	gunu_baslat(clampi(hedef_gun, 1, Hikaye.SON_GUN))


func ana_menu_goster() -> void:
	if ana_menu_acik:
		return
	ana_menu_acik = true
	ses_oynat(ses_dugme)

	var kat = ust_katman_al()
	var kapak = ColorRect.new()
	kapak.name = "AnaMenuKapak"
	kapak.color = Color(0.01, 0.02, 0.03, 0.86)
	kapak.size = Vector2(1024.0, 571.0)
	kapak.mouse_filter = Control.MOUSE_FILTER_STOP
	kat.add_child(kapak)

	var panel = Panel.new()
	panel.position = Vector2(192, 48)
	panel.size = Vector2(640, 474)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.10, 0.12, 0.99)
	sb.border_color = Color(0.84, 0.66, 0.34, 1.0)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(4)
	sb.corner_detail = 1
	sb.shadow_color = Color(0, 0, 0, 0.78)
	sb.shadow_size = 10
	panel.add_theme_stylebox_override("panel", sb)
	kapak.add_child(panel)

	var font = preload("res://assets/retro_font.ttf")
	panel.add_child(_etiket("IRONHOLD: CEZAEVİ KANTİNİ (1984)", 22, Color(0.96, 0.84, 0.44), Vector2(20, 16), Vector2(600, 30)))
	panel.add_child(_etiket("Memur Evan Mercer (#4471)  •  Mevcut Vardiya: %d. Gün  •  Kasa: %d$" % [aktif_gun, oyuncu_parasi], 11, Color(0.76, 0.84, 0.92), Vector2(20, 46), Vector2(600, 20)))

	var ayirici = ColorRect.new()
	ayirici.color = Color(0.84, 0.66, 0.34, 0.45)
	ayirici.position = Vector2(32, 70)
	ayirici.size = Vector2(576, 2)
	panel.add_child(ayirici)

	var secim := {"islem": "", "gun": 1}

	var btn_devam = Button.new()
	btn_devam.position = Vector2(44, 84)
	btn_devam.size = Vector2(552, 38)
	btn_devam.add_theme_font_override("font", font)
	btn_devam.add_theme_font_size_override("font_size", 12)
	btn_devam.add_theme_color_override("font_color", Color(0.56, 0.98, 0.68))
	_sik_buton_stili(btn_devam, Color(0.42, 0.88, 0.55, 1.0))
	btn_devam.text = "► MEVCUT VARDİYAYA DÖN (%d. GÜN DEVAM ET)" % aktif_gun
	btn_devam.pressed.connect(func():
		secim["islem"] = "devam"
	)
	panel.add_child(btn_devam)

	var btn_yeni = Button.new()
	btn_yeni.position = Vector2(44, 130)
	btn_yeni.size = Vector2(268, 36)
	btn_yeni.add_theme_font_override("font", font)
	btn_yeni.add_theme_font_size_override("font_size", 11)
	btn_yeni.add_theme_color_override("font_color", Color(0.98, 0.86, 0.52))
	_sik_buton_stili(btn_yeni, Color(0.90, 0.66, 0.28, 1.0))
	btn_yeni.text = "► YENİ OYUN (1. GÜNDEN)"
	btn_yeni.pressed.connect(func():
		secim["islem"] = "yeni"
	)
	panel.add_child(btn_yeni)

	var btn_tekrar = Button.new()
	btn_tekrar.position = Vector2(328, 130)
	btn_tekrar.size = Vector2(268, 36)
	btn_tekrar.add_theme_font_override("font", font)
	btn_tekrar.add_theme_font_size_override("font_size", 11)
	btn_tekrar.add_theme_color_override("font_color", Color(0.88, 0.86, 0.96))
	_sik_buton_stili(btn_tekrar, Color(0.56, 0.68, 0.92, 1.0))
	btn_tekrar.text = "► BU GÜNÜ BAŞTAN AL (%d. GÜN)" % aktif_gun
	btn_tekrar.pressed.connect(func():
		secim["islem"] = "gun_sec"
		secim["gun"] = aktif_gun
	)
	panel.add_child(btn_tekrar)

	panel.add_child(_etiket("DOĞRUDAN GÜN / BÖLÜM SEÇİMİ:", 11, Color(0.92, 0.80, 0.54), Vector2(44, 178), Vector2(552, 18)))

	var gun_etiketleri = [
		"1. GÜN\nYeni Memur",
		"2. GÜN\nSahte Tarih",
		"3. GÜN\nVoss & İsyan",
		"4. GÜN\nMüfettiş Vance",
		"5. GÜN\nBüyük Final"
	]
	for i in range(5):
		var g_no: int = i + 1
		var gb = Button.new()
		gb.position = Vector2(44 + i * 112, 200)
		gb.size = Vector2(104, 46)
		gb.add_theme_font_override("font", font)
		gb.add_theme_font_size_override("font_size", 9)
		gb.add_theme_color_override("font_color", Color(0.98, 0.92, 0.76))
		_sik_buton_stili(gb, Color(0.88, 0.42, 0.28, 1.0) if g_no == 5 else Color(0.72, 0.58, 0.34, 1.0))
		gb.text = gun_etiketleri[i]
		gb.pressed.connect(func():
			secim["islem"] = "gun_sec"
			secim["gun"] = g_no
		)
		panel.add_child(gb)

	var rehber_kutu = ColorRect.new()
	rehber_kutu.color = Color(0.06, 0.07, 0.09, 0.95)
	rehber_kutu.position = Vector2(44, 260)
	rehber_kutu.size = Vector2(552, 194)
	panel.add_child(rehber_kutu)

	var rehber_cerceve = ReferenceRect.new()
	rehber_cerceve.editor_only = false
	rehber_cerceve.border_color = Color(0.42, 0.38, 0.30, 0.85)
	rehber_cerceve.border_width = 1.5
	rehber_cerceve.size = rehber_kutu.size
	rehber_kutu.add_child(rehber_cerceve)

	var rehber_metin := (
		"KISAYOLLAR VE OYNANIŞ REHBERİ:\n" +
		"• [N / Enter] veya Kırmızı Düğme : Sıradaki mahkumu gişeye çağırır (Diyalogda geçer)\n" +
		"• [Space / Tab] veya [ ! İNCELE ] : Eşleştirme Modu (2 öğeye tıklayıp çelişki bul)\n" +
		"• [Q] veya [ ? SORGULA ] : Gişedeki mahkuma evrakı hakkında soru sorar\n" +
		"• [1] ONAY Mührü  |  [2] RET Mührü  (veya çekmeceden mührü fişin üstüne sürükle)\n" +
		"• [T] veya Teslim Bölmesi : Seçilen eşyaları ve mühürlü fişi mahkuma teslim eder\n" +
		"• [B / K] Kural Kitabı   |   [G] Cezaevi Postası (Gazete)   |   [D] Mühür Çekmecesi\n" +
		"• Gizli Pusulalar ve Vardiya Olayları : 5 farklı oyun sonunu (Direniş / Sadakat / Servet) belirler!"
	)
	var lbl_rehber = _etiket(rehber_metin, 10, Color(0.86, 0.84, 0.76), Vector2(14, 10), Vector2(524, 174))
	lbl_rehber.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	rehber_kutu.add_child(lbl_rehber)

	panel.scale = Vector2(0.92, 0.92)
	panel.pivot_offset = panel.size * 0.5
	var t = create_tween()
	t.tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	while secim["islem"] == "":
		await get_tree().create_timer(0.05).timeout

	ses_oynat(ses_dugme)
	kapak.queue_free()
	ana_menu_acik = false

	match secim["islem"]:
		"yeni":
			await gun_secerek_baslat(1, true)
		"gun_sec":
			await gun_secerek_baslat(int(secim["gun"]), false)
		"devam":
			pass
