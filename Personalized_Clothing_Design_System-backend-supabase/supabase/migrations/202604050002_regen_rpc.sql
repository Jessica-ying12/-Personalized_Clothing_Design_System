-- ============================================================
-- RPC：安全递增重新生成计数
-- ============================================================

CREATE OR REPLACE FUNCTION public.increment_flat_regen_count(design_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.flat_designs
  SET regen_count = regen_count + 1
  WHERE id = design_id AND user_id = auth.uid();
END;
$$;

CREATE OR REPLACE FUNCTION public.increment_3d_regen_count(design_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.designs_3d
  SET regen_count = regen_count + 1
  WHERE id = design_id AND user_id = auth.uid();
END;
$$;
