import 'package:core_fe_infrastructure/src/exceptions/network_exceptions.dart';
import 'package:core_fe_infrastructure/src/interfaces/connectivity.dart';
import 'package:core_fe_infrastructure/src/interfaces/i_network.dart';
import 'package:core_fe_infrastructure/src/models/base_request.dart';
import 'package:core_fe_infrastructure/src/models/base_response.dart';
import 'package:core_fe_infrastructure/src/models/http_response.dart';
import 'package:core_fe_infrastructure/src/models/request_options.dart';
import 'package:core_fe_infrastructure/src/utils/i_http_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:core_fe_infrastructure/src/constants/error_code.dart';

class RestNetworkManagerImpl implements IRestNetworkManager {
  final INetwork _networkProvider;
  final IHttpHelper _httpHelper;
  final Connectivity _connectivity;
  RestNetworkManagerImpl(
      this._networkProvider, this._httpHelper, this._connectivity);

  @override
  Future<BaseResponse<TResponse>> get<TResponse>(
      {@required GetRequest request, @required RequestOptions options}) {
    return _request<TResponse>(
      options,
      (updatedOptions) => _networkProvider.get<TResponse>(
          request: request, options: updatedOptions),
    );
  }

  @override
  Future<BaseResponse<TResponse>> post<TResponse>(
      {@required PostRequest request, @required RequestOptions options}) {
    return _request<TResponse>(
      options,
      (updatedOptions) => _networkProvider.post<TResponse>(
          request: request, options: updatedOptions),
    );
  }

  @override
  Future<BaseResponse<TResponse>> postFile<TResponse>(
      {@required PostFileRequest request, @required RequestOptions options}) {
    return _request<TResponse>(
      options,
      (updatedOptions) => _networkProvider.postFile<TResponse>(
          request: request, options: updatedOptions),
    );
  }

  @override
  Future<BaseResponse<TResponse>> put<TResponse>(
      {@required PutRequest request, @required RequestOptions options}) {
    return _request<TResponse>(
      options,
      (updatedOptions) => _networkProvider.put<TResponse>(
          request: request, options: updatedOptions),
    );
  }

  @override
  Future<BaseResponse<TResponse>> delete<TResponse>(
      {@required DeleteRequest request, @required RequestOptions options}) {
    return _request<TResponse>(
      options,
      (updatedOptions) => _networkProvider.delete<TResponse>(
          request: request, options: updatedOptions),
    );
  }

  @override
  Future<BaseResponse<TResponse>> downloadFile<TResponse>(
      {DownloadFileRequest request, RequestOptions options}) {
    return _request<TResponse>(
      options,
      (updatedOptions) => _networkProvider.downloadFile<TResponse>(
          request: request, options: updatedOptions),
    );
  }

  Future<BaseResponse<TResponse>> _request<TResponse>(RequestOptions options,
      Future<HttpResponse<TResponse>> Function(RequestOptions) request) {
    return _checkConnection()
        .then((value) => updateOptions(options))
        .then(request)
        .then(_httpHelper.resolveResponse);
  }

  Future<void> _checkConnection() {
    return _connectivity.isConnected().then(
          (isConnected) => isConnected
              ? Future.value()
              : throw ConnectionException(errorCode: ErrorCode.noInternetError),
        );
  }

  @visibleForTesting
  Future<RequestOptions> updateOptions(RequestOptions options) {
    var headers = <String, dynamic>{};
    return _httpHelper.getDefaultHeaders().then((defaultHeaders) {
      // append default headers
      headers.addAll(defaultHeaders ?? {});
      // append options headers, existing keys will be ovveriden
      headers.addAll(options.headers ?? {});
      return options.merge(
          headers: headers,
          validateStatus: options.validateStatus ?? _httpHelper.validateStatus);
    });
  }
}
