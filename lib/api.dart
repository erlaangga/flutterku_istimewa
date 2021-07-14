import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Dio dio = new Dio();
var cookieJar = CookieJar();

Cookie cookie = new Cookie('session_id', '');
const String baseUrl = 'http://10.0.2.2:8014';
String sessionId = '';
String cookieSessionId = '';

void setCookie(response) {
  dio.interceptors.add(CookieManager(cookieJar));
  List<String> rawCookies = response.headers['set-cookie'];
  List<Cookie> cookies = rawCookies.map((cookie) {
    return Cookie.fromSetCookieValue(cookie);
  }).toList();
  sessionId = cookies.firstWhere((cookieTemp) => cookieTemp.name == 'session_id').value;
  cookie.name = 'session_id';
  cookie.value = sessionId;
  cookieSessionId = cookie.name + '=' + sessionId;
}

Future get(String endpoint, Map params) async {
  try {
    String url = baseUrl + endpoint;
    var data = jsonEncode(params);
    var response = await dio.request(url,
        options: Options(method: 'get', headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.cookieHeader: cookieSessionId
        }),
        data: data);
    return response;
  } catch (e) {
    print(e);
  }
}

Future post(String endpoint, Map body) async {
  try {
    String url = baseUrl + endpoint;
    var data = jsonEncode(body);
    var response = await dio.post(url,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.cookieHeader: cookieSessionId
        }),
        data: data);
    return response;
  } catch (e) {
    print(e);
  }
}

Image loadImage(String url){
  return Image.network(url, headers: {HttpHeaders.cookieHeader: cookieSessionId});
}