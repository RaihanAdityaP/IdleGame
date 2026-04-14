// ─────────────────────────────────────────────
//  LOCALIZATION
// ─────────────────────────────────────────────
enum AppLang { id, en }

class L10n {
  static AppLang current = AppLang.id;

  static String get(String key) => _strings[current]?[key] ?? key;

  static final Map<AppLang, Map<String, String>> _strings = {
    AppLang.id: {
      // General
      'app_title':       'IDLE WARUNG',
      'reset':           'RESET',
      'beli':            'BELI',
      'batal':           'BATAL',
      'settings':        'PENGATURAN',
      'language':        'Bahasa',
      'bahasa_id':       'Indonesia',
      'bahasa_en':       'English',
      'save':            'SIMPAN',

      // Stats panel
      'coins':           'Koin',
      'per_second':      '/detik',
      'per_tap':         '/tap',
      'income_auto':     'Pemasukan Otomatis',
      'income_tap':      'Pemasukan per Tap',

      // Reset dialog
      'reset_title':     'RESET?',
      'reset_body':      'Semua progress akan\ndihapus permanen!\n\nYakin?',
      'reset_success':   'Progress direset!',

      // Shop
      'shop':            'TOKO UPGRADE',
      'section_idle':    '── OTOMATIS ──',
      'section_tap':     '── TAP ──',
      'tag_idle':        'OTOMATIS',
      'tag_tap':         'TAP',
      'stat_per_s':      '/detik',
      'stat_per_tap':    '/tap',

      // Upgrades
      'up_cup':          'Gelas Plastik',
      'up_gerobak':      'Gerobak Baru',
      'up_menu':         'Menu Tambahan',
      'up_karyawan':     'Pelayan',
      'up_dapur':        'Dapur Express',
      'up_franchise':    'Buka Cabang',
      'up_spatula':      'Spatula Pro',
      'up_tangan':       'Tangan Cepat',
      'up_resep':        'Resep Rahasia',
      'up_blender':      'Blender Turbo',

      // Events
      'ev_airdrop_title':    'AIRDROP!',
      'ev_airdrop_desc':     'Bonus koin dari langit!',
      'ev_rush_title':       'RUSH HOUR!',
      'ev_rush_desc':        'Pemasukan 2x selama 15 detik!',
      'ev_vip_title':        'PELANGGAN VIP!',
      'ev_vip_desc':         'Tap 5x selama 20 detik!',
      'ev_bencana_title':    'BENCANA!',
      'ev_bencana_desc':     'Bayar atau penghasilan turun 30%!',
      'ev_promo_title':      'PROMO VIRAL!',
      'ev_promo_desc':       'Koin 3x selama 10 detik!',
      'ev_artis_title':      'ARTIS MAMPIR!',
      'ev_artis_desc':       'Bonus koin besar!',
      'ev_hujan_title':      'HUJAN DERAS!',
      'ev_hujan_desc':       'Bayar atau pemasukan turun 50%!',
      'ev_listrik_title':    'LISTRIK MATI!',
      'ev_listrik_desc':     'Bayar tagihan atau tutup sementara!',
      'ev_festival_title':   'FESTIVAL KULINER!',
      'ev_festival_desc':    'Tap 10x selama 30 detik!',
      'ev_supplier_title':   'SUPPLIER MURAH!',
      'ev_supplier_desc':    'Pengeluaran 0, pemasukan 1.5x!',
      'ev_gosip_title':      'GOSIP WARUNG!',
      'ev_gosip_desc':       'Pelanggan kabur, bayar atau -20% CPS!',
      'ev_gajian_title':     'HARI GAJIAN!',
      'ev_gajian_desc':      'Semua orang belanja, CPS 3x!',

      // Milestones
      'milestone':       'MILESTONE TERCAPAI!',

      // Bencana button
      'bayar':           'BAYAR',
    },

    AppLang.en: {
      // General
      'app_title':       'IDLE WARUNG',
      'reset':           'RESET',
      'beli':            'BUY',
      'batal':           'CANCEL',
      'settings':        'SETTINGS',
      'language':        'Language',
      'bahasa_id':       'Indonesian',
      'bahasa_en':       'English',
      'save':            'SAVE',

      // Stats panel
      'coins':           'Coins',
      'per_second':      '/sec',
      'per_tap':         '/tap',
      'income_auto':     'Auto Income',
      'income_tap':      'Tap Income',

      // Reset dialog
      'reset_title':     'RESET?',
      'reset_body':      'All progress will be\npermanently deleted!\n\nAre you sure?',
      'reset_success':   'Progress reset!',

      // Shop
      'shop':            'UPGRADE SHOP',
      'section_idle':    '── AUTO ──',
      'section_tap':     '── TAP ──',
      'tag_idle':        'AUTO',
      'tag_tap':         'TAP',
      'stat_per_s':      '/sec',
      'stat_per_tap':    '/tap',

      // Upgrades
      'up_cup':          'Plastic Cup',
      'up_gerobak':      'New Cart',
      'up_menu':         'Extra Menu',
      'up_karyawan':     'Waiter',
      'up_dapur':        'Express Kitchen',
      'up_franchise':    'Open Branch',
      'up_spatula':      'Pro Spatula',
      'up_tangan':       'Quick Hands',
      'up_resep':        'Secret Recipe',
      'up_blender':      'Turbo Blender',

      // Events
      'ev_airdrop_title':    'AIRDROP!',
      'ev_airdrop_desc':     'Bonus coins from the sky!',
      'ev_rush_title':       'RUSH HOUR!',
      'ev_rush_desc':        'Income 2x for 15 seconds!',
      'ev_vip_title':        'VIP CUSTOMER!',
      'ev_vip_desc':         'Tap 5x for 20 seconds!',
      'ev_bencana_title':    'DISASTER!',
      'ev_bencana_desc':     'Pay up or income drops 30%!',
      'ev_promo_title':      'VIRAL PROMO!',
      'ev_promo_desc':       'Coins 3x for 10 seconds!',
      'ev_artis_title':      'CELEB VISIT!',
      'ev_artis_desc':       'Massive coin bonus!',
      'ev_hujan_title':      'HEAVY RAIN!',
      'ev_hujan_desc':       'Pay up or income drops 50%!',
      'ev_listrik_title':    'POWER OUTAGE!',
      'ev_listrik_desc':     'Pay the bill or close temporarily!',
      'ev_festival_title':   'FOOD FESTIVAL!',
      'ev_festival_desc':    'Tap 10x for 30 seconds!',
      'ev_supplier_title':   'CHEAP SUPPLIER!',
      'ev_supplier_desc':    'Zero cost, income 1.5x!',
      'ev_gosip_title':      'WARUNG GOSSIP!',
      'ev_gosip_desc':       'Customers fled, pay or -20% income!',
      'ev_gajian_title':     'PAYDAY!',
      'ev_gajian_desc':      'Everyone\'s spending, income 3x!',

      // Milestones
      'milestone':       'MILESTONE REACHED!',

      // Bencana button
      'bayar':           'PAY',
    },
  };
}