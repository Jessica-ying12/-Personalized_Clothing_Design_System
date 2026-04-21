from fastapi import Request


def is_private_ip(ip: str) -> bool:
    """检查是否是局域网 IP"""
    if not ip:
        return True

    private_ranges = [
        '127.0.0.1',
        '::1',
        '10.',
        '172.16.',
        '172.17.',
        '172.18.',
        '172.19.',
        '172.20.',
        '172.21.',
        '172.22.',
        '172.23.',
        '172.24.',
        '172.25.',
        '172.26.',
        '172.27.',
        '172.28.',
        '172.29.',
        '172.30.',
        '172.31.',
        '192.168.',
        '169.254.',
    ]
    return any(ip.startswith(prefix) for prefix in private_ranges)


def get_ip_addr(request: Request) -> str:
    headers = request.headers
    ip = headers.get('x-forwarded-for')
    if not ip or ip.lower() == 'unknown':
        ip = headers.get('Proxy-Client-IP')
    if not ip or ip.lower() == 'unknown':
        ip = headers.get('X-Forwarded-For')
    if not ip or ip.lower() == 'unknown':
        ip = headers.get('WL-Proxy-Client-IP')
    if not ip or ip.lower() == 'unknown':
        ip = headers.get('X-Real-IP')
    if not ip or ip.lower() == 'unknown':
        ip = request.client.host

    # 处理多级代理
    ip = get_multistage_reverse_proxy_ip(ip)

    # 过滤局域网 IP：如果获取到的是局域网 IP，尝试从直连获取
    if ip and is_private_ip(ip) and request.client:
        client_ip = request.client.host
        if client_ip and not is_private_ip(client_ip):
            ip = client_ip

    return '0:0:0:0:0:0:0:1' if ip == '::1' else ip


def get_multistage_reverse_proxy_ip(ip: str) -> str:
    # 多级反向代理检测
    if ip and ',' in ip:
        ips = ip.strip().split(',')
        # 优先返回公网 IP
        for sub_ip in ips:
            cleaned_ip = sub_ip.strip()
            if not is_unknown(cleaned_ip) and not is_private_ip(cleaned_ip):
                return cleaned_ip
        # 如果所有 IP 都是局域网，返回第一个非 unknown 的
        for sub_ip in ips:
            cleaned_ip = sub_ip.strip()
            if not is_unknown(cleaned_ip):
                return cleaned_ip
    return ip


def is_unknown(check_string: str) -> bool:
    return not check_string or check_string.lower() == 'unknown'


def get_ip_location(ip: str) -> dict:
    """
    根据IP地址获取地理位置信息

    :param ip: IP地址
    :return: 包含国家、省份、城市、区县的字典
    """
    # 检查是否是局域网IP
    if is_private_ip(ip):
        return {
            'country': '局域网',
            'province': '',
            'city': '',
            'district': '',
        }

    # 这里可以集成第三方IP地址库，如ip2region、GeoIP2等
    # 目前返回一个简单的示例实现
    # TODO: 集成真实的IP地址库进行查询

    try:
        import requests

        # 使用免费的IP查询API（示例）
        # 注意：生产环境建议使用本地IP数据库以提高性能和稳定性
        response = requests.get(f'http://ip-api.com/json/{ip}?lang=zh-CN', timeout=3)
        if response.status_code == 200:
            data = response.json()
            if data.get('status') == 'success':
                return {
                    'country': data.get('country', ''),
                    'province': data.get('regionName', ''),
                    'city': data.get('city', ''),
                    'district': '',
                }
    except Exception as e:
        # 记录异常但不中断程序，返回默认值
        import logging

        logging.getLogger(__name__).debug(f'IP地址查询失败: {ip}, 错误: {e!s}')

    # 如果查询失败，返回空信息
    return {
        'country': '未知',
        'province': '',
        'city': '',
        'district': '',
    }
