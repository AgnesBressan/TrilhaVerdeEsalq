// lib/services/api_cliente.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mime/mime.dart';

import '../models/trilha.dart';
import '../models/arvore.dart';
import '../models/pergunta.dart';
import '../models/usuario.dart';
import '../models/trofeu.dart';

class ApiConflictError implements Exception {}

class ApiClient {
  final http.Client _http;
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  // [VERSÃO FINAL] Esta função agora aponta para o seu backend na nuvem.
  String get _base {
    return 'https://webtrilhaverde.onrender.com';
  }

  Uri _u(String path, [Map<String, dynamic>? q]) =>
      Uri.parse('$_base$path').replace(queryParameters: q);

  // ================== AUTH/JWT helpers ==================
  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();
  Future<String?> _getToken() async {
    final p = await _prefs;
    return p.getString('token') ?? p.getString('jwt');
  }

  Future<void> saveToken(String token) async {
    final p = await _prefs;
    await p.setString('token', token);
  }

  Future<void> clearToken() async {
    final p = await _prefs;
    await p.remove('token');
    await p.remove('jwt');
  }

  Map<String, String> _headers({bool json = false, String? token}) => {
        if (json) 'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ================== PERFIL (auth) ==================
  Future<Map<String, dynamic>?> fetchMe() async {
    final t = await _getToken();
    if (t == null) return null;
    final r = await _http.get(_u('/api/auth/me'), headers: _headers(token: t));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode == 401 || r.statusCode == 404) return null;
    throw Exception('Falha ao buscar perfil (${r.statusCode})');
  }

  Future<Uint8List?> fetchAvatar() async {
    final t = await _getToken();
    if (t == null) return null;
    final r = await _http.get(_u('/api/auth/me/avatar'), headers: _headers(token: t));
    if (r.statusCode == 200) return r.bodyBytes;
    if (r.statusCode == 204 || r.statusCode == 404) return null;
    throw Exception('Falha ao baixar avatar (${r.statusCode})');
  }

  Future<bool> uploadAvatar(File file) async {
    final t = await _getToken();
    if (t == null) return false;
    final req = http.MultipartRequest('POST', _u('/api/auth/me/avatar'));
    req.headers.addAll(_headers(token: t));
    req.files.add(await http.MultipartFile.fromPath('avatar', file.path));
    final res = await req.send();
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // ================== Trilhas ==================
  Future<List<Trilha>> listarTrilhas() async {
    final t = await _getToken();
    final r = await _http.get(_u('/api/trilhas'), headers: _headers(token: t));
    if (r.statusCode != 200) throw Exception('Falha ao carregar trilhas');
    final data = jsonDecode(r.body) as List;
    return data.map((e) => Trilha.fromJson(e as Map<String, dynamic>)).toList();
    }

  // ================== Árvores ==================
  Future<List<Arvore>> listarArvores({
    required String trilha,
    bool ativas = true,
  }) async {
    final t = await _getToken();
    final r = await _http.get(
      _u('/api/arvores', {
        'trilha': trilha,
        if (ativas) 'ativas': 'true',
      }),
      headers: _headers(token: t),
    );
    if (r.statusCode != 200) throw Exception('Falha ao carregar árvores');
    final data = jsonDecode(r.body) as List;
    return data.map((e) => Arvore.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Arvore> obterArvore(String trilha, int codigo) async {
    final t = await _getToken();
    final r = await _http.get(_u('/api/arvores/$trilha/$codigo'), headers: _headers(token: t));
    if (r.statusCode != 200) throw Exception('Falha ao carregar dados da árvore');
    return Arvore.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  // ================== Perguntas ==================
  Future<List<Pergunta>> listarPerguntas({
    required String trilha,
    required int arvoreCodigo,
  }) async {
    final t = await _getToken();
    final r = await _http.get(
      _u('/api/perguntas', {
        'trilha': trilha,
        'arvore': '$arvoreCodigo',
      }),
      headers: _headers(token: t),
    );
    if (r.statusCode != 200) throw Exception('Falha ao carregar perguntas');
    final data = jsonDecode(r.body) as List;
    return data.map((e) => Pergunta.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ================== Usuário ==================
  Future<Usuario> salvarUsuario(Usuario u) async {
    final t = await _getToken();
    final r = await _http.post(
      _u('/api/usuarios'),
      headers: _headers(json: true, token: t),
      body: jsonEncode({
        'nickname': u.nickname,
        'nome': u.nome,
        'idade': u.idade,
        'ano_escolar': u.anoEscolar,
        'num_arvores_visitadas': u.numArvoresVisitadas,
      }),
    
    );

    if (r.statusCode == 409) throw ApiConflictError();
    if (r.statusCode != 200 && r.statusCode != 201) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }

  Future<Usuario?> obterUsuario(String nickname) async {
    final t = await _getToken();
    final r = await _http.get(_u('/api/usuarios/$nickname'), headers: _headers(token: t));
    if (r.statusCode == 404) return null;
    if (r.statusCode != 200) {
      throw Exception('Falha ao buscar usuário (${r.statusCode})');
    }
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }

  // ================== Usuário (Avatar) ==================
  Future<Uint8List?> fetchAvatarUsuario(String nickname) async {
    final t = await _getToken();
    final r = await _http.get(_u('/api/usuarios/$nickname/avatar'), headers: _headers(token: t));
    
    if (r.statusCode == 200) return r.bodyBytes;
    if (r.statusCode == 404 || r.statusCode == 204) return null; 
    
    throw Exception('Falha ao baixar avatar do usuário (${r.statusCode})');
  }

  Future<bool> uploadAvatarUsuario(String nickname, File file) async {
    final t = await _getToken();
    final req = http.MultipartRequest('POST', _u('/api/usuarios/$nickname/avatar'));
    
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    
    req.headers.addAll(_headers(token: t));
    req.files.add(await http.MultipartFile.fromPath('avatar', file.path));
    req.fields['foto_mime'] = mimeType;
    
    final res = await req.send();
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // ================== Troféus e Pontuação ==================
  Future<List<Trofeu>> listarTrofeus(String nickname) async {
    final t = await _getToken();
    final r = await _http.get(_u('/api/usuarios/$nickname/trofeus'), headers: _headers(token: t));

    if (r.statusCode != 200) {
      throw Exception('Falha ao carregar troféus');
    }

    final data = jsonDecode(r.body) as List;
    return data.map((e) => Trofeu.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> obterTotalArvores() async {
    final t = await _getToken();
    final r = await _http.get(_u('/api/arvores/total', {'ativas': 'true'}), headers: _headers(token: t)); 
    
    if (r.statusCode != 200) {
      throw Exception('Falha ao buscar total de árvores');
    }
    
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return data['total'] as int;
  }

  Future<void> salvarTrofeu(String nickname, String trilhaNome, int arvoreCodigo) async {
    final t = await _getToken();
    final r = await _http.post(
      _u('/api/usuarios/$nickname/trofeus'),
      headers: _headers(json: true, token: t),
      body: jsonEncode({
        'trilha_nome': trilhaNome,
        'arvore_codigo': arvoreCodigo,
      }),
    );

    if (r.statusCode != 201) {
      throw Exception('Falha ao salvar o troféu');
    }
  }

  Future<void> reiniciarProgresso(String nickname) async {
    final t = await _getToken();
    final r = await _http.delete(
      _u('/api/usuarios/$nickname/trofeus'),
      headers: _headers(token: t),
    );

    if (r.statusCode != 204) {
      throw Exception('Falha ao reiniciar o progresso');
    }
  }

  // ================== Sessão ==================
  Future<void> sair() async {
    final p = await _prefs;
    await p.remove('ultimo_usuario');
    await clearToken(); 
  }
}