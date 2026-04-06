-- 创建 Storage Bucket 用于存储设计图片
-- Migration: 202604050003_storage_bucket.sql

-- 插入 bucket（如果不存在）
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'designs',
    'designs',
    true,  -- 公开访问
    10485760,  -- 10MB 限制
    ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 创建 Storage RLS 策略：用户只能上传自己的文件
CREATE POLICY "Users can upload their own files"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'designs' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- 创建 Storage RLS 策略：所有人可以读取公开文件
CREATE POLICY "Public files are accessible to all"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'designs');

-- 创建 Storage RLS 策略：用户可以删除自己的文件
CREATE POLICY "Users can delete their own files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'designs' AND
    auth.uid()::text = (storage.foldername(name))[1]
);
