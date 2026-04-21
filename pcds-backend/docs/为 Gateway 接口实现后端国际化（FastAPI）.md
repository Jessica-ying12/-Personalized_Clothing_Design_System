## 目标
- 为 `module_hammer/gateway` 全部接口提供国际化能力：根据请求语言返回对应语言的消息与错误文案。
- 保持现有统一响应结构不变，仅对 `msg`/文本进行本地化，兼容现有调用。

## 总体方案
- 采用 `gettext + Babel` 的生产级方案，而不是引入 `fastapi-i18n`：
  - `gettext`/`.po/.mo` 文件适合专业的翻译工作流、支持复数、上下文等，生态成熟、性能稳定。
  - 通过中间件解析 `Accept-Language`（或查询参数/用户偏好），使用 `contextvars` 记录当前请求语言。
  - 在统一响应工具 `ResponseUtil` 内部对 `msg` 做翻译，避免到处改控制器代码。
  - 渐进式迁移：当前中文文案作为 `msgid`，后续可逐步替换为语义化 key。

## 关键接入点
- 统一响应封装：`utils/response_util.py`，例如 `success` 构造响应体位置 `utils/response_util.py:41`、`failure` 在 `utils/response_util.py:87`、`error` 在 `utils/response_util.py:225`。
- 全局异常处理：`exceptions/handle.py`，异常最终走 `ResponseUtil.*`，例如 `exceptions/handle.py:25/30/52/59`。
- 网关控制器中文消息示例：
  - 登录成功：`module_hammer/gateway/controller/login_controller.py:163`、`:111`、`:129`、`:216`、`:228`
  - 发送成功/验证码错误：`login_controller.py:52`、`:69`、`:74`、`:81`
  - 业务异常抛出：`module_hammer/gateway/controller/user_controller.py:101`
- 中间件统一注册：`middlewares/handle.py:11-16` 可挂载语言协商中间件。

## 语言协商与上下文
- 解析顺序：`query.lang`（或 `X-Language`）> `Accept-Language` > 用户偏好（未来）> 默认 `zh`。
- 解析 `Accept-Language` 支持 `zh-CN/zh/en-US/en`；规范化为两字母代码 `zh/en`。
- 使用 `contextvars` 保存当前请求语言，线程安全且适配异步。

## 翻译模块设计
- 目录：`i18n/`
  - `locale/zh/LC_MESSAGES/backend.po|mo`
  - `locale/en/LC_MESSAGES/backend.po|mo`
  - 初始以现有中文文案作为 `msgid`，`zh` 译文同源，`en` 提供英文翻译。
- 代码：`i18n/translator.py`
  - 缓存 `gettext.translation(domain='backend', localedir, languages=[lang])`。
  - 暴露 `t(msg: str, **kwargs)`，支持格式化参数。
- 中间件：`middlewares/locale_middleware.py`
  - 解析语言并写入 `contextvars`，设置响应头 `Content-Language`。
- 注册：在 `middlewares/handle.py` 增加 `add_locale_middleware(app)`。

## 响应与异常国际化
- 在 `ResponseUtil` 的 `success/failure/error/unauthorized/forbidden` 统一对 `msg` 调用 `t(msg)`：
  - 例如在 `utils/response_util.py:41/87/133/179/225` 处对 `msg` 翻译后再编码响应。
  - 保持入参兼容：如果传入是 key 或中文均翻译，找不到译文时原文回退。
- 全局异常无需改动控制器：异常处理最终统一调用 `ResponseUtil`，翻译自动生效。
- 特例：直接返回字典的场景（例如报警回调）也应改用 `ResponseUtil.error/success`，或显式调用 `t(...)`。

## 控制器改动策略（渐进式）
- 短期：不批量改动控制器；依赖 `ResponseUtil` 自动翻译现有中文 `msg`。
- 中期：为常用消息引入语义化 key（如 `login.success`、`common.sent`、`error.captcha_token_required`），同时在 `.po` 中保留对中文 msgid 的兼容条目。
- 长期：统一规范所有 `ResponseUtil.xxx(msg=...)` 为 key + 参数，占位符通过 `t('user.device.not_unbound')` 格式化。

## 语言资源维护
- 引入 `Babel`（pybabel）到 `requirements.txt`，提供命令：
  - 初始化：`pybabel init -i messages.pot -d i18n/locale -l en`/`zh`
  - 更新：`pybabel extract` → `pybabel update`
  - 编译：`pybabel compile -d i18n/locale`
- 将网关常用文案（示例）收录：
  - `登录成功`、`发送成功`、`退出成功`、`验证码token不能为空`、`验证码发送失败`、`参数错误`、`处理失败`、`用户有设备未解绑` 等。

## 性能与稳定性
- 翻译对象缓存：按语言缓存 `gettext.translation`，降低 IO。
- 中间件解析使用轻量逻辑；如需复杂 `Accept-Language` 解析可用 `babel` 的 `Locale`。
- 与现有中间件兼容：不影响 `gzip`/`trace`，响应结构和状态码不变。

## 验证与回归
- 请求示例：
  - `curl -H "Accept-Language: en" /gateway/login` → 返回 `{msg: "Login successful"}`。
  - `curl -H "Accept-Language: zh" /gateway/login` → 返回 `{msg: "登录成功"}`。
- 异常示例：触发 `ServiceException('用户有设备未解绑')`（`user_controller.py:101`）→ 对应英文译文。
- SSE/流式消息：在产生日志或推送字符串处调用 `t(...)` 保持一致（如 LLM 相关文案）。

## 与 fastapi-i18n 的取舍
- 可用但不建议作为长期生产方案：
  - 优点：集成简单、开箱即用。
  - 局限：翻译工作流不标准、复杂语法能力有限、生态与维护情况不如 `gettext/Babel`；难以对接专业翻译平台。
- 结论：采用 `gettext + Babel`，并通过统一响应封装实现最低成本接入。

## 后续拓展
- 用户偏好语言存储（用户表字段），登录后优先使用用户偏好覆盖请求头。
- 多数值/复数、上下文（`pgettext/ngettext`）支持。
- 将校验器消息（`pydantic_validation_decorator`）统一改为 key + 翻译。
