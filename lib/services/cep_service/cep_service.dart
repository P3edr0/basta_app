// lib/core/services/cep_service/i_cep_service.dart
import 'package:dartz/dartz.dart';

import '../../domain/entities/cep_entity.dart';
import '../../domain/exceptions/exceptions.dart';

abstract class ICepService {
  /// Consulta um CEP e retorna os dados
  /// Retorna Either com erro à esquerda ou CepModel à direita
  Future<Either<IBasExceptions, CepEntity>> getCep(String cep);

  /// Valida formato do CEP
  bool validFormat(String cep);

  /// Formata CEP para exibição (xxxxx-xxx)
  String formatarCep(String cep);

  /// Limpa formatação (remove traços)
  String cleanCep(String cep);
}
