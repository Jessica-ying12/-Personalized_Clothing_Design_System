import re
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from exceptions.exception import ServiceError
from utils.log_util import logger


class CronUtil:
    """
    Cron表达式工具类
    """

    @classmethod
    def __valid_range(cls, search_str: str, start_range: int, end_range: int):
        match = re.match(r'^(\d+)-(\d+)$', search_str)
        if match:
            start, end = int(match.group(1)), int(match.group(2))
            return start_range <= start < end <= end_range
        return False

    @classmethod
    def __valid_sum(
        cls, search_str: str, start_range_a: int, start_range_b: int, end_range_a: int, end_range_b: int, sum_range: int
    ):
        match = re.match(r'^(\d+)/(\d+)$', search_str)
        if match:
            start, end = int(match.group(1)), int(match.group(2))
            return (
                start_range_a <= start <= start_range_b
                and end_range_a <= end <= end_range_b
                and start + end <= sum_range
            )
        return False

    @classmethod
    def validate_second_or_minute(cls, second_or_minute: str):
        """
        校验秒或分钟值是否正确

        :param second_or_minute: 秒或分钟值
        :return: 校验结果
        """
        if (
            second_or_minute == '*'
            or ('-' in second_or_minute and cls.__valid_range(second_or_minute, 0, 59))
            or ('/' in second_or_minute and cls.__valid_sum(second_or_minute, 0, 58, 1, 59, 59))
            or re.match(r'^(?:[0-5]?\d|59)(?:,[0-5]?\d|59)*$', second_or_minute)
        ):
            return True
        return False

    @classmethod
    def validate_hour(cls, hour: str):
        """
        校验小时值是否正确

        :param hour: 小时值
        :return: 校验结果
        """
        if (
            hour == '*'
            or ('-' in hour and cls.__valid_range(hour, 0, 23))
            or ('/' in hour and cls.__valid_sum(hour, 0, 22, 1, 23, 23))
            or re.match(r'^(?:0|[1-9]|1\d|2[0-3])(?:,(?:0|[1-9]|1\d|2[0-3]))*$', hour)
        ):
            return True
        return False

    @classmethod
    def validate_day(cls, day: str):
        """
        校验日值是否正确

        :param day: 日值
        :return: 校验结果
        """
        if (
            day in ['*', '?', 'L']
            or ('-' in day and cls.__valid_range(day, 1, 31))
            or ('/' in day and cls.__valid_sum(day, 1, 30, 1, 30, 31))
            or ('W' in day and re.match(r'^(?:[1-9]|1\d|2\d|3[01])W$', day))
            or re.match(r'^(?:0|[1-9]|1\d|2[0-9]|3[0-1])(?:,(?:0|[1-9]|1\d|2[0-9]|3[0-1]))*$', day)
        ):
            return True
        return False

    @classmethod
    def validate_month(cls, month: str):
        """
        校验月值是否正确

        :param month: 月值
        :return: 校验结果
        """
        if (
            month == '*'
            or ('-' in month and cls.__valid_range(month, 1, 12))
            or ('/' in month and cls.__valid_sum(month, 1, 11, 1, 11, 12))
            or re.match(r'^(?:0|[1-9]|1[0-2])(?:,(?:0|[1-9]|1[0-2]))*$', month)
        ):
            return True
        return False

    @classmethod
    def validate_week(cls, week: str):
        """
        校验周值是否正确

        :param week: 周值
        :return: 校验结果
        """
        if (
            week in ['*', '?']
            or ('-' in week and cls.__valid_range(week, 1, 7))
            or ('#' in week and re.match(r'^[1-7]#[1-4]$', week))
            or ('L' in week and re.match(r'^[1-7]L$', week))
            or re.match(r'^[1-7](?:(,[1-7]))*$', week)
        ):
            return True
        return False

    @classmethod
    def validate_year(cls, year: str):
        """
        校验年值是否正确

        :param year: 年值
        :return: 校验结果
        """
        current_year = int(datetime.now().year)
        future_years = [current_year + i for i in range(9)]
        if (
            year == '*'
            or ('-' in year and cls.__valid_range(year, current_year, 2099))
            or ('/' in year and cls.__valid_sum(year, current_year, 2098, 1, 2099 - current_year, 2099))
            or ('#' in year and re.match(r'^[1-7]#[1-4]$', year))
            or ('L' in year and re.match(r'^[1-7]L$', year))
            or (
                (len(year) == 4 or ',' in year)
                and all(int(item) in future_years and current_year <= int(item) <= 2099 for item in year.split(','))
            )
        ):
            return True
        return False

    @classmethod
    def validate_cron_expression(cls, cron_expression: str):
        """
        校验Cron表达式是否正确

        :param cron_expression: Cron表达式
        :return: 校验结果
        """
        values = cron_expression.split()
        if len(values) != 6 and len(values) != 7:
            return False
        second_validation = cls.validate_second_or_minute(values[0])
        minute_validation = cls.validate_second_or_minute(values[1])
        hour_validation = cls.validate_hour(values[2])
        day_validation = cls.validate_day(values[3])
        month_validation = cls.validate_month(values[4])
        week_validation = cls.validate_week(values[5])
        validation = (
            second_validation
            and minute_validation
            and hour_validation
            and day_validation
            and month_validation
            and week_validation
        )
        if len(values) == 6:
            return validation
        if len(values) == 7:
            year_validation = cls.validate_year(values[6])
            return validation and year_validation
        return None

    @classmethod
    def generate_cron_expression(
        cls, feeding_hour: int, feeding_minute: int, timezone: str, cycle_type: str, week_cycle: str | None = None
    ):
        """
        生成Cron表达式
        :param feeding_hour: 小时(0-23)
        :param feeding_minute: 分钟(0-59)
        :param timezone: 用户设备所在的时区
        :param cycle_type: 周期类型('0': 周期, '1': 一次性, '2': 每天)
        :param week_cycle: 周期喂食的周数字, 例如 "1,3,5"
        :return: Cron表达式
        """
        server_tz = datetime.now().astimezone().tzinfo
        try:
            user_tz = ZoneInfo(timezone)
        except Exception:
            logger.warning(f'无效的时区: {timezone}，默认使用服务器时区: {server_tz}')
            user_tz = server_tz  # type: ignore

        now_in_user_tz = datetime.now(user_tz)
        base_user_day = now_in_user_tz.replace(hour=0, minute=0, second=0, microsecond=0)
        user_dt_aware = base_user_day + timedelta(hours=int(feeding_hour), minutes=int(feeding_minute))
        server_dt_aware = user_dt_aware.astimezone(server_tz)

        second = 0
        minute = server_dt_aware.minute
        hour = server_dt_aware.hour

        if cycle_type == '0':
            week_value = week_cycle if week_cycle else '*'
            if not week_cycle:
                raise ServiceError(message='周期未提供')
            cron_expression = f'{second} {minute} {hour} ? * {week_value}'

        elif cycle_type == '1':
            target_time = server_dt_aware
            now_server_time = datetime.now(server_tz)
            # 如果目标时间小于当前时间，则将目标时间推迟到第二天执行
            if target_time < now_server_time:
                target_time += timedelta(days=1)
            cron_expression = f'{second} {target_time.minute} {target_time.hour} {target_time.day} {target_time.month} ? {target_time.year}'

        elif cycle_type == '2':
            cron_expression = f'{second} {minute} {hour} ? * *'

        else:
            raise ServiceError(message='未知的周期类型')

        if not cls.validate_cron_expression(cron_expression):
            raise ServiceError(message='Cron表达式校验失败')
        return cron_expression
