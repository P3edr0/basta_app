// lib/core/services/cep_service/via_cep_service.dart
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/cep_entity.dart';
import '../../domain/exceptions/exceptions.dart';
import 'cep_service.dart';

class ViaCepService implements ICepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';
  final Dio _dio;
  CepEntity? _ultimoResultado;

  ViaCepService() : _dio = Dio();

  CepEntity? get ultimoResultado => _ultimoResultado;

  @override
  Future<Either<IBasExceptions, CepEntity>> getCep(String cep) async {
    try {
      final cepLimpo = cleanCep(cep);

      if (!validFormat(cepLimpo)) {
        return Left(DataException(message: 'Cep inválido'));
      }

      // 2. Faz a requisição
      final url = '$_baseUrl/$cepLimpo/json/';
      final response = await _dio
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw DataException(message: 'Cep inválido'),
          );

      // 3. Processa a resposta
      return _processarResposta(response, cep);
    } catch (e, stack) {
      log('Erro: ${stack.toString()}');
      return Left(DataException(message: 'Cep inválido'));
    }
  }

  Either<IBasExceptions, CepEntity> _processarResposta(
    Response response,
    String cepOriginal,
  ) {
    try {
      if (response.statusCode != 200) {
        return Left(DataException(message: 'Cep inválido'));
      }

      final data = Map<String, dynamic>.from(response.data);

      if (data.containsKey('erro') && data['erro'] == true) {
        return Left(DataException(message: 'Cep inválido'));
      }

      final cepEntity = CepEntity.fromJson(data);

      if (!cepEntity.isValid) {
        return Left(DataException(message: 'Cep inválido'));
      }

      _ultimoResultado = cepEntity;
      return Right(cepEntity);
    } catch (e) {
      return Left(DataException(message: 'Cep inválido'));
    }
  }

  @override
  bool validFormat(String cep) {
    final cepLimpo = cleanCep(cep);

    // Regex para 8 dígitos
    final regex = RegExp(r'^\d{8}$');
    return regex.hasMatch(cepLimpo);
  }

  @override
  String formatarCep(String cep) {
    final cepLimpo = cleanCep(cep);

    if (cepLimpo.length == 8) {
      return '${cepLimpo.substring(0, 5)}-${cepLimpo.substring(5)}';
    }

    return cep;
  }

  @override
  String cleanCep(String cep) {
    return cep.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Método para fechar o client (opcional)
  void dispose() {
    _dio.close();
  }
}
