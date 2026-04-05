import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'model/post.dart';

part 'demo_api.g.dart';

@RestApi()
abstract class DemoApi {
  factory DemoApi(Dio dio, {String? baseUrl}) = _DemoApi;

  @GET('/posts/{id}')
  Future<Post> getPost(@Path('id') int id);

  @GET('/posts')
  Future<List<Post>> getPosts();
}
