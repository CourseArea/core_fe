enum ResponseType {
  /// Transform the response data to JSON object only when the
  /// content-type of response is "application/json" .
  json,

  /// Get the response stream without any transformation. The
  /// Response data will be a `ResponseBody` instance.
  ///
  ///    Response<ResponseBody> rs = await Dio().get<ResponseBody>(
  ///      url,
  ///      options: Options(
  ///        responseType: ResponseType.stream,
  ///      ),
  ///    );
  stream,

  /// Transform the response data to a String encoded with UTF8.
  plain,

  /// Get original bytes, the type of [Response.data] will be List<int>
  bytes
}