-- ============================================================
-- Business tables migration: customization + warehouse modules
-- ============================================================

-- ============================================================
-- 1. design_options
-- category: silhouette|pattern|material|style|audience|ai_model
--           body_shape|skin_color|gender|background
-- ============================================================
CREATE TABLE IF NOT EXISTS public.design_options (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category    text NOT NULL,
  parent_id   uuid REFERENCES public.design_options(id) ON DELETE CASCADE,
  name        text NOT NULL,
  name_en     text,
  sort_order  int  NOT NULL DEFAULT 0,
  meta        jsonb,
  is_active   boolean NOT NULL DEFAULT true,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_design_options_category  ON public.design_options(category);
CREATE INDEX IF NOT EXISTS idx_design_options_parent_id ON public.design_options(parent_id);

ALTER TABLE public.design_options ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read design_options" ON public.design_options;
CREATE POLICY "Anyone can read design_options"
ON public.design_options FOR SELECT USING (true);

-- ============================================================
-- 2. flat_designs
-- ============================================================
CREATE TABLE IF NOT EXISTS public.flat_designs (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  silhouette_id   uuid REFERENCES public.design_options(id),
  pattern_id      uuid REFERENCES public.design_options(id),
  material_id     uuid REFERENCES public.design_options(id),
  style_id        uuid REFERENCES public.design_options(id),
  audience_id     uuid REFERENCES public.design_options(id),
  ai_model_id     uuid REFERENCES public.design_options(id),
  params          jsonb NOT NULL DEFAULT '{}',
  image_url       text,
  status          text NOT NULL DEFAULT 'pending',
  error_msg       text,
  regen_count     int  NOT NULL DEFAULT 0,
  is_saved        boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_flat_designs_user_id    ON public.flat_designs(user_id);
CREATE INDEX IF NOT EXISTS idx_flat_designs_created_at ON public.flat_designs(created_at DESC);

ALTER TABLE public.flat_designs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own flat_designs" ON public.flat_designs;
CREATE POLICY "Users can manage own flat_designs"
ON public.flat_designs FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 3. designs_3d
-- ============================================================
CREATE TABLE IF NOT EXISTS public.designs_3d (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  flat_design_id  uuid NOT NULL REFERENCES public.flat_designs(id) ON DELETE CASCADE,
  body_shape_id   uuid REFERENCES public.design_options(id),
  skin_color_id   uuid REFERENCES public.design_options(id),
  gender_id       uuid REFERENCES public.design_options(id),
  ai_model_id     uuid REFERENCES public.design_options(id),
  background_id   uuid REFERENCES public.design_options(id),
  image_url       text,
  status          text NOT NULL DEFAULT 'pending',
  error_msg       text,
  regen_count     int  NOT NULL DEFAULT 0,
  is_saved        boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_designs_3d_user_id        ON public.designs_3d(user_id);
CREATE INDEX IF NOT EXISTS idx_designs_3d_flat_design_id ON public.designs_3d(flat_design_id);
CREATE INDEX IF NOT EXISTS idx_designs_3d_created_at     ON public.designs_3d(created_at DESC);

ALTER TABLE public.designs_3d ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own designs_3d" ON public.designs_3d;
CREATE POLICY "Users can manage own designs_3d"
ON public.designs_3d FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 4. updated_at triggers
-- ============================================================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_flat_designs_updated ON public.flat_designs;
CREATE TRIGGER on_flat_designs_updated
BEFORE UPDATE ON public.flat_designs
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS on_designs_3d_updated ON public.designs_3d;
CREATE TRIGGER on_designs_3d_updated
BEFORE UPDATE ON public.designs_3d
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 5. Seed data: design_options
-- ============================================================

-- silhouette level-1
INSERT INTO public.design_options (id, category, name, name_en, sort_order) VALUES
  ('10000000-0000-0000-0000-000000000001', 'silhouette', 'shangyi',   'Top',        1),
  ('10000000-0000-0000-0000-000000000002', 'silhouette', 'kuzi',      'Pants',      2),
  ('10000000-0000-0000-0000-000000000003', 'silhouette', 'qunzi',     'Skirt',      3),
  ('10000000-0000-0000-0000-000000000004', 'silhouette', 'waitao',    'Coat',       4),
  ('10000000-0000-0000-0000-000000000005', 'silhouette', 'lianyiqun', 'Dress',      5),
  ('10000000-0000-0000-0000-000000000006', 'silhouette', 'taozhuang', 'Suit',       6),
  ('10000000-0000-0000-0000-000000000007', 'silhouette', 'neiyi',     'Underwear',  7),
  ('10000000-0000-0000-0000-000000000008', 'silhouette', 'yundongfu', 'Sportswear', 8)
ON CONFLICT (id) DO NOTHING;

-- silhouette level-2: Top subtypes
INSERT INTO public.design_options (id, category, parent_id, name, name_en, sort_order, meta) VALUES
  ('10000000-0000-0000-0001-000000000001', 'silhouette', '10000000-0000-0000-0000-000000000001', 'T-xu', 'T-Shirt', 1,
    '{"params":[{"key":"chest","label":"chest(cm)","min":60,"max":130,"default":90},{"key":"length","label":"length(cm)","min":50,"max":90,"default":65}]}'),
  ('10000000-0000-0000-0001-000000000002', 'silhouette', '10000000-0000-0000-0000-000000000001', 'chenshan', 'Shirt', 2,
    '{"params":[{"key":"chest","label":"chest(cm)","min":60,"max":130,"default":92},{"key":"length","label":"length(cm)","min":55,"max":95,"default":70},{"key":"sleeve","label":"sleeve(cm)","min":40,"max":70,"default":58}]}'),
  ('10000000-0000-0000-0001-000000000003', 'silhouette', '10000000-0000-0000-0000-000000000001', 'weiyi', 'Hoodie', 3,
    '{"params":[{"key":"chest","label":"chest(cm)","min":70,"max":140,"default":100},{"key":"length","label":"length(cm)","min":55,"max":90,"default":68}]}'),
  ('10000000-0000-0000-0001-000000000004', 'silhouette', '10000000-0000-0000-0000-000000000001', 'beixin', 'Vest', 4,
    '{"params":[{"key":"chest","label":"chest(cm)","min":60,"max":120,"default":88},{"key":"length","label":"length(cm)","min":45,"max":75,"default":58}]}')
ON CONFLICT (id) DO NOTHING;

-- silhouette level-2: Pants subtypes
INSERT INTO public.design_options (id, category, parent_id, name, name_en, sort_order, meta) VALUES
  ('10000000-0000-0000-0002-000000000001', 'silhouette', '10000000-0000-0000-0000-000000000002', 'zhitongku', 'Straight Pants', 1,
    '{"params":[{"key":"waist","label":"waist(cm)","min":55,"max":110,"default":72},{"key":"hip","label":"hip(cm)","min":70,"max":130,"default":96},{"key":"length","label":"length(cm)","min":80,"max":115,"default":100}]}'),
  ('10000000-0000-0000-0002-000000000002', 'silhouette', '10000000-0000-0000-0000-000000000002', 'kuotuiku', 'Wide-leg Pants', 2,
    '{"params":[{"key":"waist","label":"waist(cm)","min":55,"max":110,"default":72},{"key":"hip","label":"hip(cm)","min":80,"max":140,"default":100},{"key":"length","label":"length(cm)","min":80,"max":115,"default":100}]}'),
  ('10000000-0000-0000-0002-000000000003', 'silhouette', '10000000-0000-0000-0000-000000000002', 'duanku', 'Shorts', 3,
    '{"params":[{"key":"waist","label":"waist(cm)","min":55,"max":110,"default":72},{"key":"length","label":"length(cm)","min":30,"max":60,"default":45}]}'),
  ('10000000-0000-0000-0002-000000000004', 'silhouette', '10000000-0000-0000-0000-000000000002', 'jinshenku', 'Skinny Pants', 4,
    '{"params":[{"key":"waist","label":"waist(cm)","min":55,"max":100,"default":70},{"key":"hip","label":"hip(cm)","min":70,"max":120,"default":92},{"key":"length","label":"length(cm)","min":80,"max":115,"default":100}]}')
ON CONFLICT (id) DO NOTHING;

-- silhouette level-2: Skirt subtypes
INSERT INTO public.design_options (id, category, parent_id, name, name_en, sort_order, meta) VALUES
  ('10000000-0000-0000-0003-000000000001', 'silhouette', '10000000-0000-0000-0000-000000000003', 'Aziqun', 'A-line Skirt', 1,
    '{"params":[{"key":"waist","label":"waist(cm)","min":55,"max":100,"default":68},{"key":"length","label":"length(cm)","min":40,"max":100,"default":65}]}'),
  ('10000000-0000-0000-0003-000000000002', 'silhouette', '10000000-0000-0000-0000-000000000003', 'baotunqun', 'Pencil Skirt', 2,
    '{"params":[{"key":"waist","label":"waist(cm)","min":55,"max":100,"default":68},{"key":"hip","label":"hip(cm)","min":70,"max":120,"default":92},{"key":"length","label":"length(cm)","min":40,"max":90,"default":60}]}'),
  ('10000000-0000-0000-0003-000000000003', 'silhouette', '10000000-0000-0000-0000-000000000003', 'baizhequn', 'Pleated Skirt', 3,
    '{"params":[{"key":"waist","label":"waist(cm)","min":55,"max":100,"default":68},{"key":"length","label":"length(cm)","min":40,"max":100,"default":65}]}'),
  ('10000000-0000-0000-0003-000000000004', 'silhouette', '10000000-0000-0000-0000-000000000003', 'banshengqun', 'Mini Skirt', 4,
    '{"params":[{"key":"waist","label":"waist(cm)","min":55,"max":100,"default":68},{"key":"length","label":"length(cm)","min":25,"max":50,"default":38}]}')
ON CONFLICT (id) DO NOTHING;

-- silhouette level-2: Coat subtypes
INSERT INTO public.design_options (id, category, parent_id, name, name_en, sort_order, meta) VALUES
  ('10000000-0000-0000-0004-000000000001', 'silhouette', '10000000-0000-0000-0000-000000000004', 'fengyi', 'Trench Coat', 1,
    '{"params":[{"key":"chest","label":"chest(cm)","min":70,"max":140,"default":100},{"key":"length","label":"length(cm)","min":80,"max":130,"default":105}]}'),
  ('10000000-0000-0000-0004-000000000002', 'silhouette', '10000000-0000-0000-0000-000000000004', 'yurongfu', 'Down Jacket', 2,
    '{"params":[{"key":"chest","label":"chest(cm)","min":70,"max":140,"default":102},{"key":"length","label":"length(cm)","min":55,"max":100,"default":72}]}'),
  ('10000000-0000-0000-0004-000000000003', 'silhouette', '10000000-0000-0000-0000-000000000004', 'xizhuang', 'Blazer', 3,
    '{"params":[{"key":"chest","label":"chest(cm)","min":70,"max":130,"default":96},{"key":"length","label":"length(cm)","min":60,"max":90,"default":72}]}'),
  ('10000000-0000-0000-0004-000000000004', 'silhouette', '10000000-0000-0000-0000-000000000004', 'jiake', 'Jacket', 4,
    '{"params":[{"key":"chest","label":"chest(cm)","min":70,"max":130,"default":98},{"key":"length","label":"length(cm)","min":50,"max":80,"default":62}]}')
ON CONFLICT (id) DO NOTHING;

-- pattern
INSERT INTO public.design_options (id, category, name, name_en, sort_order) VALUES
  ('20000000-0000-0000-0000-000000000001', 'pattern', 'chun_se',    'Solid',      1),
  ('20000000-0000-0000-0000-000000000002', 'pattern', 'tiao_wen',   'Stripes',    2),
  ('20000000-0000-0000-0000-000000000003', 'pattern', 'ge_wen',     'Plaid',      3),
  ('20000000-0000-0000-0000-000000000004', 'pattern', 'sui_hua',    'Floral',     4),
  ('20000000-0000-0000-0000-000000000005', 'pattern', 'ji_he',      'Geometric',  5),
  ('20000000-0000-0000-0000-000000000006', 'pattern', 'mi_cai',     'Camo',       6),
  ('20000000-0000-0000-0000-000000000007', 'pattern', 'dong_wu_wen','Animal',     7),
  ('20000000-0000-0000-0000-000000000008', 'pattern', 'zha_ran',    'Tie-dye',    8),
  ('20000000-0000-0000-0000-000000000009', 'pattern', 'yin_hua',    'Print',      9),
  ('20000000-0000-0000-0000-000000000010', 'pattern', 'ci_xiu',     'Embroidery', 10)
ON CONFLICT (id) DO NOTHING;

-- material
INSERT INTO public.design_options (id, category, name, name_en, sort_order) VALUES
  ('30000000-0000-0000-0000-000000000001', 'material', 'mian',      'Cotton',    1),
  ('30000000-0000-0000-0000-000000000002', 'material', 'ma',        'Linen',     2),
  ('30000000-0000-0000-0000-000000000003', 'material', 'si_chou',   'Silk',      3),
  ('30000000-0000-0000-0000-000000000004', 'material', 'yang_mao',  'Wool',      4),
  ('30000000-0000-0000-0000-000000000005', 'material', 'niu_zai',   'Denim',     5),
  ('30000000-0000-0000-0000-000000000006', 'material', 'pi_ge',     'Leather',   6),
  ('30000000-0000-0000-0000-000000000007', 'material', 'xue_fang',  'Chiffon',   7),
  ('30000000-0000-0000-0000-000000000008', 'material', 'zhen_zhi',  'Knit',      8),
  ('30000000-0000-0000-0000-000000000009', 'material', 'di_lun',    'Polyester', 9),
  ('30000000-0000-0000-0000-000000000010', 'material', 'tian_e_rong','Velvet',   10)
ON CONFLICT (id) DO NOTHING;

-- style
INSERT INTO public.design_options (id, category, name, name_en, sort_order) VALUES
  ('40000000-0000-0000-0000-000000000001', 'style', 'xiu_xian',    'Casual',     1),
  ('40000000-0000-0000-0000-000000000002', 'style', 'zheng_shi',   'Formal',     2),
  ('40000000-0000-0000-0000-000000000003', 'style', 'yun_dong',    'Sport',      3),
  ('40000000-0000-0000-0000-000000000004', 'style', 'jie_tou',     'Streetwear', 4),
  ('40000000-0000-0000-0000-000000000005', 'style', 'fu_gu',       'Vintage',    5),
  ('40000000-0000-0000-0000-000000000006', 'style', 'jian_yue',    'Minimalist', 6),
  ('40000000-0000-0000-0000-000000000007', 'style', 'bo_xi_mi_ya', 'Bohemian',   7),
  ('40000000-0000-0000-0000-000000000008', 'style', 'peng_ke',     'Punk',       8),
  ('40000000-0000-0000-0000-000000000009', 'style', 'xue_yuan',    'Preppy',     9),
  ('40000000-0000-0000-0000-000000000010', 'style', 'guo_chao',    'Guochao',    10)
ON CONFLICT (id) DO NOTHING;

-- audience
INSERT INTO public.design_options (id, category, name, name_en, sort_order) VALUES
  ('50000000-0000-0000-0000-000000000001', 'audience', 'nan_xing',   'Male',      1),
  ('50000000-0000-0000-0000-000000000002', 'audience', 'nv_xing',    'Female',    2),
  ('50000000-0000-0000-0000-000000000003', 'audience', 'er_tong',    'Children',  3),
  ('50000000-0000-0000-0000-000000000004', 'audience', 'lao_nian',   'Elderly',   4),
  ('50000000-0000-0000-0000-000000000005', 'audience', 'qing_shao_nian','Teen',   5),
  ('50000000-0000-0000-0000-000000000006', 'audience', 'zhi_chang',  'Office',    6),
  ('50000000-0000-0000-0000-000000000007', 'audience', 'yun_dong_yuan','Athlete', 7),
  ('50000000-0000-0000-0000-000000000008', 'audience', 'yun_fu',     'Maternity', 8)
ON CONFLICT (id) DO NOTHING;

-- ai_model
INSERT INTO public.design_options (id, category, name, name_en, sort_order, meta) VALUES
  ('60000000-0000-0000-0000-000000000001', 'ai_model', 'Stable Diffusion XL', 'SDXL',   1, '{"provider":"stability"}'),
  ('60000000-0000-0000-0000-000000000002', 'ai_model', 'DALL-E 3',            'DALLE3', 2, '{"provider":"openai"}'),
  ('60000000-0000-0000-0000-000000000003', 'ai_model', 'Midjourney v6',       'MJ6',    3, '{"provider":"midjourney"}'),
  ('60000000-0000-0000-0000-000000000004', 'ai_model', 'Flux.1',              'FLUX1',  4, '{"provider":"blackforest"}')
ON CONFLICT (id) DO NOTHING;

-- body_shape
INSERT INTO public.design_options (id, category, name, name_en, sort_order, meta) VALUES
  ('70000000-0000-0000-0000-000000000001', 'body_shape', 'biao_zhun', 'Standard', 1,
    '{"params":[{"key":"height","label":"height(cm)","min":140,"max":210,"default":170},{"key":"weight","label":"weight(kg)","min":40,"max":120,"default":65}]}'),
  ('70000000-0000-0000-0000-000000000002', 'body_shape', 'pian_shou', 'Slim',     2,
    '{"params":[{"key":"height","label":"height(cm)","min":140,"max":210,"default":170},{"key":"weight","label":"weight(kg)","min":40,"max":120,"default":55}]}'),
  ('70000000-0000-0000-0000-000000000003', 'body_shape', 'pian_pang', 'Plus',     3,
    '{"params":[{"key":"height","label":"height(cm)","min":140,"max":210,"default":170},{"key":"weight","label":"weight(kg)","min":40,"max":120,"default":80}]}'),
  ('70000000-0000-0000-0000-000000000004', 'body_shape', 'ji_rou_xing','Athletic',4,
    '{"params":[{"key":"height","label":"height(cm)","min":140,"max":210,"default":175},{"key":"weight","label":"weight(kg)","min":40,"max":120,"default":75}]}')
ON CONFLICT (id) DO NOTHING;

-- skin_color
INSERT INTO public.design_options (id, category, name, name_en, sort_order) VALUES
  ('80000000-0000-0000-0000-000000000001', 'skin_color', 'bai_xi',  'Fair',    1),
  ('80000000-0000-0000-0000-000000000002', 'skin_color', 'zi_ran',  'Natural', 2),
  ('80000000-0000-0000-0000-000000000003', 'skin_color', 'xiao_mai','Tan',     3),
  ('80000000-0000-0000-0000-000000000004', 'skin_color', 'shen_se', 'Dark',    4)
ON CONFLICT (id) DO NOTHING;

-- gender
INSERT INTO public.design_options (id, category, name, name_en, sort_order) VALUES
  ('90000000-0000-0000-0000-000000000001', 'gender', 'nan', 'Male',   1),
  ('90000000-0000-0000-0000-000000000002', 'gender', 'nv',  'Female', 2)
ON CONFLICT (id) DO NOTHING;

-- background
INSERT INTO public.design_options (id, category, name, name_en, sort_order, meta) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'background', 'white_bg',  'White',   1, '{"color":"#FFFFFF"}'),
  ('a0000000-0000-0000-0000-000000000002', 'background', 'black_bg',  'Black',   2, '{"color":"#000000"}'),
  ('a0000000-0000-0000-0000-000000000003', 'background', 'gray_bg',   'Gray',    3, '{"color":"#CCCCCC"}'),
  ('a0000000-0000-0000-0000-000000000004', 'background', 'outdoor',   'Outdoor', 4, '{"scene":"outdoor"}'),
  ('a0000000-0000-0000-0000-000000000005', 'background', 'runway',    'Runway',  5, '{"scene":"runway"}'),
  ('a0000000-0000-0000-0000-000000000006', 'background', 'street',    'Street',  6, '{"scene":"street"}')
ON CONFLICT (id) DO NOTHING;
