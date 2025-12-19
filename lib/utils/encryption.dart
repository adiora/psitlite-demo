import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class Encryptor {
  static final IV _iv = IV(
    Uint8List.fromList([
      0xed,
      0x17,
      0xc1,
      0x04,
      0xe6,
      0xfe,
      0xc0,
      0x11,
      0xe7,
      0x8f,
      0xba,
      0xfc,
      0x3e,
      0x4d,
      0xcd,
      0x7e,
    ]),
  );

  static final Uint8List _cachedKey = Uint8List.fromList([
    0xd9,
    0x6d,
    0x94,
    0x88,
    0x3c,
    0x9f,
    0x5f,
    0x51,
    0x18,
    0xe4,
    0x5f,
    0xbe,
    0xb7,
    0xc1,
    0x85,
    0x3e,
    0x6d,
    0x43,
    0xfc,
    0x6d,
    0xc1,
    0x1d,
    0x6d,
    0x57,
    0x75,
    0x70,
    0xc7,
    0xf6,
    0x8e,
    0x89,
    0x90,
    0x49,
  ]);

  static final encrypter = Encrypter(AES(Key(_cachedKey), mode: AESMode.cbc));

  static Future<String> encrypt(String input) async {
    final encrypted = encrypter.encrypt(input, iv: _iv);
    return base64Encode(encrypted.bytes);
  }
  
  static Future<String> decrypt(String base64CipherText) async {
    final cipherTextBytes = base64Decode(base64CipherText);
    return encrypter.decrypt(Encrypted(cipherTextBytes), iv: _iv);
  }
}