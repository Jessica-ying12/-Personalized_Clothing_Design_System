import type { Json } from "./json.ts";

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          full_name: string | null;
          avatar_url: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          full_name?: string | null;
          avatar_url?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          full_name?: string | null;
          avatar_url?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      design_options: {
        Row: {
          id: string;
          category: string;
          parent_id: string | null;
          name: string;
          name_en: string | null;
          sort_order: number;
          meta: Json | null;
          is_active: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          category: string;
          parent_id?: string | null;
          name: string;
          name_en?: string | null;
          sort_order?: number;
          meta?: Json | null;
          is_active?: boolean;
          created_at?: string;
        };
        Update: {
          id?: string;
          category?: string;
          parent_id?: string | null;
          name?: string;
          name_en?: string | null;
          sort_order?: number;
          meta?: Json | null;
          is_active?: boolean;
          created_at?: string;
        };
      };
      flat_designs: {
        Row: {
          id: string;
          user_id: string;
          silhouette_id: string | null;
          pattern_id: string | null;
          material_id: string | null;
          style_id: string | null;
          audience_id: string | null;
          ai_model_id: string | null;
          params: Json;
          image_url: string | null;
          status: string;
          error_msg: string | null;
          regen_count: number;
          is_saved: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          silhouette_id?: string | null;
          pattern_id?: string | null;
          material_id?: string | null;
          style_id?: string | null;
          audience_id?: string | null;
          ai_model_id?: string | null;
          params?: Json;
          image_url?: string | null;
          status?: string;
          error_msg?: string | null;
          regen_count?: number;
          is_saved?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          silhouette_id?: string | null;
          pattern_id?: string | null;
          material_id?: string | null;
          style_id?: string | null;
          audience_id?: string | null;
          ai_model_id?: string | null;
          params?: Json;
          image_url?: string | null;
          status?: string;
          error_msg?: string | null;
          regen_count?: number;
          is_saved?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      designs_3d: {
        Row: {
          id: string;
          user_id: string;
          flat_design_id: string;
          body_shape_id: string | null;
          skin_color_id: string | null;
          gender_id: string | null;
          ai_model_id: string | null;
          background_id: string | null;
          image_url: string | null;
          status: string;
          error_msg: string | null;
          regen_count: number;
          is_saved: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          flat_design_id: string;
          body_shape_id?: string | null;
          skin_color_id?: string | null;
          gender_id?: string | null;
          ai_model_id?: string | null;
          background_id?: string | null;
          image_url?: string | null;
          status?: string;
          error_msg?: string | null;
          regen_count?: number;
          is_saved?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          flat_design_id?: string;
          body_shape_id?: string | null;
          skin_color_id?: string | null;
          gender_id?: string | null;
          ai_model_id?: string | null;
          background_id?: string | null;
          image_url?: string | null;
          status?: string;
          error_msg?: string | null;
          regen_count?: number;
          is_saved?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
    };
    Views: Record<string, never>;
    Functions: {
      increment_flat_regen_count: {
        Args: { design_id: string };
        Returns: void;
      };
      increment_3d_regen_count: {
        Args: { design_id: string };
        Returns: void;
      };
    };
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
}

export type { Json };
