/**
 * 页面路由枚举
 * 该枚举定义了应用中的重要页面路由路径，用于导航和权限控制。
 */
export enum PageEnum {
	/**
	 * 注册页面路由
	 * 用于用户注册操作的页面路径。
	 */
	REGISTER = "/register",
	/**
	 * 登录页面路由
	 * 用于用户登录操作的页面路径。
	 */
	LOGIN = "/login",
	/**
	 * 忘记密码页面路由
	 * 用于用户忘记密码操作的页面路径。
	 */
	FORGOT_PASSWORD = "/forgot-password",
	/**
	 * 403错误页面路由
	 * 当用户无权限访问特定资源时跳转的页面路径。
	 */
	ERROR_403 = "/403",
	/**
	 * 500错误页面路由
	 * 当服务器发生错误时跳转的页面路径。
	 */
	ERROR_500 = "/500",
	/**
	 * 404错误页面路由
	 * 当用户请求的页面不存在时跳转的页面路径。
	 * 使用通配符捕获所有未匹配的路由。
	 */
	ERROR_404 = "/:pathMatch(.*)*",
	/**
	 * 首页路由
	 * 应用的主页面路径。
	 */
	INDEX = "/"
}

export enum CacheEnum {
	TOKEN_KEY = "token", //token
	ACCOUNT_KEY = "account", //账号
	SETTING_KEY = "setting", //设置
	CACHE_KEY = "dim_admin_"
}

export enum LocaleEnum {
	zhCN = "zh_CN",
	enUS = "en_US"
}

export enum MenuEnum {
	CATALOGUE = "M",
	MENU = "C",
	BUTTON = "A"
}
