func gunu_baslat(gun_no: int) -> void:
	aktif_gun = gun_no
	gun_verisi = Hikaye.GUNLER[gun_no]
	bugun_tarih = Hikaye.tarih_str(gun_no)
	gecerli_gardiyanlar = gun_verisi["gecerli_gardiyanlar"]
	blok_kurallari = gun_verisi["kurallar"]
	gun_dogru = 0
	gun_hata = 0
	gun_kazanc = 0
	mahkum_listesi = gunluk_liste_uret(gun_no)
	aktif_mahkum_indeksi = -1
	gisede_mahkum_var = false
	yeni_mahkum_geliyor = false
	mahkum_ayriliyor = false
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

	await gun_karti_goster()
	await gorevli_ziyaret("gazete")


# ------------------------------------------------------------------------------------
# GÜNLÜK MAHKUM LİSTESİ
# ------------------------------------------------------------------------------------
func gunluk_liste_uret(gun: int) -> Array:
	var veri = Hikaye.GUNLER[gun]
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
	var nakil: String = Hikaye.NAKIL.get(gun, "")
	if nakil != "" and not (nakil in secim) and not secim.is_empty():
		secim[0] = nakil
	secim.shuffle()
	# Nakledilecek mahkum günün sonunda gelsin
	if nakil != "" and nakil in secim:
		secim.erase(nakil)
		secim.append(nakil)
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
		"replik_2": "Fişim kurallara uygun. Yeşil mührü bas... lütfen.",
		"onay_1": "Teşekkür ederim... Dosya kantin kutusunda.",
		"onay_2": "Işıklar sönerse... koşma.",
		"red_1": "Anlıyorum. Sen de onlardansın.",
		"red_2": "Gece kapı çalınacak, memur.",
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
		l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
		l.add_theme_font_size_override("font_size", 10)
		l.add_theme_color_override("font_color", Color(0.16, 0.1, 0.08, 1.0))
		l.position = Vector2(10.0, 14.0)
		l.size = Vector2(140.0, 76.0)
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
	l.text = metin
	l.position = poz
	l.size = boy
	l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	l.add_theme_font_size_override("font_size", boyut)
	l.add_theme_color_override("font_color", renk)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func gun_karti_goster() -> void:
	var kat = ust_katman_al()
	var kart = ColorRect.new()
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
	var t = create_tween()
	t.tween_property(l1, "modulate:a", 1.0, 0.7)
	t.tween_property(l2, "modulate:a", 1.0, 0.5)
	t.tween_property(l3, "modulate:a", 1.0, 0.6)
	t.tween_interval(1.5)
	t.tween_property(kart, "modulate:a", 0.0, 0.9)
	await t.finished
	kart.queue_free()


func ekran_salla(guc: float) -> void:
	var t = create_tween()
	for i in range(5):
		t.tween_property(self, "position", Vector2(randf_range(-guc, guc), randf_range(-guc, guc)), 0.04)
	t.tween_property(self, "position", Vector2.ZERO, 0.05)


func rapor_paneli_goster(gun: int, bakiye_once: int, gunluk_net: int) -> void:
	var kat = ust_katman_al()
	var kapak = ColorRect.new()
	kapak.color = Color(0, 0, 0, 0.78)
	kapak.size = Vector2(1024.0, 571.0)
	kapak.mouse_filter = Control.MOUSE_FILTER_STOP
	kat.add_child(kapak)
	var panel = Panel.new()
	panel.position = Vector2(292, 96)
	panel.size = Vector2(440, 380)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.1, 0.12, 0.98)
	sb.border_color = Color(0.5, 0.42, 0.3)
	sb.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", sb)
	kapak.add_child(panel)
	var altin = Color(0.9, 0.82, 0.55)
	panel.add_child(_etiket("GÜN %d TAMAMLANDI" % gun, 22, Color(0.8, 0.24, 0.18), Vector2(0, 16), Vector2(440, 30)))
	var satirlar = [
		["Doğru kararlar", "%d" % gun_dogru, Color(0.4, 0.85, 0.5)],
		["Hatalı kararlar", "%d" % gun_hata, Color(0.9, 0.35, 0.3)],
		["Fişlerden net", "%+d $" % gun_kazanc, altin],
		["Maaş", "+%d $" % Hikaye.MAAS, altin],
		["Kira ve yemek", "-%d $" % Hikaye.KIRA_YEMEK, Color(0.9, 0.5, 0.35)],
	]
	var y = 66.0
	for s in satirlar:
		var a = _etiket(s[0], 14, Color(0.75, 0.74, 0.7), Vector2(34, y), Vector2(220, 22))
		a.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		var b = _etiket(s[1], 14, s[2], Vector2(250, y), Vector2(156, 22))
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		panel.add_child(a)
		panel.add_child(b)
		y += 26.0
	var cizgi = ColorRect.new()
	cizgi.color = Color(0.5, 0.42, 0.3)
	cizgi.position = Vector2(30, y + 2)
	cizgi.size = Vector2(380, 2)
	panel.add_child(cizgi)
	panel.add_child(_etiket("BAKİYE: %d $" % oyuncu_parasi, 20, Color(0.96, 0.88, 0.45) if oyuncu_parasi > 0 else Color(0.95, 0.3, 0.25), Vector2(0, y + 10), Vector2(440, 28)))
	var not_metin: String = gun_verisi["gun_sonu_notu"]
	if not_metin != "":
		panel.add_child(_etiket(not_metin, 12, Color(0.6, 0.6, 0.62), Vector2(20, y + 46), Vector2(400, 44)))
	var btn = Button.new()
	btn.text = "ERTESİ GÜN ►" if gun < Hikaye.SON_GUN else "SON ►"
	btn.position = Vector2(130, 322)
	btn.size = Vector2(180, 34)
	btn.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	btn.add_theme_font_size_override("font_size", 15)
	panel.add_child(btn)
	kapak.modulate.a = 0.0
	panel.scale = Vector2(0.9, 0.9)
	panel.pivot_offset = panel.size * 0.5
	var t = create_tween()
	t.tween_property(kapak, "modulate:a", 1.0, 0.35)
	t.parallel().tween_property(panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await btn.pressed
	ses_oynat(ses_dugme)
	var t2 = create_tween()
	t2.tween_property(kapak, "modulate:a", 0.0, 0.3)
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
	var renk = Color(0.8, 0.22, 0.16) if anahtar != "muhbir" else Color(0.45, 0.8, 0.5)
	var b = _etiket(s["baslik"], 38, renk, Vector2(0, 110), Vector2(1024, 50))
	var m = _etiket(s["metin"], 15, Color(0.82, 0.8, 0.72), Vector2(162, 190), Vector2(700, 180))
	var ozet = _etiket("Bakiye: %d $   •   Gün: %d" % [oyuncu_parasi, aktif_gun], 12, Color(0.5, 0.5, 0.5), Vector2(0, 392), Vector2(1024, 20))
	var btn = Button.new()
	btn.text = "TEKRAR OYNA"
	btn.position = Vector2(412, 440)
	btn.size = Vector2(200, 38)
	btn.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	btn.add_theme_font_size_override("font_size", 15)
	btn.pressed.connect(func(): get_tree().reload_current_scene())
	for n in [b, m, ozet, btn]:
		n.modulate.a = 0.0
		kapak.add_child(n)
	var t = create_tween()
	t.tween_property(b, "modulate:a", 1.0, 1.0)
	t.tween_property(m, "modulate:a", 1.0, 1.4)
	t.tween_property(ozet, "modulate:a", 1.0, 0.6)
	t.tween_property(btn, "modulate:a", 1.0, 0.6)


func gun_sonu_akisi() -> void:
	gorevli_teslimatta = true
	await get_tree().create_timer(0.7).timeout
	await gorevli_ziyaret("gun_sonu")
	var once = oyuncu_parasi
	var net = Hikaye.MAAS - Hikaye.KIRA_YEMEK
	para_guncelle(net)
	await get_tree().create_timer(0.5).timeout
	await rapor_paneli_goster(aktif_gun, once, net)
	if oyuncu_parasi <= 0:
		son_ekrani_goster("isten_atildin")
		return
	var nakil: String = Hikaye.NAKIL.get(aktif_gun, "")
	if nakil != "":
		nakledilenler.append(nakil)
	if aktif_gun >= Hikaye.SON_GUN:
		son_ekrani_goster("muhbir" if elias_karari == "ONAYLANDI" else "itaatkar")
		return
	gunu_baslat(aktif_gun + 1)


# ------------------------------------------------------------------------------------
# ATMOSFER: vinyet, tane, titreyen lambalar, toz ve ortam sesi
# ------------------------------------------------------------------------------------
const ATMOSFER_SHADER := """
shader_type canvas_item;
uniform float vignette = 0.62;
uniform float flicker = 0.0;
uniform float grain = 0.07;
void fragment() {
	vec2 uv = UV;
	float d = distance(uv, vec2(0.5, 0.48));
	float v = smoothstep(0.32, 0.98, d) * vignette;
	float n = fract(sin(dot(floor(uv * vec2(512.0, 286.0)) + floor(TIME * 24.0), vec2(12.9898, 78.233))) * 43758.5453);
	float a = v + flicker + (n - 0.5) * grain;
	COLOR = vec4(0.015, 0.02, 0.03, clamp(a, 0.0, 0.96));
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
	atmosfer_mat.set_shader_parameter("vignette", 0.6 + 0.04 * sin(Time.get_ticks_msec() * 0.0021))


# ------------------------------------------------------------------------------------
# GÖREVLİ (GARDİYAN) ZİYARETİ: sağdan gelir, replik atar, gider
# ------------------------------------------------------------------------------------
const GOREVLI_Y: float = 168.0
var gorevli_yuruyus_kare: int = 0

func _g_doku(isim: String) -> Texture2D:
	return load("res://assets/%s.png" % isim) as Texture2D


func _balonlari_hazirla() -> void:
	if g_balon_panel: return
	g_balon_panel = _balon_yap(Color(0.09, 0.1, 0.12, 0.97), Color(0.82, 0.62, 0.3))
	p_balon_panel = _balon_yap(Color(0.14, 0.16, 0.2, 0.97), Color(0.55, 0.68, 0.85))


func _balon_yap(arka: Color, cerceve: Color) -> PanelContainer:
	var pc = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = arka
	sb.border_color = cerceve
	sb.set_border_width_all(2)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 5
	sb.content_margin_bottom = 6
	pc.add_theme_stylebox_override("panel", sb)
	var l = Label.new()
	l.name = "Yazi"
	l.custom_minimum_size = Vector2(212.0, 0.0)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_override("font", preload("res://assets/retro_font.ttf"))
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color(0.93, 0.9, 0.82))
	pc.add_child(l)
	pc.visible = false
	pc.z_index = 45
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pc)
	return pc


func konus(kim: String, metin: String, gorevli: Control = null) -> void:
	_balonlari_hazirla()
	var pc: PanelContainer = g_balon_panel if kim == "g" else p_balon_panel
	var l = pc.get_node("Yazi") as Label
	l.text = metin
	l.visible_ratio = 0.0
	pc.visible = true
	pc.reset_size()
	if kim == "g" and gorevli:
		pc.position = Vector2(clampf(gorevli.position.x - 150.0, 330.0, 800.0), 96.0)
		ses_oynat(ses_konusma, -2.0)
	else:
		pc.position = Vector2(430.0, 300.0)
		ses_oynat(ses_konusma, -8.0)
	var sure = maxf(0.5, metin.length() * 0.028)
	var t = create_tween()
	t.tween_property(l, "visible_ratio", 1.0, sure)
	await t.finished
	await get_tree().create_timer(0.8 + metin.length() * 0.012).timeout
	pc.visible = false
	await get_tree().create_timer(0.12).timeout


func _gorevli_yuru(g: TextureRect, hedef_x: float, sure: float, kagitli: bool, sagdan_sola: bool) -> void:
	g.flip_h = not sagdan_sola
	var t = create_tween()
	t.tween_property(g, "position:x", hedef_x, sure).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var adim: int = 0
	while t.is_running():
		var kare: int = adim % 4
		g.texture = _g_doku(("g0_paper%d" if kagitli else "g0_walk%d") % kare)
		g.position.y = GOREVLI_Y - (3.0 if (adim % 2) == 1 else 0.0)
		if adim % 2 == 0:
			ses_oynat(ses_ayak, -6.0)
		await get_tree().create_timer(0.16).timeout
		adim += 1
	g.position.y = GOREVLI_Y


func gorevli_ziyaret(mod: String) -> void:
	var gorevli = find_child("Gorevli") as TextureRect
	var gazete = find_child("CezaeviPostasi")
	if not gorevli:
		if gazete: gazete.visible = true
		gorevli_teslimatta = false
		return
	var balon_eski = gorevli.get_node_or_null("GorevliBalonu")
	if balon_eski: balon_eski.visible = false
	gorevli_teslimatta = true
	gorevli.visible = true
	gorevli.modulate.a = 1.0
	gorevli.rotation = 0.0
	gorevli.size = Vector2(72.0, 150.0)
	gorevli.pivot_offset = Vector2(36.0, 140.0)
	gorevli.position = Vector2(1070.0, GOREVLI_Y)
	var kagitli = (mod == "gazete")

	# Kapı gıcırdar, görevli sağdan girer
	ses_oynat(ses_gicirti, -4.0)
	await _gorevli_yuru(gorevli, 690.0, 1.7, kagitli, true)

	if mod == "gazete":
		gorevli.texture = _g_doku("g0_point")
		await get_tree().create_timer(0.2).timeout
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

	await get_tree().create_timer(0.35).timeout
	var replikler: Array = gun_verisi["gardiyan"] if mod == "gazete" else []
	for r in replikler:
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
			gorevli.texture = _g_doku("g0_point")
			await konus("g", satir, gorevli)

	gorevli.texture = _g_doku("g0_idle")
	await konus("g", gun_verisi["cikis"], gorevli)

	# Çıkarken takılıp sendeler (bazen)
	if randf() < 0.5:
		gorevli.texture = _g_doku("g0_walk1")
		await _gorevli_yuru(gorevli, gorevli.position.x + 40.0, 0.5, false, false)
		ses_oynat(ses_thud, -6.0)
		var tt = create_tween()
		tt.tween_property(gorevli, "rotation", 0.3, 0.1)
		tt.tween_property(gorevli, "rotation", -0.12, 0.12)
		tt.tween_property(gorevli, "rotation", 0.0, 0.14)
		await tt.finished
		await konus("g", "Bu zemin bana kasıtlı çarptı. Rapora yazıyorum.", gorevli)
	ses_oynat(ses_gicirti, -8.0)
	await _gorevli_yuru(gorevli, 1080.0, 1.5, false, false)
	gorevli.visible = false
	gorevli_teslimatta = false


