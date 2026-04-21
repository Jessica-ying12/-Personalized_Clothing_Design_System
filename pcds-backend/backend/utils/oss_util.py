import asyncio
import base64
import hashlib
import hmac
import uuid
from datetime import datetime, timezone
from urllib.parse import quote, urlparse

import httpx
from fastapi import UploadFile
from loguru import logger

from module_hammer import HammerConfig


class AliyunOSSUtil:
    """阿里云OSS工具类 - 完全异步实现"""

    def __init__(self):
        """初始化OSS配置"""
        self.access_key_id = HammerConfig.aliyun_access_key_id
        self.access_key_secret = HammerConfig.aliyun_access_key_secret
        self.endpoint = HammerConfig.aliyun_oss_endpoint
        self.bucket_name = HammerConfig.aliyun_oss_bucket_name
        self.static_url = HammerConfig.static_url

        # 构建 OSS 基础 URL
        self.oss_host = f'{self.bucket_name}.{self.endpoint}'
        self.oss_url = f'https://{self.oss_host}'

        # 并发控制信号量（限制同时进行的上传数量）
        self.upload_semaphore = asyncio.Semaphore(5)

        # HTTP客户端配置
        self.http_timeout = httpx.Timeout(
            connect=10.0,  # 连接超时
            read=300.0,  # 读取超时
            write=300.0,  # 写入超时
            pool=60.0,  # 连接池超时
        )

        # 连接池限制
        self.http_limits = httpx.Limits(max_keepalive_connections=10, max_connections=20)

    @staticmethod
    def _remove_url_signature(image_url: str) -> str:
        """
        处理URL中的签名参数，确保特殊字符正确编码
        支持多种云服务的签名格式：
        - 阿里云 OSS: Signature=
        - 华为云 OBS: Signature= (AWS S3 兼容格式)
        - 腾讯云 COS: sign=
        """
        try:
            from urllib.parse import parse_qs, urlparse, urlunparse

            # 解析 URL
            parsed = urlparse(image_url)
            query_params = parse_qs(parsed.query, keep_blank_values=True)

            # 检查是否包含签名参数
            signature_keys = ['Signature', 'sign', 'signature']
            has_signature = any(key in query_params for key in signature_keys)

            if has_signature:
                # 重新编码查询参数，确保特殊字符正确处理
                encoded_params = []
                for key, values in query_params.items():
                    for value in values:
                        # 对签名值进行特殊处理
                        if key in signature_keys:
                            # 确保 + 号被正确编码为 %2B
                            encoded_value = value.replace('+', '%2B')
                            encoded_params.append(f'{key}={encoded_value}')
                        else:
                            encoded_params.append(f'{key}={value}')

                # 重新构建 URL
                new_query = '&'.join(encoded_params)
                new_parsed = parsed._replace(query=new_query)
                return urlunparse(new_parsed)

            return image_url

        except Exception as e:
            logger.warning(f'处理URL签名时出错: {e}, 将使用原始URL')
            return image_url

    @staticmethod
    def _get_file_extension(url: str) -> str:
        """从URL中获取文件扩展名"""
        try:
            parsed_url = urlparse(url)
            path = parsed_url.path
            if '.' in path:
                return path[path.rfind('.') :]
            return '.jpg'  # 默认扩展名
        except Exception:
            return '.jpg'

    @staticmethod
    def _generate_folder_name() -> str:
        """生成基于时间的文件夹名称"""
        import time

        return hex(int(time.time() * 1000000))[2:]

    @staticmethod
    def _generate_date_folder_name() -> str:
        """生成基于日期的文件夹名称，格式为 YYYY/MM/DD"""
        from datetime import datetime

        now = datetime.now()
        return f"{now.strftime('%Y')}/{now.strftime('%m')}/{now.strftime('%d')}"

    def _get_domain(self) -> str:
        """获取OSS域名"""
        return self.static_url if self.static_url else self.oss_url

    def _generate_oss_signature(self, method: str, object_name: str, content_type: str = 'image/jpeg') -> dict:
        """
        生成 OSS REST API 签名

        Args:
            method: HTTP 方法 (PUT)
            object_name: OSS 对象名称
            content_type: 内容类型

        Returns:
            包含签名信息的请求头
        """
        # 生成 GMT 时间
        gmt_time = datetime.now(timezone.utc).strftime('%a, %d %b %Y %H:%M:%S GMT')

        # 构建待签名字符串
        string_to_sign = f'{method}\n\n{content_type}\n{gmt_time}\n/{self.bucket_name}/{object_name}'

        # 计算签名
        signature = base64.b64encode(
            hmac.new(self.access_key_secret.encode('utf-8'), string_to_sign.encode('utf-8'), hashlib.sha1).digest()
        ).decode('utf-8')

        # 构建授权头
        authorization = f'OSS {self.access_key_id}:{signature}'

        return {'Authorization': authorization, 'Date': gmt_time, 'Content-Type': content_type, 'Host': self.oss_host}

    async def upload_file_with_custom_folder(
        self, file: 'UploadFile', base_folder: str, custom_folder: str | None = None
    ) -> str:
        """
        上传文件到OSS，支持自定义文件夹

        Args:
            file: FastAPI的UploadFile对象
            base_folder: 基础存储文件夹
            custom_folder: 自定义文件夹名称（可选）

        Returns:
            上传成功返回OSS文件的完整URL

        Raises:
            Exception: 文件上传失败
        """
        async with self.upload_semaphore:
            try:
                logger.info(
                    f'开始上传文件到OSS，基础文件夹: {base_folder}, 自定义文件夹: {custom_folder}, 文件名: {file.filename}'
                )

                # 生成唯一文件名
                file_extension = self._get_file_extension(file.filename)
                unique_filename = f'{uuid.uuid4()}{file_extension}'

                # 生成日期文件夹
                date_folder = self._generate_date_folder_name()

                # 构建对象路径：基础文件夹/自定义文件夹/日期文件夹/唯一文件名
                if custom_folder:
                    object_name = f'{base_folder}/{custom_folder}/{date_folder}/{unique_filename}'
                else:
                    object_name = f'{base_folder}/{date_folder}/{unique_filename}'

                logger.info(f'OSS对象路径: {object_name}')

                # 读取文件内容
                image_data = await file.read()

                # 完全异步的 OSS 上传
                await self._async_upload_to_oss(object_name, image_data)

                # 构建并返回文件的完整URL
                file_url = f'{self._get_domain()}/{object_name}'
                logger.info(f'文件上传成功: {file_url}')
                return file_url

            except Exception as e:
                logger.error(f'文件上传失败: {e}')
                logger.exception('文件上传异常详情:')
                raise

    async def upload_file(self, file: 'UploadFile', folder: str = 'default') -> str:
        """
        从本地直接上传文件到OSS

        Args:
            file: FastAPI的UploadFile对象
            folder: 存储文件夹

        Returns:
            上传成功返回OSS文件的完整URL

        Raises:
            Exception: 文件上传失败
        """
        async with self.upload_semaphore:
            try:
                # 生成唯一文件名
                file_extension = self._get_file_extension(file.filename)
                unique_filename = f'{uuid.uuid4()}{file_extension}'
                object_name = f'{folder}/{self._generate_folder_name()}/{unique_filename}'

                # 读取文件内容
                image_data = await file.read()

                # 完全异步的 OSS 上传
                await self._async_upload_to_oss(object_name, image_data)

                # 构建并返回文件的完整URL
                file_url = f'{self._get_domain()}/{object_name}'
                logger.info(f'文件上传成功: {file_url}')
                return file_url

            except Exception as e:
                logger.exception(e)
                raise

    async def upload_lang_page_file(
        self, file: 'UploadFile', folder: str = 'default', lang_page_code: str = 'default'
    ) -> tuple[str, str]:
        """
        从本地直接上传文件到OSS

        Args:
            file: FastAPI的UploadFile对象
            folder: 存储文件夹

        Returns:
            tuple: (文件URL, 对象名称)

        Raises:
            Exception: 文件上传失败
        """
        async with self.upload_semaphore:
            try:
                object_name = f'{folder}/{lang_page_code}/{file.filename}'

                # 读取文件内容
                image_data = await file.read()

                # 完全异步的 OSS 上传
                await self._async_upload_to_oss(object_name, image_data)

                # 构建并返回文件的完整URL
                file_url = f'{self._get_domain()}/{object_name}'
                logger.info(f'文件上传成功: {file_url}')
                return file_url, object_name

            except Exception as e:
                logger.exception(e)
                raise

    async def upload_image_from_url(self, image_url: str, folder: str = 'capture') -> str:
        """
        从URL下载图片并上传到OSS

        Args:
            image_url: 图片URL
            folder: 存储文件夹

        Returns:
            上传成功返回OSS文件路径

        Raises:
            httpx.RequestError: 网络请求错误
            httpx.HTTPStatusError: HTTP状态错误
            Exception: 其他上传错误
        """
        async with self.upload_semaphore:  # 控制并发数量
            try:
                # 处理URL签名
                clean_url = self._remove_url_signature(image_url)

                # 生成唯一文件名
                file_extension = self._get_file_extension(clean_url)
                unique_filename = f'{uuid.uuid4()}{file_extension}'
                object_name = f'{folder}/{self._generate_folder_name()}/{unique_filename}'

                # 异步下载图片
                async with httpx.AsyncClient(timeout=self.http_timeout, limits=self.http_limits) as client:
                    response = await client.get(image_url)
                    response.raise_for_status()
                    image_data = response.content

                # 完全异步的 OSS 上传
                await self._async_upload_to_oss(object_name, image_data)

                logger.info(f'图片上传成功: {object_name}')
                return object_name

            except httpx.RequestError as e:
                logger.error(f'网络请求失败: {e}')
                raise

            except httpx.HTTPStatusError as e:
                status_code = e.response.status_code

                if status_code == 403:
                    logger.error(f'HTTP 403 Forbidden 错误: {e}')
                    logger.error('可能原因: 1) 签名已过期 2) 签名格式错误 3) 访问权限不足')
                    logger.error(f'请求 URL: {clean_url}')
                elif status_code in [404, 401]:
                    logger.error(f'HTTP错误 {status_code}: {e}')
                else:
                    logger.error(f'HTTP错误 {status_code}: {e}')

                raise

            except Exception as e:
                logger.error(f'图片上传失败: {e}')
                raise

    async def _async_upload_to_oss(self, object_name: str, image_data: bytes) -> None:
        """完全异步上传到OSS（使用 REST API）"""
        try:
            # 检测内容类型
            content_type = 'image/jpeg'
            if object_name.lower().endswith('.png'):
                content_type = 'image/png'
            elif object_name.lower().endswith('.gif'):
                content_type = 'image/gif'
            elif object_name.lower().endswith('.webp'):
                content_type = 'image/webp'
            elif object_name.lower().endswith('.mp4'):
                content_type = 'video/mp4'
            elif object_name.lower().endswith('.mov'):
                content_type = 'video/quicktime'
            elif object_name.lower().endswith('.json'):
                content_type = 'application/json'
            elif object_name.lower().endswith('.apk'):
                content_type = 'application/vnd.android.package-archive'

            # 生成签名
            headers = self._generate_oss_signature('PUT', object_name, content_type)

            # 构建上传 URL
            upload_url = f'{self.oss_url}/{object_name}'

            # 异步上传到 OSS
            async with httpx.AsyncClient(timeout=self.http_timeout, limits=self.http_limits) as client:
                response = await client.put(upload_url, content=image_data, headers=headers)
                response.raise_for_status()

            logger.debug(f'成功异步上传 {len(image_data)} 字节到 OSS: {object_name}')

        except httpx.HTTPStatusError as e:
            logger.error(f'OSS 上传 HTTP 错误 {e.response.status_code}: {e}')
            logger.error(f'响应内容: {e.response.text}')
            raise
        except Exception as e:
            logger.error(f'异步上传到OSS失败: {e}')
            raise

    async def delete_file(self, object_name: str) -> bool:
        """
        删除OSS中的单个文件

        Args:
            object_name: OSS对象名称（文件路径）

        Returns:
            删除成功返回True，失败返回False

        Raises:
            Exception: 删除失败时抛出异常
        """
        try:
            # 生成删除操作的签名
            headers = self._generate_oss_signature('DELETE', object_name)

            # 构建删除 URL
            delete_url = f'{self.oss_url}/{object_name}'

            # 异步删除文件
            async with httpx.AsyncClient(timeout=self.http_timeout, limits=self.http_limits) as client:
                response = await client.delete(delete_url, headers=headers)

                # OSS删除操作：200表示删除成功，404表示文件不存在（也算成功）
                if response.status_code in [200, 204, 404]:
                    logger.info(f'文件删除成功: {object_name}')
                    return True
                logger.error(f'文件删除失败，状态码: {response.status_code}, 响应: {response.text}')
                return False

        except httpx.HTTPStatusError as e:
            if e.response.status_code == 404:
                logger.info(f'文件不存在，视为删除成功: {object_name}')
                return True
            logger.error(f'删除文件HTTP错误 {e.response.status_code}: {e}')
            logger.error(f'响应内容: {e.response.text}')
            raise
        except Exception as e:
            logger.error(f'删除文件失败: {object_name}, 错误: {e}')
            raise

    async def delete_files(self, object_names: list[str]) -> dict[str, bool]:
        """
        批量删除OSS中的文件

        Args:
            object_names: OSS对象名称列表

        Returns:
            删除结果字典，键为文件名，值为删除是否成功
        """
        results = {}

        # 使用信号量控制并发删除数量
        async def delete_single_file(object_name: str) -> tuple[str, bool]:
            async with self.upload_semaphore:  # 复用上传的信号量来控制并发
                try:
                    success = await self.delete_file(object_name)
                    return object_name, success
                except Exception as e:
                    logger.error(f'批量删除中单个文件失败: {object_name}, 错误: {e}')
                    return object_name, False

        # 并发执行删除操作
        tasks = [delete_single_file(obj_name) for obj_name in object_names]
        delete_results = await asyncio.gather(*tasks, return_exceptions=True)

        # 处理结果
        for result in delete_results:
            if isinstance(result, Exception):
                logger.error(f'批量删除任务异常: {result}')
                continue

            if isinstance(result, tuple):
                object_name, success = result
                results[object_name] = success

        # 统计删除结果
        success_count = sum(1 for success in results.values() if success)
        total_count = len(object_names)
        logger.info(f'批量删除完成: 成功 {success_count}/{total_count}')

        return results

    async def delete_folder(self, folder_prefix: str) -> dict[str, int]:
        """
        删除OSS中指定前缀的所有文件（模拟删除文件夹）

        Args:
            folder_prefix: 文件夹前缀，例如 "images/2024/"

        Returns:
            删除结果统计: {"total": 总数, "success": 成功数, "failed": 失败数}
        """
        try:
            # 确保前缀以 / 结尾
            if not folder_prefix.endswith('/'):
                folder_prefix += '/'

            # 列出指定前缀的所有文件
            file_list = await self._list_objects_with_prefix(folder_prefix)

            if not file_list:
                logger.info(f'文件夹为空或不存在: {folder_prefix}')
                return {'total': 0, 'success': 0, 'failed': 0}

            # 批量删除文件
            delete_results = await self.delete_files(file_list)

            # 统计结果
            total = len(delete_results)
            success = sum(1 for success in delete_results.values() if success)
            failed = total - success

            result = {'total': total, 'success': success, 'failed': failed}
            logger.info(f'文件夹删除完成: {folder_prefix}, 结果: {result}')

            return result

        except Exception as e:
            logger.error(f'删除文件夹失败: {folder_prefix}, 错误: {e}')
            raise

    async def _list_objects_with_prefix(self, prefix: str, max_keys: int = 1000) -> list[str]:
        """
        列出指定前缀的所有对象

        Args:
            prefix: 对象前缀
            max_keys: 最大返回数量

        Returns:
            对象名称列表
        """
        try:
            # 构建查询参数
            params = {'list-type': '2', 'prefix': prefix, 'max-keys': str(max_keys)}

            # 生成签名（GET请求）
            query_string = '&'.join([f'{k}={quote(str(v))}' for k, v in params.items()])
            resource = f'/{self.bucket_name}/?{query_string}'

            # 生成 GMT 时间
            gmt_time = datetime.now(timezone.utc).strftime('%a, %d %b %Y %H:%M:%S GMT')

            # 构建待签名字符串
            string_to_sign = f'GET\n\n\n{gmt_time}\n{resource}'

            # 计算签名
            signature = base64.b64encode(
                hmac.new(self.access_key_secret.encode('utf-8'), string_to_sign.encode('utf-8'), hashlib.sha1).digest()
            ).decode('utf-8')

            # 构建请求头
            headers = {
                'Authorization': f'OSS {self.access_key_id}:{signature}',
                'Date': gmt_time,
                'Host': self.oss_host,
            }

            # 发送请求
            list_url = f'{self.oss_url}/?{query_string}'

            async with httpx.AsyncClient(timeout=self.http_timeout, limits=self.http_limits) as client:
                response = await client.get(list_url, headers=headers)
                response.raise_for_status()

                # 解析XML响应
                import xml.etree.ElementTree as ET

                root = ET.fromstring(response.text)

                # 提取对象名称
                object_names = [
                    content.text
                    for content in root.findall('.//{http://s3.amazonaws.com/doc/2006-03-01/}Key')
                    if content.text
                ]

                logger.debug(f'列出前缀 {prefix} 的对象数量: {len(object_names)}')
                return object_names

        except Exception as e:
            logger.error(f'列出对象失败: {prefix}, 错误: {e}')
            raise

    def _generate_delete_signature(self, object_name: str) -> dict:
        """
        生成删除操作的签名（兼容方法，实际使用 _generate_oss_signature）

        Args:
            object_name: OSS 对象名称

        Returns:
            包含签名信息的请求头
        """
        return self._generate_oss_signature('DELETE', object_name)
