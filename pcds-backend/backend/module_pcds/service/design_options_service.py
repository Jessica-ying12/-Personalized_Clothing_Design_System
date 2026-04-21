from typing import List, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from module_pcds.entity.do.design_option_do import PcdsDesignOption
from module_pcds.entity.vo.design_vo import DesignOptionVO


class PcdsDesignOptionsService:

    @staticmethod
    async def get_options(db: AsyncSession, category: Optional[str] = None) -> List[DesignOptionVO]:
        query = select(PcdsDesignOption).where(PcdsDesignOption.status == '0')
        if category:
            query = query.where(PcdsDesignOption.category == category)
        query = query.order_by(PcdsDesignOption.sort_order)
        result = await db.execute(query)
        options = result.scalars().all()

        # 建立 option_id → option_code 映射，用于 parent_id 转 parent_code
        id_to_code = {opt.option_id: opt.option_code for opt in options}
        # 如果按 category 过滤，父级可能不在结果里，需要全量查一次
        if category:
            all_result = await db.execute(select(PcdsDesignOption).where(PcdsDesignOption.status == '0'))
            all_opts = all_result.scalars().all()
            id_to_code = {opt.option_id: opt.option_code for opt in all_opts}

        return [
            DesignOptionVO(
                id=opt.option_code,
                category=opt.category,
                name=opt.name_zh,
                name_en=opt.name_en,
                parent_id=id_to_code.get(opt.parent_id) if opt.parent_id else None,
                sort_order=opt.sort_order,
            )
            for opt in options
        ]

    @staticmethod
    async def get_children(db: AsyncSession, parent_id: str) -> List[DesignOptionVO]:
        # 先找父级
        parent_result = await db.execute(
            select(PcdsDesignOption).where(PcdsDesignOption.option_code == parent_id)
        )
        parent = parent_result.scalar_one_or_none()
        if not parent:
            return []

        result = await db.execute(
            select(PcdsDesignOption)
            .where(PcdsDesignOption.parent_id == parent.option_id, PcdsDesignOption.status == '0')
            .order_by(PcdsDesignOption.sort_order)
        )
        options = result.scalars().all()
        return [
            DesignOptionVO(
                id=opt.option_code,
                category=opt.category,
                name=opt.name_zh,
                name_en=opt.name_en,
                parent_id=str(opt.parent_id) if opt.parent_id else None,
                sort_order=opt.sort_order,
            )
            for opt in options
        ]

    @staticmethod
    async def init_default_options(db: AsyncSession) -> None:
        """初始化默认设计选项数据"""
        count_result = await db.execute(select(PcdsDesignOption))
        existing = count_result.scalars().first()
        if existing:
            return  # 已有数据，跳过

        default_options = [
            # ── 版型（clothing_type）一级分类 ─────────────────────
            ('clothing_type', 'ct_top',      '上装', 'Tops',      None, 1),
            ('clothing_type', 'ct_bottom',   '下装', 'Bottoms',   None, 2),
            ('clothing_type', 'ct_dress',    '裙装', 'Dresses',   None, 3),
            ('clothing_type', 'ct_suit',     '套装', 'Suits',     None, 4),
            # 上装子类
            ('clothing_type', 'ct_tshirt',   'T恤',   'T-Shirt',       'ct_top', 11),
            ('clothing_type', 'ct_shirt',    '衬衫',  'Shirt',         'ct_top', 12),
            ('clothing_type', 'ct_hoodie',   '卫衣',  'Hoodie',        'ct_top', 13),
            ('clothing_type', 'ct_coat',     '外套',  'Coat',          'ct_top', 14),
            ('clothing_type', 'ct_blazer',   '西装',  'Blazer',        'ct_top', 15),
            ('clothing_type', 'ct_jacket',   '夹克',  'Jacket',        'ct_top', 16),
            ('clothing_type', 'ct_windbreaker', '风衣', 'Windbreaker', 'ct_top', 17),
            ('clothing_type', 'ct_down_jacket', '羽绒服', 'Down Jacket', 'ct_top', 18),
            # 下装子类
            ('clothing_type', 'ct_straight_pants', '直筒裤', 'Straight Pants', 'ct_bottom', 21),
            ('clothing_type', 'ct_wide_pants',     '阔腿裤', 'Wide-leg Pants', 'ct_bottom', 22),
            ('clothing_type', 'ct_tapered_pants',  '锥形裤', 'Tapered Pants',  'ct_bottom', 23),
            ('clothing_type', 'ct_jeans',          '牛仔裤', 'Jeans',          'ct_bottom', 24),
            ('clothing_type', 'ct_sweatpants',     '运动裤', 'Sweatpants',     'ct_bottom', 25),
            ('clothing_type', 'ct_shorts',         '短裤',   'Shorts',         'ct_bottom', 26),
            # 裙装子类
            ('clothing_type', 'ct_a_skirt',        'A字裙',  'A-line Skirt',   'ct_dress', 31),
            ('clothing_type', 'ct_pleated_skirt',  '百褶裙', 'Pleated Skirt',  'ct_dress', 32),
            ('clothing_type', 'ct_pencil_skirt',   '包臀裙', 'Pencil Skirt',   'ct_dress', 33),
            ('clothing_type', 'ct_dress_full',     '连衣裙', 'Dress',          'ct_dress', 34),
            ('clothing_type', 'ct_midi_skirt',     '半身裙', 'Midi Skirt',     'ct_dress', 35),
            ('clothing_type', 'ct_slip_dress',     '吊带裙', 'Slip Dress',     'ct_dress', 36),
            # 套装子类
            ('clothing_type', 'ct_suit_set',       '西装套装', 'Suit Set',     'ct_suit', 41),
            ('clothing_type', 'ct_sport_set',      '运动套装', 'Sport Set',    'ct_suit', 42),
            ('clothing_type', 'ct_casual_set',     '休闲套装', 'Casual Set',   'ct_suit', 43),

            # ── 花纹（pattern）────────────────────────────────────
            ('pattern', 'p_solid',      '纯色',   'Solid Color',  None, 1),
            ('pattern', 'p_stripe',     '条纹',   'Stripe',       None, 2),
            ('pattern', 'p_plaid',      '格纹',   'Plaid',        None, 3),
            ('pattern', 'p_floral',     '碎花',   'Floral',       None, 4),
            ('pattern', 'p_geometric',  '几何图案', 'Geometric',  None, 5),
            ('pattern', 'p_animal',     '动物纹', 'Animal Print', None, 6),
            ('pattern', 'p_camouflage', '迷彩',   'Camouflage',   None, 7),
            ('pattern', 'p_tie_dye',    '扎染',   'Tie-Dye',      None, 8),

            # ── 材质（material）──────────────────────────────────
            ('material', 'm_cotton',    '棉',   'Cotton',     None, 1),
            ('material', 'm_linen',     '麻',   'Linen',      None, 2),
            ('material', 'm_silk',      '丝绸', 'Silk',       None, 3),
            ('material', 'm_chiffon',   '雪纺', 'Chiffon',    None, 4),
            ('material', 'm_denim',     '牛仔', 'Denim',      None, 5),
            ('material', 'm_leather',   '皮革', 'Leather',    None, 6),
            ('material', 'm_knit',      '针织', 'Knit',       None, 7),
            ('material', 'm_wool',      '羊毛', 'Wool',       None, 8),
            ('material', 'm_polyester', '涤纶', 'Polyester',  None, 9),

            # ── 风格（style）──────────────────────────────────────
            ('style', 's_casual',     '休闲',   'Casual',     None, 1),
            ('style', 's_business',   '商务',   'Business',   None, 2),
            ('style', 's_sport',      '运动',   'Sport',      None, 3),
            ('style', 's_streetwear', '街头',   'Streetwear', None, 4),
            ('style', 's_vintage',    '复古',   'Vintage',    None, 5),
            ('style', 's_minimalist', '简约',   'Minimalist', None, 6),
            ('style', 's_ethnic',     '民族风', 'Ethnic',     None, 7),
            ('style', 's_preppy',     '学院风', 'Preppy',     None, 8),

            # ── 受众（audience）──────────────────────────────────
            ('audience', 'a_men',     '男性',     'Men',          None, 1),
            ('audience', 'a_women',   '女性',     'Women',        None, 2),
            ('audience', 'a_kids',    '儿童',     'Children',     None, 3),
            ('audience', 'a_elderly', '老年人',   'Elderly',      None, 4),
            ('audience', 'a_office',  '职场人士', 'Office',       None, 5),
            ('audience', 'a_athlete', '运动爱好者', 'Athlete',    None, 6),
            ('audience', 'a_student', '学生',     'Student',      None, 7),

            # ── AI模型（ai_model）────────────────────────────────
            ('ai_model', 'ai_standard', '快速生成', 'Fast',     None, 1),
            ('ai_model', 'ai_hd',       '精细生成', 'Detailed', None, 2),
            ('ai_model', 'ai_creative', '创意生成', 'Creative', None, 3),

            # ── 身体类型（body_type）─────────────────────────────
            ('body_type', 'bt_standard', '标准',   'Standard',  None, 1),
            ('body_type', 'bt_slim',     '偏瘦',   'Slim',      None, 2),
            ('body_type', 'bt_plus',     '偏胖',   'Plus Size', None, 3),
            ('body_type', 'bt_muscular', '肌肉型', 'Muscular',  None, 4),

            # ── 肤色（skin_tone）─────────────────────────────────
            ('skin_tone', 'sk_fair',    '白皙', 'Fair',    None, 1),
            ('skin_tone', 'sk_natural', '自然', 'Natural', None, 2),
            ('skin_tone', 'sk_tan',     '小麦', 'Tan',     None, 3),
            ('skin_tone', 'sk_dark',    '深色', 'Dark',    None, 4),

            # ── 性别（gender）────────────────────────────────────
            ('gender', 'g_male',   '男', 'Male',   None, 1),
            ('gender', 'g_female', '女', 'Female', None, 2),

            # ── 背景（background）────────────────────────────────
            ('background', 'bg_white',  '纯白背景',   'White Studio',        None, 1),
            ('background', 'bg_city',   '城市街景',   'City Street',         None, 2),
            ('background', 'bg_nature', '自然风光',   'Nature',              None, 3),
            ('background', 'bg_studio', '专业摄影棚', 'Professional Studio', None, 4),
            ('background', 'bg_indoor', '室内场景',   'Indoor',              None, 5),
            ('background', 'bg_beach',  '海滩',       'Beach',               None, 6),

            # ── 颜色（color）─────────────────────────────────────
            ('color', 'col_white',    '纯白',   'White',       None, 1),
            ('color', 'col_black',    '经典黑', 'Black',       None, 2),
            ('color', 'col_sky_blue', '天空蓝', 'Sky Blue',    None, 3),
            ('color', 'col_coral',    '珊瑚红', 'Coral Red',   None, 4),
            ('color', 'col_mint',     '薄荷绿', 'Mint Green',  None, 5),
            ('color', 'col_cream',    '奶油黄', 'Cream Yellow',None, 6),
            ('color', 'col_gray',     '烟灰',   'Smoke Gray',  None, 7),
            ('color', 'col_navy',     '藏青',   'Navy Blue',   None, 8),
            ('color', 'col_pink',     '粉红',   'Pink',        None, 9),
            ('color', 'col_purple',   '紫色',   'Purple',      None, 10),
            ('color', 'col_orange',   '橙色',   'Orange',      None, 11),
            ('color', 'col_brown',    '棕色',   'Brown',       None, 12),
        ]

        # 先插入父级，再插入子级
        code_to_id: dict[str, int] = {}

        # 第一轮：插入无父级的选项
        for category, code, name_zh, name_en, parent_code, sort in default_options:
            if parent_code is None:
                opt = PcdsDesignOption(
                    category=category,
                    option_code=code,
                    name_zh=name_zh,
                    name_en=name_en,
                    parent_id=None,
                    sort_order=sort,
                )
                db.add(opt)

        await db.flush()

        # 查询所有已插入的选项，建立 code -> id 映射
        result = await db.execute(select(PcdsDesignOption))
        for opt in result.scalars().all():
            code_to_id[opt.option_code] = opt.option_id

        # 第二轮：插入有父级的选项
        for category, code, name_zh, name_en, parent_code, sort in default_options:
            if parent_code is not None:
                parent_id = code_to_id.get(parent_code)
                opt = PcdsDesignOption(
                    category=category,
                    option_code=code,
                    name_zh=name_zh,
                    name_en=name_en,
                    parent_id=parent_id,
                    sort_order=sort,
                )
                db.add(opt)

        await db.commit()
