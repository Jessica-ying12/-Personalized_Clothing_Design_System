import 'package:flutter/material.dart';

/// 选项预览图 — 使用 Pollinations AI 生成，固定 seed 保证每次相同
/// URL 格式: https://image.pollinations.ai/prompt/{encoded_prompt}?width=200&height=200&seed={seed}&nologo=true
const optionPreviewImages = <String, String>{
  // ── 服装类型一级 ──────────────────────────────────────────────
  'ct_top':    'https://image.pollinations.ai/prompt/flat%20lay%20top%20shirt%20clothing%20white%20background?width=200&height=200&seed=1001&nologo=true',
  'ct_bottom': 'https://image.pollinations.ai/prompt/flat%20lay%20pants%20trousers%20white%20background?width=200&height=200&seed=1002&nologo=true',
  'ct_dress':  'https://image.pollinations.ai/prompt/flat%20lay%20dress%20skirt%20white%20background?width=200&height=200&seed=1003&nologo=true',
  'ct_suit':   'https://image.pollinations.ai/prompt/flat%20lay%20suit%20set%20outfit%20white%20background?width=200&height=200&seed=1004&nologo=true',

  // ── 上装子类 ──────────────────────────────────────────────────
  'ct_tshirt':      'https://image.pollinations.ai/prompt/flat%20lay%20white%20tshirt%20cotton%20casual%20white%20background?width=200&height=200&seed=1011&nologo=true',
  'ct_shirt':       'https://image.pollinations.ai/prompt/flat%20lay%20button%20shirt%20formal%20white%20background?width=200&height=200&seed=1012&nologo=true',
  'ct_hoodie':      'https://image.pollinations.ai/prompt/flat%20lay%20hoodie%20sweatshirt%20casual%20white%20background?width=200&height=200&seed=1013&nologo=true',
  'ct_coat':        'https://image.pollinations.ai/prompt/flat%20lay%20overcoat%20long%20coat%20white%20background?width=200&height=200&seed=1014&nologo=true',
  'ct_blazer':      'https://image.pollinations.ai/prompt/flat%20lay%20blazer%20suit%20jacket%20white%20background?width=200&height=200&seed=1015&nologo=true',
  'ct_jacket':      'https://image.pollinations.ai/prompt/flat%20lay%20denim%20jacket%20casual%20white%20background?width=200&height=200&seed=1016&nologo=true',
  'ct_windbreaker': 'https://image.pollinations.ai/prompt/flat%20lay%20windbreaker%20raincoat%20white%20background?width=200&height=200&seed=1017&nologo=true',
  'ct_down_jacket': 'https://image.pollinations.ai/prompt/flat%20lay%20down%20jacket%20winter%20puffer%20white%20background?width=200&height=200&seed=1018&nologo=true',

  // ── 下装子类 ──────────────────────────────────────────────────
  'ct_straight_pants': 'https://image.pollinations.ai/prompt/flat%20lay%20straight%20leg%20pants%20white%20background?width=200&height=200&seed=1021&nologo=true',
  'ct_wide_pants':     'https://image.pollinations.ai/prompt/flat%20lay%20wide%20leg%20pants%20fashion%20white%20background?width=200&height=200&seed=1022&nologo=true',
  'ct_tapered_pants':  'https://image.pollinations.ai/prompt/flat%20lay%20tapered%20pants%20slim%20white%20background?width=200&height=200&seed=1023&nologo=true',
  'ct_jeans':          'https://image.pollinations.ai/prompt/flat%20lay%20blue%20denim%20jeans%20white%20background?width=200&height=200&seed=1024&nologo=true',
  'ct_sweatpants':     'https://image.pollinations.ai/prompt/flat%20lay%20sweatpants%20sport%20jogger%20white%20background?width=200&height=200&seed=1025&nologo=true',
  'ct_shorts':         'https://image.pollinations.ai/prompt/flat%20lay%20shorts%20summer%20casual%20white%20background?width=200&height=200&seed=1026&nologo=true',

  // ── 裙装子类 ──────────────────────────────────────────────────
  'ct_a_skirt':       'https://image.pollinations.ai/prompt/flat%20lay%20aline%20skirt%20fashion%20white%20background?width=200&height=200&seed=1031&nologo=true',
  'ct_pleated_skirt': 'https://image.pollinations.ai/prompt/flat%20lay%20pleated%20skirt%20white%20background?width=200&height=200&seed=1032&nologo=true',
  'ct_pencil_skirt':  'https://image.pollinations.ai/prompt/flat%20lay%20pencil%20skirt%20bodycon%20white%20background?width=200&height=200&seed=1033&nologo=true',
  'ct_dress_full':    'https://image.pollinations.ai/prompt/flat%20lay%20full%20dress%20women%20fashion%20white%20background?width=200&height=200&seed=1034&nologo=true',
  'ct_midi_skirt':    'https://image.pollinations.ai/prompt/flat%20lay%20midi%20skirt%20white%20background?width=200&height=200&seed=1035&nologo=true',
  'ct_slip_dress':    'https://image.pollinations.ai/prompt/flat%20lay%20slip%20dress%20satin%20white%20background?width=200&height=200&seed=1036&nologo=true',

  // ── 套装子类 ──────────────────────────────────────────────────
  'ct_suit_set':   'https://image.pollinations.ai/prompt/flat%20lay%20formal%20suit%20set%20white%20background?width=200&height=200&seed=1041&nologo=true',
  'ct_sport_set':  'https://image.pollinations.ai/prompt/flat%20lay%20sport%20athletic%20set%20white%20background?width=200&height=200&seed=1042&nologo=true',
  'ct_casual_set': 'https://image.pollinations.ai/prompt/flat%20lay%20casual%20matching%20set%20white%20background?width=200&height=200&seed=1043&nologo=true',

  // ── 花纹 ──────────────────────────────────────────────────────
  'p_solid':      'https://image.pollinations.ai/prompt/solid%20color%20plain%20fabric%20texture%20close%20up?width=200&height=200&seed=2001&nologo=true',
  'p_stripe':     'https://image.pollinations.ai/prompt/striped%20fabric%20pattern%20close%20up%20texture?width=200&height=200&seed=2002&nologo=true',
  'p_plaid':      'https://image.pollinations.ai/prompt/plaid%20tartan%20fabric%20pattern%20close%20up?width=200&height=200&seed=2003&nologo=true',
  'p_floral':     'https://image.pollinations.ai/prompt/floral%20flower%20print%20fabric%20pattern%20close%20up?width=200&height=200&seed=2004&nologo=true',
  'p_geometric':  'https://image.pollinations.ai/prompt/geometric%20pattern%20fabric%20texture%20close%20up?width=200&height=200&seed=2005&nologo=true',
  'p_animal':     'https://image.pollinations.ai/prompt/animal%20print%20leopard%20fabric%20pattern%20close%20up?width=200&height=200&seed=2006&nologo=true',
  'p_camouflage': 'https://image.pollinations.ai/prompt/camouflage%20military%20fabric%20pattern%20close%20up?width=200&height=200&seed=2007&nologo=true',
  'p_tie_dye':    'https://image.pollinations.ai/prompt/tie%20dye%20colorful%20fabric%20pattern%20close%20up?width=200&height=200&seed=2008&nologo=true',

  // ── 材质 ──────────────────────────────────────────────────────
  'm_cotton':    'https://image.pollinations.ai/prompt/cotton%20fabric%20texture%20close%20up%20soft%20white?width=200&height=200&seed=3001&nologo=true',
  'm_linen':     'https://image.pollinations.ai/prompt/linen%20fabric%20texture%20natural%20close%20up?width=200&height=200&seed=3002&nologo=true',
  'm_silk':      'https://image.pollinations.ai/prompt/silk%20fabric%20shiny%20smooth%20texture%20close%20up?width=200&height=200&seed=3003&nologo=true',
  'm_chiffon':   'https://image.pollinations.ai/prompt/chiffon%20sheer%20fabric%20texture%20close%20up?width=200&height=200&seed=3004&nologo=true',
  'm_denim':     'https://image.pollinations.ai/prompt/denim%20blue%20jeans%20fabric%20texture%20close%20up?width=200&height=200&seed=3005&nologo=true',
  'm_leather':   'https://image.pollinations.ai/prompt/leather%20material%20texture%20close%20up%20dark?width=200&height=200&seed=3006&nologo=true',
  'm_knit':      'https://image.pollinations.ai/prompt/knit%20wool%20sweater%20texture%20close%20up?width=200&height=200&seed=3007&nologo=true',
  'm_wool':      'https://image.pollinations.ai/prompt/wool%20fabric%20texture%20warm%20close%20up?width=200&height=200&seed=3008&nologo=true',
  'm_polyester': 'https://image.pollinations.ai/prompt/polyester%20synthetic%20fabric%20texture%20close%20up?width=200&height=200&seed=3009&nologo=true',

  // ── 风格 ──────────────────────────────────────────────────────
  's_casual':     'https://image.pollinations.ai/prompt/casual%20everyday%20outfit%20flat%20lay%20white%20background?width=200&height=200&seed=4001&nologo=true',
  's_business':   'https://image.pollinations.ai/prompt/business%20formal%20office%20outfit%20flat%20lay%20white%20background?width=200&height=200&seed=4002&nologo=true',
  's_sport':      'https://image.pollinations.ai/prompt/sport%20athletic%20activewear%20flat%20lay%20white%20background?width=200&height=200&seed=4003&nologo=true',
  's_streetwear': 'https://image.pollinations.ai/prompt/streetwear%20urban%20fashion%20flat%20lay%20white%20background?width=200&height=200&seed=4004&nologo=true',
  's_vintage':    'https://image.pollinations.ai/prompt/vintage%20retro%20fashion%20flat%20lay%20white%20background?width=200&height=200&seed=4005&nologo=true',
  's_minimalist': 'https://image.pollinations.ai/prompt/minimalist%20simple%20clean%20fashion%20flat%20lay%20white%20background?width=200&height=200&seed=4006&nologo=true',
  's_ethnic':     'https://image.pollinations.ai/prompt/ethnic%20traditional%20cultural%20fashion%20flat%20lay%20white%20background?width=200&height=200&seed=4007&nologo=true',
  's_preppy':     'https://image.pollinations.ai/prompt/preppy%20college%20style%20fashion%20flat%20lay%20white%20background?width=200&height=200&seed=4008&nologo=true',

  // ── 受众 ──────────────────────────────────────────────────────
  'a_men':     'https://image.pollinations.ai/prompt/mens%20fashion%20clothing%20flat%20lay%20white%20background?width=200&height=200&seed=5001&nologo=true',
  'a_women':   'https://image.pollinations.ai/prompt/womens%20fashion%20clothing%20flat%20lay%20white%20background?width=200&height=200&seed=5002&nologo=true',
  'a_kids':    'https://image.pollinations.ai/prompt/kids%20children%20clothing%20flat%20lay%20white%20background?width=200&height=200&seed=5003&nologo=true',
  'a_elderly': 'https://image.pollinations.ai/prompt/elderly%20senior%20comfortable%20clothing%20flat%20lay%20white%20background?width=200&height=200&seed=5004&nologo=true',
  'a_office':  'https://image.pollinations.ai/prompt/office%20professional%20work%20clothing%20flat%20lay%20white%20background?width=200&height=200&seed=5005&nologo=true',
  'a_athlete': 'https://image.pollinations.ai/prompt/athlete%20sport%20performance%20clothing%20flat%20lay%20white%20background?width=200&height=200&seed=5006&nologo=true',
  'a_student': 'https://image.pollinations.ai/prompt/student%20campus%20casual%20clothing%20flat%20lay%20white%20background?width=200&height=200&seed=5007&nologo=true',

  // ── AI模型 ────────────────────────────────────────────────────
  'ai_standard': 'https://image.pollinations.ai/prompt/fast%20ai%20generation%20lightning%20bolt%20icon%20blue%20gradient?width=200&height=200&seed=6001&nologo=true',
  'ai_hd':       'https://image.pollinations.ai/prompt/high%20detail%20ai%20generation%20crystal%20clear%20purple%20gradient?width=200&height=200&seed=6002&nologo=true',
  'ai_creative': 'https://image.pollinations.ai/prompt/creative%20ai%20generation%20colorful%20artistic%20gradient?width=200&height=200&seed=6003&nologo=true',
};

/// 获取选项图标（fallback 用）
const optionIcons = <String, IconData>{
  'ct_top': Icons.checkroom, 'ct_bottom': Icons.straighten,
  'ct_dress': Icons.dry_cleaning, 'ct_suit': Icons.business_center,
  'ct_tshirt': Icons.checkroom, 'ct_shirt': Icons.checkroom,
  'ct_hoodie': Icons.checkroom, 'ct_coat': Icons.checkroom,
  'ct_blazer': Icons.business_center, 'ct_jacket': Icons.checkroom,
  'ct_windbreaker': Icons.air, 'ct_down_jacket': Icons.ac_unit,
  'ct_straight_pants': Icons.straighten, 'ct_wide_pants': Icons.straighten,
  'ct_tapered_pants': Icons.straighten, 'ct_jeans': Icons.straighten,
  'ct_sweatpants': Icons.sports, 'ct_shorts': Icons.beach_access,
  'ct_a_skirt': Icons.dry_cleaning, 'ct_pleated_skirt': Icons.dry_cleaning,
  'ct_pencil_skirt': Icons.dry_cleaning, 'ct_dress_full': Icons.dry_cleaning,
  'ct_midi_skirt': Icons.dry_cleaning, 'ct_slip_dress': Icons.dry_cleaning,
  'ct_suit_set': Icons.business_center, 'ct_sport_set': Icons.sports,
  'ct_casual_set': Icons.checkroom,
};

IconData getOptionIcon(String optionId, [IconData fallback = Icons.style]) {
  return optionIcons[optionId] ?? fallback;
}
