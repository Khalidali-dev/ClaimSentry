import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/claim_request.dart';
import '../models/run_response.dart';

class ApiResult<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;
  final bool isConnectionError;

  ApiResult.success(this.data)
      : errorMessage = null,
        isSuccess = true,
        isConnectionError = false;

  ApiResult.failure(this.errorMessage, {this.isConnectionError = false})
      : data = null,
        isSuccess = false;
}

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConfig.backendBaseUrl,
        _client = client ?? http.Client();

  Future<ApiResult<RunResponse>> runPipeline(ClaimRequest request) async {
    final endpoint = Uri.parse('$baseUrl/run');
    final payloadJson = jsonEncode(request.toJson());

    try {
      final response = await _client
          .post(
            endpoint,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: payloadJson,
          )
          .timeout(const Duration(seconds: 45));

      if ((response.statusCode >= 200 && response.statusCode < 300) ||
          response.statusCode == 422) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        final runResponse = RunResponse.fromJson(decoded);
        return ApiResult.success(runResponse);
      } else {
        String detailMessage = 'Server error (${response.statusCode})';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorBody is Map && errorBody.containsKey('detail')) {
            detailMessage = errorBody['detail'].toString();
          }
        } catch (_) {
          detailMessage = response.body.isNotEmpty ? response.body : detailMessage;
        }
        return ApiResult.failure(
          'Pipeline failed with status ${response.statusCode}: $detailMessage',
        );
      }
    } on TimeoutException {
      return ApiResult.failure(
        'Request timed out after 45 seconds. The multi-agent pipeline is taking longer than expected.',
      );
    } catch (e) {
      return ApiResult.failure(
        'Unable to connect to ClaimSentry backend at $baseUrl/run.\n'
        'Details: $e\n\n'
        '• Local: Ensure backend is running (cd backend && python run.py)\n'
        '• Production: Verify your Hugging Face Space backend is running ($baseUrl/health)',
        isConnectionError: true,
      );
    }
  }

  Future<ApiResult<Map<String, dynamic>>> checkHealth() async {
    final endpoint = Uri.parse('$baseUrl/health');
    try {
      final response = await _client
          .get(
            endpoint,
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        return ApiResult.success(decoded);
      } else {
        return ApiResult.failure('Health check returned status ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Health check failed: $e', isConnectionError: true);
    }
  }
}
