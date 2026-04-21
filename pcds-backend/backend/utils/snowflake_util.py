import threading
import time


class SnowflakeIdGenerator:
    """
    Snowflake ID 生成器

    64位结构:
    - 1位: 符号位(固定0)
    - 41位: 毫秒级时间戳(可用约69年)
    - 10位: 机器ID(0~1023)
    - 12位: 毫秒内序列号(0~4095)
    """

    # 起始时间戳: 2025-01-01 00:00:00 UTC (毫秒)
    EPOCH = 1735689600000

    MACHINE_ID_BITS = 10
    SEQUENCE_BITS = 12

    MAX_MACHINE_ID = (1 << MACHINE_ID_BITS) - 1  # 1023
    MAX_SEQUENCE = (1 << SEQUENCE_BITS) - 1  # 4095

    MACHINE_ID_SHIFT = SEQUENCE_BITS  # 12
    TIMESTAMP_SHIFT = MACHINE_ID_BITS + SEQUENCE_BITS  # 22

    def __init__(self, machine_id: int = 1):
        if not 0 <= machine_id <= self.MAX_MACHINE_ID:
            raise ValueError(f'machine_id 必须在 0~{self.MAX_MACHINE_ID} 之间')
        self._machine_id = machine_id
        self._sequence = 0
        self._last_timestamp = -1
        self._lock = threading.Lock()

    def _current_millis(self) -> int:
        return int(time.time() * 1000)

    def _wait_next_millis(self, last_timestamp: int) -> int:
        timestamp = self._current_millis()
        while timestamp <= last_timestamp:
            timestamp = self._current_millis()
        return timestamp

    def next_id(self) -> int:
        with self._lock:
            timestamp = self._current_millis()

            if timestamp < self._last_timestamp:
                raise RuntimeError(f'时钟回拨，拒绝生成ID，回拨 {self._last_timestamp - timestamp}ms')

            if timestamp == self._last_timestamp:
                self._sequence = (self._sequence + 1) & self.MAX_SEQUENCE
                if self._sequence == 0:
                    timestamp = self._wait_next_millis(self._last_timestamp)
            else:
                self._sequence = 0

            self._last_timestamp = timestamp

            return (
                ((timestamp - self.EPOCH) << self.TIMESTAMP_SHIFT)
                | (self._machine_id << self.MACHINE_ID_SHIFT)
                | self._sequence
            )


# 全局单例
snowflake = SnowflakeIdGenerator(machine_id=1)
