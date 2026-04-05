import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../client/base_response.dart';
import 'model/app_setting.dart';

part 'website_api.g.dart';

@RestApi()
abstract class WebsiteApi {
  factory WebsiteApi(Dio dio, {String? baseUrl}) = _WebsiteApi;

  @GET('/api/v1/website/app-setting')
  Future<BaseResponse<AppSetting>> getAppSetting();
}
