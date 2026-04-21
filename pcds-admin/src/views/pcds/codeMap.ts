/** 所有设计选项代码 → 中文名映射 */
export const codeMap: Record<string, string> = {
    // 服装类型
    ct_top: '上装', ct_bottom: '下装', ct_dress: '裙装', ct_suit: '套装',
    ct_tshirt: 'T恤', ct_shirt: '衬衫', ct_hoodie: '卫衣', ct_coat: '外套',
    ct_blazer: '西装', ct_jacket: '夹克', ct_windbreaker: '风衣', ct_down_jacket: '羽绒服',
    ct_straight_pants: '直筒裤', ct_wide_pants: '阔腿裤', ct_tapered_pants: '锥形裤',
    ct_jeans: '牛仔裤', ct_sweatpants: '运动裤', ct_shorts: '短裤',
    ct_a_skirt: 'A字裙', ct_pleated_skirt: '百褶裙', ct_pencil_skirt: '包臀裙',
    ct_dress_full: '连衣裙', ct_midi_skirt: '半身裙', ct_slip_dress: '吊带裙',
    ct_suit_set: '西装套装', ct_sport_set: '运动套装', ct_casual_set: '休闲套装',
    // 花纹
    p_solid: '纯色', p_stripe: '条纹', p_plaid: '格纹', p_floral: '碎花',
    p_geometric: '几何图案', p_animal: '动物纹', p_camouflage: '迷彩', p_tie_dye: '扎染',
    // 材质
    m_cotton: '棉', m_linen: '麻', m_silk: '丝绸', m_chiffon: '雪纺',
    m_denim: '牛仔', m_leather: '皮革', m_knit: '针织', m_wool: '羊毛', m_polyester: '涤纶',
    // 风格
    s_casual: '休闲', s_business: '商务', s_sport: '运动', s_streetwear: '街头',
    s_vintage: '复古', s_minimalist: '简约', s_ethnic: '民族风', s_preppy: '学院风',
    // 受众
    a_men: '男性', a_women: '女性', a_kids: '儿童', a_elderly: '老年人',
    a_office: '职场人士', a_athlete: '运动爱好者', a_student: '学生',
    // AI模型
    ai_standard: '快速生成', ai_hd: '精细生成', ai_creative: '创意生成',
    // 身体类型
    bt_standard: '标准', bt_slim: '偏瘦', bt_plus: '偏胖', bt_muscular: '肌肉型',
    // 肤色
    sk_fair: '白皙', sk_natural: '自然', sk_tan: '小麦', sk_dark: '深色',
    // 性别
    g_male: '男', g_female: '女',
    // 背景
    bg_white: '纯白背景', bg_city: '城市街景', bg_nature: '自然风光',
    bg_studio: '专业摄影棚', bg_indoor: '室内场景', bg_beach: '海滩',
    // 颜色
    col_white: '纯白', col_black: '经典黑', col_sky_blue: '天空蓝', col_coral: '珊瑚红',
    col_mint: '薄荷绿', col_cream: '奶油黄', col_gray: '烟灰', col_navy: '藏青',
    col_pink: '粉红', col_purple: '紫色', col_orange: '橙色', col_brown: '棕色',
}

export const cn = (code: string) => codeMap[code] || code
