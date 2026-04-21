# rate_limiter.py
import time
from collections import defaultdict


class RateLimiter:
    def __init__(self):
        # 存储每个标识符的请求记录 {identifier: [timestamp1, timestamp2, ...]}
        self.requests: dict[str, list] = defaultdict(list)

    def is_allowed(self, identifier: str, max_requests: int, window: int) -> bool:
        """
        检查是否允许请求

        :param identifier: 唯一标识符（如IP地址、用户ID等）
        :param max_requests: 时间窗口内最大请求数
        :param window: 时间窗口（秒）
        :return: 是否允许请求
        """
        now = time.time()
        # 清理过期请求记录
        self.requests[identifier] = [req_time for req_time in self.requests[identifier] if now - req_time < window]

        # 检查是否超过限制
        if len(self.requests[identifier]) >= max_requests:
            return False

        # 记录当前请求
        self.requests[identifier].append(now)
        return True


# 全局限流器实例
rate_limiter = RateLimiter()
