import json
import random
import re
import string
import time
from collections import OrderedDict
from pathlib import Path
from typing import Any, Literal

from sqlalchemy import inspect
from sqlalchemy.engine.row import Row
from sqlalchemy.orm.collections import InstrumentedList

from config.database import Base
from config.env import CachePathConfig


def worship():
    print("""
////////////////////////////////////////////////////////////////////
//                          _ooOoo_                               //
//                         o8888888o                              //
//                         88" . "88                              //
//                         (| ^_^ |)                              //
//                         O\\  =  /O                              //
//                      ____/`---'\\____                           //
//                    .'  \\|     |//  `.                         //
//                   /  \\|||  :  |||//  \\                        //
//                  /  _||||| -:- |||||-  \\                       //
//                  |   | \\\\  -  /// |   |                       //
//                  | \\_|  ''\\---/''  |   |                       //
//                  \\  .-\\__  `-`  ___/-. /                       //
//                ___`. .'  /--.--\\  `. . ___                     //
//              ."" '<  `.___\\_<|>_/___.'  >'"".                  //
//            | | :  `- \\`.;`\\ _ /`;.`/ - ` : | |                 //
//            \\  \\ `-.   \\_ __\\ /__ _/   .-` /  /                 //
//      ========`-.____`-.___\\_____/___.-`____.-'========         //
//                           `=---='                              //
//      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        //
//             佛祖保佑       永不宕机      永无BUG                 //
////////////////////////////////////////////////////////////////////
    """)


class SqlalchemyUtil:
    """
    sqlalchemy工具类
    """

    @classmethod
    def base_to_dict(
        cls, obj: Base | dict, transform_case: Literal['no_case', 'snake_to_camel', 'camel_to_snake'] = 'no_case'
    ):
        """
        将sqlalchemy模型对象转换为字典

        :param obj: sqlalchemy模型对象或普通字典
        :param transform_case: 转换得到的结果形式，可选的有'no_case'(不转换)、'snake_to_camel'(下划线转小驼峰)、'camel_to_snake'(小驼峰转下划线)，默认为'no_case'
        :return: 字典结果
        """
        if isinstance(obj, Base):
            base_dict = obj.__dict__.copy()
            base_dict.pop('_sa_instance_state', None)
            for name, value in base_dict.items():
                if isinstance(value, InstrumentedList):
                    base_dict[name] = cls.serialize_result(value, 'snake_to_camel')
        elif isinstance(obj, dict):
            base_dict = obj.copy()
        if transform_case == 'snake_to_camel':
            return {
                CamelCaseUtil.snake_to_camel(k): cls.serialize_result(v, 'snake_to_camel') for k, v in base_dict.items()
            }
        if transform_case == 'camel_to_snake':
            return {
                SnakeCaseUtil.camel_to_snake(k): cls.serialize_result(v, 'camel_to_snake') for k, v in base_dict.items()
            }

        return base_dict

    @classmethod
    def serialize_result(
        cls, result: Any, transform_case: Literal['no_case', 'snake_to_camel', 'camel_to_snake'] = 'no_case'
    ):
        """
        将sqlalchemy查询结果序列化

        :param result: sqlalchemy查询结果
        :param transform_case: 转换得到的结果形式，可选的有'no_case'(不转换)、'snake_to_camel'(下划线转小驼峰)、'camel_to_snake'(小驼峰转下划线)，默认为'no_case'
        :return: 序列化结果
        """
        if isinstance(result, Base | dict):
            return cls.base_to_dict(result, transform_case)
        if isinstance(result, list):
            return [cls.serialize_result(row, transform_case) for row in result]
        if isinstance(result, Row):
            if all(isinstance(row, Base) for row in result):
                return [cls.base_to_dict(row, transform_case) for row in result]
            if any(isinstance(row, Base) for row in result):
                return [cls.serialize_result(row, transform_case) for row in result]
            result_dict = result._asdict()
            if transform_case == 'snake_to_camel':
                return {CamelCaseUtil.snake_to_camel(k): v for k, v in result_dict.items()}
            if transform_case == 'camel_to_snake':
                return {SnakeCaseUtil.camel_to_snake(k): v for k, v in result_dict.items()}
            return result_dict
        return result


class CamelCaseUtil:
    """
    下划线形式(snake_case)转小驼峰形式(camelCase)工具方法
    """

    @classmethod
    def snake_to_camel(cls, snake_str: str):
        """
        下划线形式字符串(snake_case)转换为小驼峰形式字符串(camelCase)

        :param snake_str: 下划线形式字符串
        :return: 小驼峰形式字符串
        """
        # 分割字符串
        words = snake_str.split('_')
        # 小驼峰命名，第一个词首字母小写，其余词首字母大写
        return words[0] + ''.join(word.capitalize() for word in words[1:])

    @classmethod
    def transform_result(cls, result: Any):
        """
        针对不同类型将下划线形式(snake_case)批量转换为小驼峰形式(camelCase)方法

        :param result: 输入数据
        :return: 小驼峰形式结果
        """
        return SqlalchemyUtil.serialize_result(result=result, transform_case='snake_to_camel')


class SnakeCaseUtil:
    """
    小驼峰形式(camelCase)转下划线形式(snake_case)工具方法
    """

    @classmethod
    def camel_to_snake(cls, camel_str: str):
        """
        小驼峰形式字符串(camelCase)转换为下划线形式字符串(snake_case)

        :param camel_str: 小驼峰形式字符串
        :return: 下划线形式字符串
        """
        # 在大写字母前添加一个下划线，然后将整个字符串转为小写
        words = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', camel_str)
        return re.sub('([a-z0-9])([A-Z])', r'\1_\2', words).lower()

    @classmethod
    def transform_result(cls, result: Any):
        """
        针对不同类型将下划线形式(snake_case)批量转换为小驼峰形式(camelCase)方法

        :param result: 输入数据
        :return: 小驼峰形式结果
        """
        return SqlalchemyUtil.serialize_result(result=result, transform_case='camel_to_snake')


def bytes2human(n, format_str='%(value).1f%(symbol)s'):
    """Used by various scripts. See:
    http://goo.gl/zeJZl

    >>> bytes2human(10000)
    '9.8K'
    >>> bytes2human(100001221)
    '95.4M'
    """
    symbols = ('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')
    prefix = {}
    for i, s in enumerate(symbols[1:]):
        prefix[s] = 1 << (i + 1) * 10
    for symbol in reversed(symbols[1:]):
        if n >= prefix[symbol]:
            value = float(n) / prefix[symbol]
            return format_str % locals()
    return format_str % dict(symbol=symbols[0], value=n)


def bytes2file_response(bytes_info):
    yield bytes_info


def get_filepath_from_url(url: str):
    """
    工具方法：根据请求参数获取文件路径

    :param url: 请求参数中的url参数
    :return: 文件路径
    """
    file_info = url.split('?')[1].split('&')
    task_id = file_info[0].split('=')[1]
    file_name = file_info[1].split('=')[1]
    task_path = file_info[2].split('=')[1]
    return str(Path(CachePathConfig.PATH) / task_path / task_id / file_name)


def model_to_dict(obj):
    if obj is None:
        return {}
    _dict = None
    try:
        _dict = dict(obj)
    except Exception:
        try:
            _dict = {
                c.key: getattr(obj, c.key) for c in inspect(obj).mapper.column_attrs if getattr(obj, c.key) is not None
            }
        except Exception:
            _dict = {k: v for k, v in obj.__dict__.items() if not k.startswith('_')}
    return _dict


def dict_to_model(model_class, data_dict):
    """根据字典数据创建或更新模型对象，过滤 SQLAlchemy 内部属性"""
    # 过滤掉以 "_" 开头的键，这些通常是 SQLAlchemy 的内部属性
    filtered_data = {k: v for k, v in data_dict.items() if not k.startswith('_')}
    return model_class(**filtered_data)


def get_mapping_dict(t, exclude_fields=None, is_camel=True) -> dict:
    if exclude_fields is None:
        exclude_fields = []

    # 提取字段名
    exclude_field_names = {field.name for field in exclude_fields}

    field_comments = OrderedDict()
    for column in t.__table__.columns:
        if column.name not in exclude_field_names:
            if is_camel:
                field_comments[CamelCaseUtil.snake_to_camel(column.name)] = column.comment
            else:
                field_comments[column.name] = column.comment
    return field_comments


def generate_random_string(length=10):
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))


def generate_instance_uuid():
    part1 = generate_random_string(10)
    part2 = generate_random_string(8)
    return f'{part1}-{part2}'


def generate_serial_number(prefix=''):
    """
    生成18位数字流水号，包含时间戳和随机数
    :return: 生成的流水号
    """
    # 获取当前时间戳（毫秒）
    timestamp = int(round(time.time() * 1000))
    # 将时间戳转换为字符串
    timestamp_str = str(timestamp)
    # 生成随机数
    random_str = str(random.randint(0, 99999)).zfill(18 - len(timestamp_str))
    # 拼接时间戳和随机数
    serial_number = timestamp_str + random_str
    return prefix + serial_number


def generate_eight_serial_number(prefix=''):
    """
    生成8位数字流水号,包含时间戳和随机数
    :return: 生成的流水号
    """
    # 获取当前时间戳(秒级)后6位
    timestamp = int(time.time())
    timestamp_str = str(timestamp)[-6:]
    # 生成2位随机数
    random_str = str(random.randint(0, 99)).zfill(2)
    # 拼接时间戳和随机数
    serial_number = timestamp_str + random_str
    return prefix + serial_number


def is_json(myjson):
    try:
        json.loads(myjson)
    except ValueError:
        return False
    return True


def compare_version_names(version1: str, version2: str) -> int:
    """
    比较两个版本名称的大小

    :param version1: 版本名称1
    :param version2: 版本名称2
    :return: 如果version1 > version2返回1，如果version1 < version2返回-1，相等返回0
    """
    # 分割版本号，例如 "1.2.3" 分割为 ["1", "2", "3"]
    v1_parts = version1.split('.')
    v2_parts = version2.split('.')

    # 获取最大长度，确保可以比较所有部分
    max_length = max(len(v1_parts), len(v2_parts))

    # 逐个比较各部分
    for i in range(max_length):
        # 获取当前部分，如果不存在则为0
        v1_part = int(v1_parts[i]) if i < len(v1_parts) and v1_parts[i].isdigit() else 0
        v2_part = int(v2_parts[i]) if i < len(v2_parts) and v2_parts[i].isdigit() else 0

        if v1_part > v2_part:
            return 1
        if v1_part < v2_part:
            return -1

    return 0
