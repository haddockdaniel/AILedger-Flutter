import 'dart:io';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class S3Service {
  static final _credentials = AWSCredentials(awsAccessKey, awsSecretKey);
  static final _signer = AWS4Signer(credentials: _credentials);

  static Future<String> uploadReceipt(File file, String key) async {
    final uri = Uri.parse('https://$awsBucket.s3.$awsRegion.amazonaws.com/$key');
    final request = AWSHttpRequest.put(
      uri,
      body: file.readAsBytesSync(),
      headers: {'Content-Type': 'image/jpeg'},
    );
    final signed = _signer.sign(
      request,
      service: AWSService.s3,
      region: awsRegion,
    );
    final response = await http.put(
      signed.uri,
      headers: signed.headers,
      body: signed.body,
    );
    if (response.statusCode == 200) {
      return 'https://$awsBucket.s3.$awsRegion.amazonaws.com/$key';
    } else {
      throw Exception('Failed to upload to S3: ${response.statusCode}');
    }
  }
  
}