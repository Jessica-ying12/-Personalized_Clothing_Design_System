export enum ContentTypeEnum {
	// json
	JSON = "application/json;charset=UTF-8",
	// form-data   上传资源（图片，视频）
	FORM_DATA = "multipart/form-data;charset=UTF-8"
}

export enum RequestMethodsEnum {
	GET = "GET",
	POST = "POST",
	DELETE = "DELETE",
	PUT = "PUT"
}

/**
 * 请求返回码枚举。
 *
 * 该枚举定义了系统中各种请求操作可能的返回码，用于标识请求的处理状态和结果。
 * 每个返回码对应一个特定的错误类型或成功状态，便于开发人员和用户理解请求处理的结果。
 */
export enum RequestCodeEnum {
	SUCCESS = 200, //成功
	UNAUTHORIZE=401 //未授权
}
