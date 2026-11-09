extends RefCounted
# Hikaye verisi: 5 günlük karanlık hapishane hikayesi, vardiya ortası kriz olayları,
# gizli pusulalar, gece kararları, Sgt. Dobbs makarası, mahkum kadrosu ve 5 farklı oyun sonu.
# Tüm kişi isimleri İngilizcedir.

const SON_GUN: int = 5
const MAAS: int = 25
const KIRA_YEMEK: int = 20

# Mahkum kadrosu: tüm isimler İngilizce, her birinin korkutucu portresi ve sabit sicil/blok bilgisi var.
const KADRO := {
	"dutch": {
		"ad": "Dutch Marlow", "blok": "A Blok", "no": "41772", "gorsel": "res://assets/p_dutch.png",
		"siddetli": true,
		"sorgu": "Koridorda nöbetçi var memur kardeş, durumu fişin yanındaki kağıda yazdım.",
		"rusvet": "Şşşt usta... Kağıdın köşesine 20$ bıraktım, çorba parası yaparsın, görmezden gel.",
		"acilis": [
			"Kolay gelsin memur, sabahtan beri sırada bekliyoruz, bacaklarımız koptu.",
			"Koğuşta erzak bitti usta, şu fişe bir bakıver de işimiz görülsün."
		]
	},
	"ghost": {
		"ad": "Ghost Keller", "blok": "C Blok", "no": "30551", "gorsel": "res://assets/p_ghost.png",
		"siddetli": false,
		"sorgu": "Sesli söyleyemem memur bey... Mazgaldan uzattığım küçük kağıdı okuyun lütfen.",
		"acilis": [
			"Hücreler buz gibi memur kardeş... Sabaha kadar öksürükten gözüme uyku girmedi.",
			"Revirden yeni çıktım, ayakta duracak halim yok, ilacımı alıp döneyim."
		]
	},
	"vince": {
		"ad": "Vince Rattler", "blok": "A Blok", "no": "66203", "gorsel": "res://assets/p_vince.png",
		"siddetli": true,
		"sorgu": "Şefim burada sesli konuşturma beni, masaya bıraktığım kağıtta her şey yazıyor.",
		"rusvet": "Bak kağıdın üstüne 20$ iliştirdim şefim, ikimizin de yüzü gülsün, bas yeşili geç.",
		"acilis": [
			"Selam şefim, koğuşta çocuklar acıktı, şu bizim istihkakı hallediverelim.",
			"İşler yoğun galiba usta, bizim fişi aradan çıkarırsan sevinirim."
		]
	},
	"doc": {
		"ad": "Doc Hollis", "blok": "C Blok", "no": "55102", "gorsel": "res://assets/p_doc.png",
		"siddetli": false,
		"sorgu": "Gardiyanlar dinliyor memur bey, lütfen fişin yanındaki gizli pusulaya bakın...",
		"acilis": [
			"Kolay gelsin memur bey, revir için sargı bezi ve ilaç yazdırdım.",
			"Hastalar koğuşta ilaç bekliyor, evrakımı kontrol edebilir misiniz?"
		]
	},
	"moe": {
		"ad": "Big Moe Carver", "blok": "B Blok", "no": "90417", "gorsel": "res://assets/p_moe.png",
		"siddetli": true,
		"sorgu": "Usta çenemdeki tel yüzünden zor konuşuyorum, evrakımda hiçbir eksik yok!",
		"acilis": [
			"Kusura bakma memur, çenem sargılı... Akşamdan beri boğazımdan lokma geçmedi.",
			"B Blok'tan geliyorum usta, erzakımı alıp doğru koğuşa döneceğim."
		]
	},
	"eddie": {
		"ad": "Eddie Pale", "blok": "C Blok", "no": "18830", "gorsel": "res://assets/p_eddie.png",
		"siddetli": false,
		"sorgu": "Memur bey, derdimi sesli anlatamam, lütfen uzattığım yardım kağıdını okuyun...",
		"acilis": [
			"İyi günler memur bey, revir kaydımla kantin fişimi getirdim.",
			"C Blok revir sırasından geliyorum usta, evrakım tezgahın üstünde."
		]
	},
	"wolf": {
		"ad": "Wolf Brannigan", "blok": "B Blok", "no": "72964", "gorsel": "res://assets/p_wolf.png",
		"siddetli": true,
		"sorgu": "Evrakımda hiçbir sorun yok memur! Sabahtan beri bu fiş için bekliyorum ben!",
		"acilis": [
			"Koridorda herkes burnundan soluyor memur, bir an önce işimizi halledelim.",
			"B Blok erzakımı alacağım usta, kağıdım mühürlü."
		]
	},
	"stitches": {
		"ad": "Jonas Stitch", "blok": "B Blok", "no": "27395", "gorsel": "res://assets/p_stitches.png",
		"siddetli": false,
		"sorgu": "Memur ağabey, koridorda nöbetçi var, ne olur fişin yanındaki küçük kağıdı oku...",
		"acilis": [
			"Kolay gelsin memur ağabey, B Blok sırasından geliyorum.",
			"Sıram geldi usta, fişimi mazgaldan bıraktım."
		]
	},
	"tommy": {
		"ad": "Mad Tommy Reed", "blok": "A Blok", "no": "58811", "gorsel": "res://assets/p_tommy.png",
		"siddetli": true,
		"sorgu": "Şefim burada sesli söyletme beni, uzattığım kağıda yazdım durumu!",
		"rusvet": "Usta şimdi beni geri gönderme, kağıdın arasına 20$ bıraktım, aramızda halledelim.",
		"acilis": [
			"Selam şef! A Blok sırasından geliyorum, fişimi uzattım.",
			"Öğle sayımına yetişmem lazım usta, evrakıma bakabilir misin?"
		]
	},
	"crow": {
		"ad": "Crow Dalton", "blok": "B Blok", "no": "36078", "gorsel": "res://assets/p_crow.png",
		"siddetli": false,
		"sorgu": "Memur bey, gardiyanlar duyacak, ricamı küçük kağıda yazıp uzattım...",
		"rusvet": "Aramızda kalsın memur bey, kağıda iliştirdiğim 20$'ı al da eksiği görmezden gel.",
		"acilis": [
			"Kaloriferler arızalanmış, koğuşun içi fırın gibi oldu, boğazımız kurudu.",
			"Sıram yeni geldi memur bey, fişime bir göz atabilir misiniz?"
		]
	},
	"hargrove": {
		"ad": "Old Hargrove", "blok": "A Blok", "no": "11209", "gorsel": "res://assets/p_hargrove.png",
		"siddetli": false,
		"sorgu": "Yaşlılık işte evlat, ne diyeceğimi masadaki kağıda yazdım...",
		"acilis": [
			"Yirmi dokuz senedir bu koridorlardayım evlat, dizlerim artık merdivenleri çekmiyor.",
			"Akşamlık erzakımı alayım da erkenden ranzama çekileyim."
		]
	},
	"elias": {
		"ad": "Elias Crane", "blok": "C Blok", "no": "00713", "gorsel": "res://assets/p_elias.png",
		"siddetli": false,
		"sorgu": "Memur bey, lütfen sesli konuşmayın; her şeyi masaya uzattığım kağıda yazdım!",
		"acilis": [
			"İyi günler memur bey. C Blok, #00713 Elias Crane.",
			"Revir ilaç istihkakım için fişimi uzattım, evrakım tamdır."
		]
	},
}

# Her günün sonunda D Blok'a "nakledilen" mahkum (ertesi gün gazetede haberi çıkar).
const NAKIL := {1: "ghost", 2: "doc", 3: "hargrove", 4: "eddie"}

const ONAY_REPLIKLERI := [
	"Eyvallah memur bey, kolay gelsin.",
	"Sağ olasın usta, koğuşta dua edeceğim sana.",
	"Çok makbule geçti şefim, iyi nöbetler.",
	"Eksik olma kardeş, hakkını helal et.",
	"Teşekkür ettim memur bey, hayırlı vardiyalar.",
	"Allah razı olsun usta, görüşürüz.",
]
const RED_REPLIKLERI := [
	"Yapma be memur bey, eli boş mu döneceğiz şimdi?",
	"O kadar sıra bekledik, revire tekrar kim gidecek...",
	"İnsaf be usta, bir kerelik idare etsen ne olurdu?",
	"Hay aksi... Koğuşa yine aç döneceğiz desene.",
	"Peki memur bey, öyle olsun bakalım...",
	"Bunun hesabını koğuşta sorarlar bana, yaktın beni usta.",
]

# Her gün için özel kurgulanmış mahkum sırası:
# Konuşma balonlarında YALNIZCA sıradan günlük kantin selamlaşmaları çıkar;
# Yardım istekleri, rüşvet teklifleri ve gizli mesajlar masaya uzatılan fiziksel KAĞIT NOT (kagit_not / pusula) olarak gelir!
const GUN_SENARYOLARI := {
	1: [
		{
			"id": "doc", "ilac": true, "yiyecek": false, "icecek": false, "sahte": "",
			"replik_1": "Kolay gelsin memur bey, yeni görevinizde başarılar dilerim.",
			"replik_2": "C Blok reviri için sargı bezi ve ilaç istihkakımı almaya geldim.",
			"pusula": {
				"baslik": "GİZLİ PUSULA #1 — ARTHUR PYM'İN NOTU",
				"metin": "\"Yeni memura: Warden Graves her gece bir mahkumu 'D Blok'a nakil' bahanesiyle alt mahzene indiriyor. Oradan kimse dönmedi. C Blok'taki Elias Crane (#00713) kanıtları topluyor. Ona yardım et! — Arthur Pym\"",
				"secenek_direnis": "SAKLA (KANIT +1)",
				"secenek_sadakat": "İHBAR ET (+15$)",
				"odul_sadakat": 15
			}
		},
		{
			"id": "vince", "ilac": true, "yiyecek": true, "icecek": false, "sahte": "",
			"replik_1": "Selam şefim, sabahtan beri kuyruktayız, nihayet sıra bize geldi.",
			"replik_2": "A Blok istihkak fişimi mazgaldan uzattım usta, bir bakıver.",
			"kagit_not": {
				"baslik": "EL YAZISI NOT • VINCE RATTLER",
				"metin": "\"Şefim gardiyanlar duyuyor diye sesli söyleyemedim... Koğuşta arkadaşın dişi apse yaptı, acıdan kıvranıyor. A Blok'a ilaç yasak biliyorum ama fişe ağrı kesici de yazdım. Kağıda 20$ iliştirdim, görmezden gelip onaylarsan hayat kurtarırsın.\"",
				"parali": true
			}
		},
		{
			"id": "ghost", "ilac": true, "yiyecek": false, "icecek": false, "sahte": "",
			"replik_1": "Hücreler buz gibi memur kardeş... Sabaha kadar öksürükten uyuyamadım.",
			"replik_2": "C Blok revir şurubumu alayım da koğuşa döneyim, ayakta duracak halim yok.",
			"kagit_not": {
				"baslik": "KARALANMIŞ KAĞIT • GHOST KELLER",
				"metin": "\"Memur kardeş, sesimi çıkarmaya korkuyorum... Bu gece beni 'D Blok'a nakil' bahanesiyle mahzene indirecekler. Gişeden çıkarken tezgahın kenarına paslı havalandırma anahtarını bırakacağım, ne olur devriyeye çaktırma!\"",
				"parali": false
			},
			"orta_olay_sonrasi": "gun1_ghost_olayi"
		}
	],
	2: [
		{
			"id": "dutch", "ilac": false, "yiyecek": true, "icecek": true, "sahte": "tarih",
			"replik_1": "Günaydın memur, sabahtan beri kuyrukta bekliyoruz, karnımız sırtımıza yapıştı.",
			"replik_2": "A Blok için konserve ve içecek fişimi mazgaldan bıraktım usta.",
			"kagit_not": {
				"baslik": "BURUŞUK NOT • DUTCH MARLOW",
				"metin": "\"Usta dün akşam sıra bitmeyince fişim dünden kaldı, tarihi eski. Şimdi geri çevirirsen bu gece aç kalırız. Kağıdın köşesine 20$ tutturdum, çorba parası yaparsın; tarihi görmezden gelip bas yeşil mührü geç be kardeş.\"",
				"parali": true
			}
		},
		{
			"id": "moe", "ilac": false, "yiyecek": true, "icecek": false, "sahte": "",
			"replik_1": "Kusura bakma usta, çenemdeki tel yüzünden zor konuşuyorum. Akşamdan beri lokma girmedi ağzıma.",
			"replik_2": "B Blok'tan geliyorum, sadece konserve yemeğimi alacağım, kağıdım orada.",
			"orta_olay_oncesi": "gun2_alarm_olayi"
		},
		{
			"id": "doc", "ilac": true, "yiyecek": false, "icecek": false, "sahte": "",
			"replik_1": "Tekrar merhaba memur bey, bugünkü revir nöbeti bir hayli yoğundu.",
			"replik_2": "C Blok revir ilaçlarımı alabilir miyim? Evrakımı mazgaldan uzattım.",
			"pusula": {
				"baslik": "GİZLİ KANIT #2 — D BLOK DENEY KAYDI",
				"metin": "\"Memur bey, dün gece Ghost Keller'ı mahzene indirdiler! Revirden bu raporu çaldım: DENEY #30551 kimyasal hafıza silme protokolüne alındı (İmza: Warden Graves). Lütfen bu belgeyi saklayın! — Doc Hollis\"",
				"secenek_direnis": "SAKLA (KANIT +1)",
				"secenek_sadakat": "İHBAR ET (+20$)",
				"odul_sadakat": 20
			}
		}
	],
	3: [
		{
			"id": "tommy", "ilac": false, "yiyecek": true, "icecek": false, "sahte": "imza",
			"replik_1": "Selam şef! Öğle sayımına yetişeceğim, sıram nihayet geldi.",
			"replik_2": "A Blok için yiyecek istihkak fişimi tezgaha bıraktım usta.",
			"kagit_not": {
				"baslik": "KATLANMIŞ NOT • MAD TOMMY",
				"metin": "\"Şefim sesli söyleme, koridorda gardiyanlar var! Bu fişi dün Guard Voss'a iki paket sigara verip imzalatmıştım, sabah tutuklamışlar herifi. İmzayı görmezden gelip onaylarsan kağıttaki 20$ helali hoş olsun!\"",
				"parali": true
			}
		},
		{
			"id": "wolf", "ilac": false, "yiyecek": true, "icecek": false, "sahte": "",
			"replik_1": "Koridorda herkes çok gergin memur, sabahtan beri gardiyanlar koğuşları arıyor.",
			"replik_2": "Ben beladan uzak dururum, B Blok yemeğimi alıp doğru koğuşuma gideceğim.",
			"orta_olay_sonrasi": "gun3_isyan_olayi"
		},
		{
			"id": "crow", "ilac": false, "yiyecek": true, "icecek": true, "sahte": "",
			"replik_1": "Kaloriferler arızalanmış, koğuşun içi hamam gibi oldu, dilimiz damağımız kurudu.",
			"replik_2": "B Blok erzak fişimi mazgaldan uzattım memur bey, bakabilir misiniz?",
			"kagit_not": {
				"baslik": "EL YAZISI NOT • CROW DALTON",
				"metin": "\"Memur bey, B Blok'ta su boruları patladı, koğuşta yaşlılar susuzluktan baygın yatıyor. B Blok'a içecek yasak biliyorum ama fişe bir kutu da meyve suyu işaretledim. Şu 20$'ı al da bize bir şişe içecek ver ne olur.\"",
				"parali": true
			}
		},
		{
			"id": "hargrove", "ilac": false, "yiyecek": true, "icecek": false, "sahte": "",
			"replik_1": "Yirmi dokuz senedir bu demir kapıların ardındayım evlat, dizlerim artık tutmuyor.",
			"replik_2": "Akşamlık konserve istihkakımı alayım da ranzama çekileyim.",
			"pusula": {
				"baslik": "GİZLİ KANIT #3 — HARGROVE'UN NOTU & KASET",
				"metin": "\"Evlat bu akşam beni de D Blok'a indirecekler. Kaset kaydını notun altına sardım: Warden Graves bakanlık bütçesini zimmetine geçirip mahkumlar üzerinde deney yapıyor. 5. Gün #00713 Elias Crane'e yardım et! — Hargrove\"",
				"secenek_direnis": "SAKLA (KANIT +1)",
				"secenek_sadakat": "İHBAR ET (+25$)",
				"odul_sadakat": 25
			}
		}
	],
	4: [
		{
			"id": "stitches", "ilac": false, "yiyecek": true, "icecek": false, "sahte": "",
			"replik_1": "Kolay gelsin memur ağabey, B Blok sırasından geliyorum.",
			"replik_2": "Fişimi mazgaldan bıraktım usta, bir bakarsan sevinirim.",
			"kagit_not": {
				"baslik": "YARDIM KAĞIDI • JONAS STITCH",
				"metin": "\"Memur ağabey, B Blok'ta başkasının çıkardığı kavga yüzünden bütün koğuşa disiplin cezası kestiler. İki gündür tek lokma ekmek girmedi boğazımızdan, ağzımdaki dikişler sızlıyor... Param yok ama elini vicdanına koy, bir konserve vermez misin?\"",
				"parali": false
			}
		},
		{
			"id": "vince", "ilac": false, "yiyecek": true, "icecek": false, "sahte": "",
			"replik_1": "Duydun mu şef, bakanlıktan müfettiş gelmiş, koridorda tek tek evrak kontrol ediyor!",
			"replik_2": "Benim evrakım bugün tertemiz vallahi, erzakımı alayım da müfettiş gelmeden koğuşa döneyim.",
			"orta_olay_sonrasi": "gun4_mufettis_olayi"
		},
		{
			"id": "eddie", "ilac": true, "yiyecek": true, "icecek": false, "sahte": "izin",
			"replik_1": "İyi günler memur bey, C Blok revir sırasından geliyorum.",
			"replik_2": "Kantin fişimi ve revir kaydımı tezgaha bıraktım usta.",
			"kagit_not": {
				"baslik": "YARDIM PUSULASI • EDDIE PALE",
				"metin": "\"Memur bey, geçen hafta revirde tartıştık diye kartıma 'Kısıtlı' şerhi düşmüşler. Mide kanaması geçiriyorum, ilacımla yemeğimi alamazsam sabaha çıkamam... Yalvarırım müfettiş görmeden bir kolaylık sağla!\"",
				"parali": false
			}
		}
	],
	5: [
		{
			"id": "dutch", "ilac": false, "yiyecek": true, "icecek": true, "sahte": "",
			"replik_1": "Bugün hapishanede çıt çıkmıyor memur, bütün kapılara çift nöbetçi dikmişler.",
			"replik_2": "A Blok yiyecek ve içecek hakkımı alayım da koğuş kapıları kilitlenmeden döneyim.",
		},
		{
			"id": "crow", "ilac": false, "yiyecek": false, "icecek": true, "sahte": "imza",
			"replik_1": "Kolay gelsin usta, vardiya bitmeden B Blok sırasına yetiştim.",
			"replik_2": "İçecek fişimi mazgaldan uzattım, kontrol edebilir misin?",
			"kagit_not": {
				"baslik": "GİZLİ NOT • CROW DALTON",
				"metin": "\"Usta elimde geçen haftadan Guard Voss imzalı bu fiş kalmıştı, koğuşlar kilitlenince yeni nöbetçiye imzalatamadım. Aramızda kalsın, kağıda 20$ sıkıştırdım; yeşil mührü vur da içeceğimi alıp gideyim.\"",
				"parali": true
			},
			"orta_olay_sonrasi": "gun5_graves_telsiz"
		},
		{
			"id": "elias", "ilac": true, "yiyecek": false, "icecek": false, "sahte": "",
			"replik_1": "İyi günler memur bey. C Blok, #00713 Elias Crane.",
			"replik_2": "Revir ilaç istihkakım için fişimi uzattım, evrakım yönetmeliğe uygundur.",
			"kagit_not": {
				"baslik": "ACİL GİZLİ NOT • ELIAS CRANE (#00713)",
				"metin": "\"Memur bey, gardiyanlar dinlediği için sesli konuşamıyorum! Warden Graves, D Blok mahzenindeki yasadışı deneyleri ifşa edeceğimi bildiği için özel emirle adımı yasakladı. Evrakım kurallara %100 uygun! Fişime ONAY basıp ilacımı verirseniz kutudaki mikrofilmi müfettişe ulaştıracağım!\"",
				"parali": false
			}
		}
	]
}

# Vardiya ortasında gerçekleşen interaktif kriz/hikaye olayları
const ORTA_OLAYLAR := {
	"gun1_ghost_olayi": {
		"baslik": "⚡ KORİDOR OLAYI: GHOST KELLER'IN METAL ANAHTARI",
		"metin": "Ghost Keller gişeden ayrılırken tezgahın yarısına paslı bir havalandırma anahtarı bıraktı.\nKoridorun ucundan Warden Graves'in devriyesi yaklaşıyor!\n\nNe yapacaksın?",
		"secenekler": [
			{"metin": "Anahtarı Gizlice Cebine At (Kanıt +1, Direniş +1)", "para": 0, "kanit": 1, "direnis": 1, "sadakat": 0, "sonuc": "Anahtarı kolunun altına sakladın. Keller koridorun karanlığında sana minnetle başını salladı."},
			{"metin": "Devriyeye Seslenip Anahtarı Teslim Et (+15$ İkramiye, Sadakat +1)", "para": 15, "kanit": 0, "direnis": 0, "sadakat": 1, "sonuc": "Nöbetçi amiri anahtara el koydu ve siciline sadakat notu düşüp 15$ ikramiye ödedi."}
		]
	},
	"gun2_alarm_olayi": {
		"baslik": "🚨 KIRMIZI ALARM: B BLOK TÜNEL BASKINI!",
		"metin": "Hapishane sirenleri aniden çalmaya başladı! Tavan lambaları kıpkırmızı yanıp sönüyor!\nGardiyanlar B Blok koridorunda arama yaparken bir mahkum gişe mazgalından içeriye kaçak sigara paketi fırlattı.\n\nNasıl müdahale edeceksin?",
		"secenekler": [
			{"metin": "Paketi Karaborsada Satmak İçin Sakla (+20$ Gelir)", "para": 20, "kanit": 0, "direnis": 0, "sadakat": -1, "sonuc": "Kaçak paketi tezgah altına indirdin. Vince Rattler'ın adamları hesabına 20$ bıraktı."},
			{"metin": "Telsizden Güvenlik Amirine Rapor Ver (+10$ Prim, Sadakat +1)", "para": 10, "kanit": 0, "direnis": 0, "sadakat": 1, "sonuc": "Güvenlik amiri ihbarın için teşekkür etti ve 10$ disiplin primi yazdı."},
			{"metin": "Paketi Mahkumlara Geri At, Kimseyi İhbar Etme (Direniş +1)", "para": 0, "kanit": 0, "direnis": 1, "sadakat": 0, "sonuc": "Mahkumlar sessizce sana selam çaktı. Koridorda itibarın arttı."}
		]
	},
	"gun3_isyan_olayi": {
		"baslik": "💥 ACİL DURUM: KORİDORDA ARBEDE VE CAM DARBESİ!",
		"metin": "B Blok mahkumları koridorda gardiyanlarla çatışmaya başladı!\nBir demir tepsi gişe camına çarptı! Sgt. Dobbs dışarıda sıkıştı, içeriden müdahale etmen gerekiyor!",
		"secenekler": [
			{"metin": "Acil Durum Gaz Valfini Aç ve Alarmı Çal (+20$ Prim, Sadakat +1)", "para": 20, "kanit": 0, "direnis": -1, "sadakat": 1, "sonuc": "Koridora biber gazı doldu, isyan bastırıldı. Warden Graves sana 20$ üstün hizmet primi gönderdi!"},
			{"metin": "Gişe Kapısını Açıp Sgt. Dobbs'u İçeri Çek (Direniş +1, +10$ Dobbs'tan)", "para": 10, "kanit": 0, "direnis": 1, "sadakat": 0, "sonuc": "Sgt. Dobbs'u içeri çekip hayatını kurtardın! 'Borcum olsun şefim, al şu 10 doları!' dedi."},
			{"metin": "Mahkumlara Yatıştırıcı Konserve Dağıt (-10$ Stok, Direniş +1, Kanıt +1)", "para": -10, "kanit": 1, "direnis": 1, "sadakat": 0, "sonuc": "Kantin erzakıyla arbedeyi kansız yatıştırdın. Bir mahkum teşekkür olarak gizli nöbet çizelgesini bıraktı!"}
		]
	},
	"gun4_mufettis_olayi": {
		"baslik": "🕵️ BAKANLIK TEFTİŞİ: INSPECTOR VANCE GİŞEDE!",
		"metin": "Siyah paltolu Bakanlık Müfettişi Inspector Vance gişe penceresine eğildi:\n\"Memur #4471... D Blok'a nakledilen mahkumların hiçbirinden haber alınamıyor. Warden Graves'in yasadışı deney yaptığına dair elinde kanıt var mı?\"",
		"secenekler": [
			{"metin": "\"Elimdeki Gizli Kanıtları Alın Müfettiş Bey!\" (Direniş +2, +15$ Teftiş Koruması)", "para": 15, "kanit": 1, "direnis": 2, "sadakat": -2, "sonuc": "Inspector Vance belgeleri çantasına kilitledi: \"Yarın Elias Crane'in fişini onaylarsan Graves'i tutuklayacağım!\""},
			{"metin": "\"Burada Her Şey Kurallara Uygun, Warden Graves Masumdur.\" (+25$ Graves Zarfı, Sadakat +2)", "para": 25, "kanit": 0, "direnis": -1, "sadakat": 2, "sonuc": "Müfettiş kaşlarını çatarak uzaklaştı. Hemen ardından Warden Graves'in kuryesi masana 25$ sadakat ödülü bıraktı!"},
			{"metin": "\"Ben Sadece Fiş Mühürlerim, Siyasete Karışmam.\" (+10$ Harcırah)", "para": 10, "kanit": 0, "direnis": 0, "sadakat": 0, "sonuc": "Inspector Vance kartvizitini ve 10$ resmi teftiş harcırahını bırakıp koridordan ayrıldı."}
		]
	},
	"gun5_graves_telsiz": {
		"baslik": "📻 DAHİLİ TELSİZ: WARDEN GRAVES'İN SON EMRİ!",
		"metin": "Masanın üzerindeki siyah telsiz cızırdadı. Arayan bizzat Cezaevi Müdürü Warden Graves:\n\"Memur #4471! Şimdi #00713 Elias Crane gişene geliyor! Fişi kurallara uygun olsa bile KIRMIZI MÜHRÜ (RET) basacaksın! Bana itaat edersen Başmemur olursun!\"",
		"secenekler": [
			{"metin": "\"Emredersiniz Müdür Bey!\" De ve +20$ Ön Ödemeyi Al (Sadakat +1)", "para": 20, "kanit": 0, "direnis": 0, "sadakat": 1, "sonuc": "Telsizden memnun bir kahkaha duyuldu ve pnömatik tüpten masana 20$ düştü. (Yine de son karar mühründe!)"},
			{"metin": "Telsizi Yüzüne Kapat ve Fişini Hazırla! (Direniş +1)", "para": 0, "kanit": 0, "direnis": 1, "sadakat": -1, "sonuc": "Telsizin fişini çektin! Şimdi sırada #00713 Elias Crane var. Vereceğin mühür Ironhold'un kaderini belirleyecek!"}
		]
	}
}

# Her günün sonunda (1-4. günler) akşam eve/koğuşa dönerken yaşanan interaktif gece kararları
const GECE_OLAYLARI := {
	1: {
		"baslik": "🌙 1. GECE OLAYI: HASTA KARDEŞİN VE GİZLİ ZARF",
		"hikaye": "Vardiya bitti. Eve döndüğünde küçük kardeşin Clara'nın öksürüğünün ağırlaştığını gördün; eczacı antibiyotik için 15$ istiyor.\nAynı anda kapının altından 'A Blok Sendikası' mühürlü bir zarf atıldı.",
		"secenekler": [
			{"metin": "Eczaneden Kardeşine İlaç Al (-15$, Aile Güvende)", "para": -15, "kanit": 0, "direnis": 1, "sadakat": 0, "sonuc": "Clara ilacını içip rahat bir uyku çekti. Vicdanın rahat."},
			{"metin": "Sendikanın Zarfını Aç ve Avansı Kabul Et (+20$)", "para": 20, "kanit": 0, "direnis": 0, "sadakat": -1, "sonuc": "Zarfın içinden 20$ çıktı. A Blok çetesi artık seni kendi adamı sayıyor."},
			{"metin": "Parayı Kasada Tut, Ihlamur Kaynat (0$)", "para": 0, "kanit": 0, "direnis": 0, "sadakat": 0, "sonuc": "Geceyi masrafsız kapattın ama Clara sabaha kadar öksürdü."}
		]
	},
	2: {
		"baslik": "🌙 2. GECE OLAYI: D BLOK ASANSÖRÜNDEKİ DOSYA",
		"hikaye": "Gece çıkışında koridorun sonunda D Blok yük asansörünün açık kaldığını fark ettin.\nYerde Ghost Keller'ın gözlükleri ve üzerinde 'PROJEKT MONARCH' yazan şifreli bir klasör duruyor!",
		"secenekler": [
			{"metin": "Klasörü Gizlice Çantana At (Kanıt +1, Direniş +1)", "para": 0, "kanit": 1, "direnis": 1, "sadakat": 0, "sonuc": "Çok kritik bir D Blok kanıtı daha ele geçirdin!"},
			{"metin": "Klasörü Warden Graves'in Ofisine Teslim Et (+20$, Sadakat +1)", "para": 20, "kanit": 0, "direnis": 0, "sadakat": 1, "sonuc": "Warden Graves sadakatinden çok memnun kaldı ve 20$ ikramiye verdi."},
			{"metin": "Hiç Bulaşmadan Hızlıca Çıkış Kapısına Yürü (0$)", "para": 0, "kanit": 0, "direnis": 0, "sadakat": 0, "sonuc": "Gölgelerin arasından sessizce uzaklaşıp evine döndün."}
		]
	},
	3: {
		"baslik": "🌙 3. GECE OLAYI: KİRA TAHSİLDARI VE GARDİYAN LOKALİ",
		"hikaye": "Ev sahibi Mrs. Kovacs kapıya dayanmış, kışlık kömür farkı olarak 15$ istiyor.\nÖte yandan Sgt. Dobbs seni köşedeki gardiyan lokaline çağırıyor: \"Gel şefim, bu gece şansımız yaver gidecek!\"",
		"secenekler": [
			{"metin": "Ev Sahibine Kömür Parasını Öde (-15$, Ev Sıcak)", "para": -15, "kanit": 0, "direnis": 1, "sadakat": 0, "sonuc": "Soba gürül gürül yandı, evin güvende."},
			{"metin": "Sgt. Dobbs ile Gardiyan Lokalinde Zar At (+20$ Kazanç!)", "para": 20, "kanit": 0, "direnis": 0, "sadakat": 0, "sonuc": "Dobbs ile masayı topladınız! Cebine 20$ net kazanç girdi."},
			{"metin": "Lokaldeki Nöbetçi Defterinden Fotokopi Çek (-10$, Kanıt +1)", "para": -10, "kanit": 1, "direnis": 1, "sadakat": 0, "sonuc": "Nöbetçiye 10$ içki ısmarlayıp D Blok gece sevkiyat listesini kopyaladın!"}
		]
	},
	4: {
		"baslik": "🌙 4. GECE OLAYI: FİNAL ÖNCESİ GECE YARISI KARARI",
		"hikaye": "Yarın 5. ve son vardiya. Gece yarısı kapın çalındı.\nEşikte hem Warden Graves'in siyah zarfı hem de Inspector Vance'in şifreli telgraf pusulası duruyor.",
		"secenekler": [
			{"metin": "Inspector Vance'e Kanıt Dosyasını Telgrafla Gönder (-10$, Kanıt +1, Direniş +2)", "para": -10, "kanit": 1, "direnis": 2, "sadakat": -1, "sonuc": "Bakanlık özel timi yarın akşam için hazır kıta bekliyor!"},
			{"metin": "Warden Graves'in Siyah Zarfındaki 25$ Rüşveti Al (+25$, Sadakat +2)", "para": 25, "kanit": 0, "direnis": -1, "sadakat": 2, "sonuc": "Graves'in kanlı parasını cebine koydun. Yarın Elias'ı reddetmeni bekliyor."},
			{"metin": "İkisini de Yak ve Silahını Yağla (0$, Bağımsız)", "para": 0, "kanit": 0, "direnis": 0, "sadakat": 0, "sonuc": "Kimsenin piyonu olmayacaksın. Son sözü yarın gişede sen söyleyeceksin."}
		]
	}
}

const GUNLER := {
	1: {
		"tarih_gun": 18,
		"baslik": "IRONHOLD POSTASI  -  18 NİSAN 1984",
		"mahkum_sayisi": 3,
		"sahte_orani": 0.0,
		"sahte_tipleri": [],
		"kurallar": {
			"A Blok": {"yiyecek": true, "icecek": true, "ilac": false},
			"B Blok": {"yiyecek": true, "icecek": false, "ilac": false},
			"C Blok": {"yiyecek": false, "icecek": false, "ilac": true},
		},
		"gecerli_gardiyanlar": ["Guard Harlan", "Guard Cole"],
		"sahte_gardiyan": "Guard Voss",
		"kart_alt": "1. Gün — Eski kantin memuru Arthur Pym dün gece ortadan kayboldu.",
		"emir": "BUGÜN: Blok kurallarına\nkesin uyun. Soru sormayın.\n- Warden Graves",
		"gazete": {
			"sol_baslik": "MANŞET HABER",
			"aranan1": "YENİ KANTİN MEMURU\nArthur Pym'in 'ani istifası'\nsonrası gişe yeniden açıldı.",
			"aranan2": "WARDEN GRAVES:\n'Kurallara uyan kazanır.\nHata yapan D Blok'u boylar.'",
			"sol_alt": "BLOK İZİNLERİ:\nA Blok: Yiyecek + İçecek\nB Blok: Yalnız Yiyecek\nC Blok: Yalnız İlaç/Revir",
			"sag_baslik": "CEZAEVİ GÜNDEMİ",
			"sag_ust": "- KANTİN DENETİMİ:\nFişsiz hiçbir ürün verilmez.\nÖnce mührü basın, sonra\neşyayı verip TESLİM ET'e basın.",
			"sag_alt": "- GİZLİ PUSULALAR:\nMahkumların bıraktığı gizli\nnotları okumak veya ihbar\netmek sizin elinizdedir.",
		},
		"gardiyan": [
			["g", "Günaydın yeni kantinci! Ben Sgt. Dobbs. Sabah gazeten sıcak sıcak geldi!"],
			["p", "Günaydın Sgt. Dobbs. Benden önceki memur Arthur Pym'e ne oldu?"],
			["g", "Şşşt! Pym çok soru soruyordu, bir gece terliklerini bırakıp 'D Blok'a tatile çıktı! Haha!"],
			["g", "Bugün 3 mahkumun var. Kural kitabına bak, eşyaları bölmeye koyup mührü bas!"],
		],
		"cikis": "Hadi kolay gelsin şef! Kırmızı düğmeye bas da ilk mahkum gelsin!",
		"gun_sonu": [
			"Vay be! İlk günü tek parça çıkardın! Ama bu gece C Blok'ta işler karışacak..."
		],
		"gun_sonu_notu": "Gece yarısı C Blok koridorundan zincir sesleri geldi.\nGhost Keller'ın hücresi sabaha karşı boşaltıldı.",
	},
	2: {
		"tarih_gun": 19,
		"baslik": "IRONHOLD POSTASI  -  19 NİSAN 1984",
		"mahkum_sayisi": 3,
		"sahte_orani": 0.45,
		"sahte_tipleri": ["tarih"],
		"kurallar": {
			"A Blok": {"yiyecek": true, "icecek": true, "ilac": false},
			"B Blok": {"yiyecek": true, "icecek": false, "ilac": false},
			"C Blok": {"yiyecek": false, "icecek": false, "ilac": true},
		},
		"gecerli_gardiyanlar": ["Guard Harlan", "Guard Cole"],
		"sahte_gardiyan": "Guard Voss",
		"kart_alt": "2. Gün — Ghost Keller bu sabah koğuş sayımında yoktu.",
		"gazete": {
			"sol_baslik": "NAKİL BİLDİRİMİ",
			"aranan1": "GHOST KELLER (#30551)\nGece yarısı D Blok'a\n'özel nakil' edildi.",
			"aranan2": "DİSİPLİN UYARISI:\nD Blok nakillerini soran\npersonel hakkında işlem yapılır.",
			"sol_alt": "SAHTE TARİH ALARMI!\nBugünün tarihi: 19.04.1984\nEski tarihli fişleri derhal\nREDDEDİN!",
			"sag_baslik": "CEZAEVİ GÜNDEMİ",
			"sag_ust": "- ESKİ FİŞ FURYASI:\nMahkumlar eski tarihli\nfişleri kullanmaya çalışıyor.\nTarihi mutlaka inceleyin!",
			"sag_alt": "- B BLOK ARAMASI:\nBugün vardiya ortasında\nkoridor araması ve siren\ntatbikatı yapılacaktır.",
		},
		"emir": "BUGÜN: Fiş tarihi\n19.04.1984 olmalı!\nEski fişleri REDDEDİN.\n- Warden Graves",
		"gardiyan": [
			["g", "Dobbs Ekspres geldi! Duydun mu, dün gece Ghost Keller'ı D Blok mahzenine indirmişler."],
			["p", "D Blok'ta gerçekte ne var Sgt. Dobbs?"],
			["g", "Vallahi ben kapısından bile geçmem şefim! Bugün uyanıklar eski tarihli fişlerle gelecek, tarihi 19.04.1984 olmayanı yapıştır kırmızıyı!"],
		],
		"cikis": "Gözünü dört aç şefim, bugün koridorda alarm çalabilir!",
		"gun_sonu": [
			"İkinci gün de bitti! Yalnız Doc Hollis'i revirden zorla çıkarıyorlar..."
		],
		"gun_sonu_notu": "Doc Hollis gece yarısı D Blok asansörüne bindirildi.\nBıraktığı otopsi raporu her şeyi kanıtlıyor.",
	},
	3: {
		"tarih_gun": 20,
		"baslik": "IRONHOLD POSTASI  -  20 NİSAN 1984",
		"mahkum_sayisi": 4,
		"sahte_orani": 0.45,
		"sahte_tipleri": ["tarih", "imza"],
		"kurallar": {
			"A Blok": {"yiyecek": true, "icecek": false, "ilac": false},
			"B Blok": {"yiyecek": true, "icecek": false, "ilac": false},
			"C Blok": {"yiyecek": false, "icecek": false, "ilac": true},
		},
		"gecerli_gardiyanlar": ["Guard Harlan", "Guard Cole"],
		"sahte_gardiyan": "Guard Voss",
		"kart_alt": "3. Gün — Guard Voss sahte imzadan tutuklandı, B Blok kaynıyor!",
		"emir": "BUGÜN: A Blok İÇECEK\nYASAKLANDI! Guard Voss\nimzası GEÇERSİZDİR!\n- Warden Graves",
		"gazete": {
			"sol_baslik": "ARANAN & NAKİL",
			"aranan1": "GUARD VOSS (Tutuklandı)\nSUÇ: Mahkumlara sahte\nimzalı fiş satmak.\nVOSS İMZASI GEÇERSİZ!",
			"aranan2": "DOC HOLLIS (#55102)\nD Blok'a nakledildi.\n'Tıbbi tecrübesine ihtiyaç\nduyulduğu' bildirildi.",
			"sol_alt": "YENİ BLOK KURALI:\nA Blok içecek izni İPTAL!\nA: Yalnız Yiyecek\nB: Yalnız Yiyecek | C: İlaç",
			"sag_baslik": "CEZAEVİ GÜNDEMİ",
			"sag_ust": "- YETKİLİ GARDİYANLAR:\nBugün yalnızca Guard Harlan\nve Guard Cole imzaları\ngeçerlidir!",
			"sag_alt": "- İSYAN TEHLİKESİ:\nB Blok koğuşlarında gerilim\nyüksek. Gişe camını koruyun!",
		},
		"gardiyan": [
			["g", "Skandal var şefim! Bizim Guard Voss iki paket sigaraya sahte imza satarken yakalandı!"],
			["p", "Demek Guard Voss imzalı tüm fişleri reddedeceğim."],
			["g", "Aynen öyle! Sadece Guard Harlan ve Guard Cole geçerli. Ayrıca A Blok'a içecek vermek bugün kesin yasak!"],
		],
		"cikis": "Dikkatli ol şefim, B Blok bugün patlamaya hazır bomba gibi!",
		"gun_sonu": [
			"Üçüncü günü de atlattık! Old Hargrove'un bıraktığı kaset elini yakmasın dikkat et!"
		],
		"gun_sonu_notu": "Old Hargrove da D Blok'a götürüldü.\nYarın Bakanlık Müfettişi Inspector Vance hapishaneye geliyor!",
	},
	4: {
		"tarih_gun": 21,
		"baslik": "IRONHOLD POSTASI  -  21 NİSAN 1984",
		"mahkum_sayisi": 3,
		"sahte_orani": 0.5,
		"sahte_tipleri": ["tarih", "imza", "izin"],
		"kurallar": {
			"A Blok": {"yiyecek": true, "icecek": false, "ilac": false},
			"B Blok": {"yiyecek": false, "icecek": false, "ilac": false},
			"C Blok": {"yiyecek": true, "icecek": false, "ilac": true},
		},
		"gecerli_gardiyanlar": ["Guard Harlan", "Guard Cole"],
		"sahte_gardiyan": "Guard Voss",
		"kart_alt": "4. Gün — Bakanlık Müfettişi Inspector Vance teftiş için koridorda!",
		"emir": "BUGÜN: B Blok DİSİPLİN\nCEZASINDA (Her şey yasak).\nKısıtlı izin = RED!\n- Warden Graves",
		"gazete": {
			"sol_baslik": "ACİL BÜLTEN",
			"aranan1": "OLD HARGROVE (#11209)\n29 yıllık mahkum gece\nD Blok'a nakledildi.\nGeri dönüş kaydı: YOK.",
			"aranan2": "INSPECTOR VANCE\nBakanlık müfettişi bugün\nkantin gişesini bizzat\nteftiş edecek!",
			"sol_alt": "KURALLAR DEĞİŞTİ!\nA Blok: Yalnız Yiyecek\nB Blok: TÜMÜ YASAK (Tecrit)\nC Blok: Yiyecek + İlaç",
			"sag_baslik": "CEZAEVİ GÜNDEMİ",
			"sag_ust": "- KISITLI İZİN YASAĞI:\nİzin statüsü 'KISITLI' olan\nmahkumların fişleri geçersizdir!\nEşya vermeden REDDEDİN.",
			"sag_alt": "- KRİTİK SORGULAMA:\nInspector Vance gişeye\ngeldiğinde vereceğiniz yanıt\nkaderinizi belirleyecek.",
		},
		"gardiyan": [
			["g", "Şşşt! Bakanlık Müfettişi Inspector Vance koridorda! Birazdan gişene uğrayıp seni sorgulayacak!"],
			["p", "Elimdeki D Blok kanıtlarını ona verebilir miyim?"],
			["g", "Karar senin şefim! Bugün B Blok isyan çıkardı diye komple cezalı, onlara hiçbir şey verme! Kısıtlı izinlileri de reddet!"],
		],
		"cikis": "Inspector Vance'e ne söyleyeceğini iyi düşün. Yarın büyük final!",
		"gun_sonu": [
			"Yarın 5. ve son gün memur bey! Elias Crane yarın gişene gelecek..."
		],
		"gun_sonu_notu": "Inspector Vance bakanlık baskını için son kanıtı bekliyor.\nWarden Graves ise tüm muhbirleri tasfiye etmeye hazırlanıyor.",
	},
	5: {
		"tarih_gun": 22,
		"baslik": "IRONHOLD POSTASI  -  22 NİSAN 1984",
		"mahkum_sayisi": 3,
		"sahte_orani": 0.45,
		"sahte_tipleri": ["tarih", "imza", "izin"],
		"kurallar": {
			"A Blok": {"yiyecek": true, "icecek": true, "ilac": false},
			"B Blok": {"yiyecek": false, "icecek": true, "ilac": false},
			"C Blok": {"yiyecek": false, "icecek": false, "ilac": true},
		},
		"gecerli_gardiyanlar": ["Guard Harlan", "Guard Cole"],
		"sahte_gardiyan": "Guard Voss",
		"kart_alt": "5. Gün (Büyük Final) — Ironhold'un kaderi senin mühründe!",
		"emir": "ÖZEL EMİR: #00713\nELIAS CRANE gelirse\nDERHAL REDDEDİN!\n- Warden Graves",
		"gazete": {
			"sol_baslik": "SON DAKİKA",
			"aranan1": "ELIAS CRANE (#00713)\nWarden Graves'in özel emri:\nGişeye geldiği anda\nREDDEDİLECEKTİR!",
			"aranan2": "EDDIE PALE (#18830)\nD Blok'a nakledildi.\nD Blok mahzeninde Projekt\nMonarch alarmı verildi!",
			"sol_alt": "SON GÜN KURALLARI:\nA Blok: Yiyecek + İçecek\nB Blok: Yalnız İçecek\nC Blok: Yalnız İlaç",
			"sag_baslik": "CEZAEVİ GÜNDEMİ",
			"sag_ust": "- BÜYÜK SEÇİM:\nElias Crane'in evrakları\nkurallara tam uygun olsa bile\nWarden Graves RED emri verdi!",
			"sag_alt": "- INSPECTOR VANCE:\n'Elias'ın ilaç kutusundaki\nmikrofilmi onaylayan memur\nIronhold'u kurtaracaktır!'",
		},
		"gardiyan": [
			["g", "Son gün geldi çattı şefim! Koridorun iki ucunda iki ayrı kuvvet bekliyor."],
			["p", "Masadaki özel emirde #00713 Elias Crane'i reddetmem yazıyor."],
			["g", "Elias'ın fişi kurallara %100 uygun! Onaylayıp ilacını verirsen Projekt Monarch ifşa olur. Reddedersen Warden Graves kazanır!"],
		],
		"cikis": "Hakkını helal et şefim! Hangi mührü basarsan sonumuz o olacak!",
		"gun_sonu": [
			"Mühür basıldı! Dışarıda sirenler ve helikopter sesleri yankılanıyor..."
		],
		"gun_sonu_notu": "",
	},
}

const SONLAR := {
	"isten_atildin": {
		"baslik": "SON 1/5: D BLOK MAHKUMU (#4471)",
		"metin": "Kasa bakiyen tükendi ve borçlarını ödeyemedin.\nWarden Graves seni 'verimsiz personel' ilan ederek\ngece yarısı D Blok'a — Projekt Monarch mahzenine — naklettirdi.\n\nSabah olduğunda kantin gişesinde yeni bir memur oturuyor.\nSen ise demir parmaklıkların arkasında, elinde buruşuk bir fişle sıranı bekliyorsun.",
	},
	"devrim_kahramani": {
		"baslik": "SON 2/5: DEVRİMİN KIVILCIMI (GERÇEK SON)",
		"metin": "Topladığın gizli kanıtlar ve Elias Crane'e bastığın yeşil mühür sayesinde\nInspector Vance ve Bakanlık Özel Birlikleri gece yarısı Ironhold'a baskın düzenledi!\n\nWarden Graves kelepçelenerek kendi kurduğu D Blok hücresine kapatıldı.\nArthur Pym, Doc Hollis, Ghost Keller ve Old Hargrove mahzenden kurtarıldı!\nBakanlık seni Üstün Cesaret Madalyası ve Başmüfettişlik göreviyle ödüllendirdi!",
	},
	"muhbir": {
		"baslik": "SON 3/5: KARANLIKTA KAÇIŞ",
		"metin": "Warden Graves'in emrine karşı gelerek Elias Crane'in ilacını onayladın!\nAncak elinde yeterli ek kanıt olmadığı için Graves kanıtların bir kısmını yakmayı başardı.\n\nGece yarısı Sgt. Dobbs ve Elias Crane ile birlikte havalandırma tünelinden kaçtınız.\nBasına sızdırdığınız ses kaseti ülkede büyük infial yarattı; artık özgür bir direnişçisin!",
	},
	"basmemur": {
		"baslik": "SON 4/5: DEMİR YUMRUK BAŞMEMURU",
		"metin": "Beş gün boyunca Warden Graves'e tam sadakat gösterdin, gizli pusulaları ihbar ettin\nve son gün Elias Crane'in fişine acımadan KIRMIZI MÜHRÜ bastın!\n\nInspector Vance eli boş döndü. Warden Graves seni 'Ironhold Başmemuru' ilan etti.\nMaaşın üç katına çıktı, odan üst kata taşındı...\nArtık D Blok nakil listelerinin altındaki mührü bizzat sen basıyorsun.",
	},
	"karaborsa_patronu": {
		"baslik": "SON 5/5: GÖLGE SENDİKASI PATRONU",
		"metin": "Ne Warden Graves'in ne de Bakanlığın umurundaydın; sen kendi imparatorluğunu kurdun!\nAldığın rüşvetler, kaçak sevkiyatlar ve doldurduğun kasanla A Blok Sendikası'nın gizli ortağı oldun.\n\nBeşinci günün sonunda içi para dolu çantanla Ironhold'dan istifa edip çıktın.\nArkanda yanan bir hapishane, önünde ise servet dolu yeni bir hayat bıraktın!",
	},
	"itaatkar": {
		"baslik": "SON: SUSTURULAN TANIK",
		"metin": "Warden Graves'in emrine boyun eğip Elias Crane'i reddettin,\nfakat önceki günlerde Graves'in güvenini tam kazanamadığın için 'riskli tanık' sayıldın.\n\nBir hafta sonra yayınlanan yeni D Blok nakil listesinin\nen başında kendi sicil numaranı gördün: #4471.\n\nÇok fazla şey biliyordun.",
	},
}


static func tarih_str(gun: int) -> String:
	return "%02d.04.1984" % GUNLER[gun]["tarih_gun"]
