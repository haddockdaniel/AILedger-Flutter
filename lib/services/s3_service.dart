import 'dart:io';
import 'package:aws_s3_client/aws_s3_client.dart';
import '../utils/constants.dart';

class S3Service {
  static final _client = S3(
    region: awsRegion,
    bucketId: awsBucket,
    accessKey: awsAccessKey,
    secretKey: awsSecretKey,
  );

  static Future<String> uploadReceipt(File file, String key) async {
    final response = await _client.putObject(
      key,
      file.readAsBytesSync(),
      'image/jpeg',
    );
    if (response.statusCode == 200) {
      return 'https://$awsBucket.s3.$awsRegion.amazonaws.com/$key';
    } else {
      throw Exception('Failed to upload to S3: ${response.statusCode}');
    }
  }
}