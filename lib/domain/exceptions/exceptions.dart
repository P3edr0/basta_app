abstract class IBasExceptions implements Exception {
  String message = "Falha na autenticação.";
  IBasExceptions({required this.message});
}

class EmailAlreadyExistsException extends IBasExceptions {
  @override
  EmailAlreadyExistsException({super.message = "E-mail já cadastrado."});
}

class TooManyAttemptsException extends IBasExceptions {
  @override
  TooManyAttemptsException({
    super.message = 'Acesso bloqueado temporariamente. Tente mais tarde.',
  });
}

class DataException extends IBasExceptions {
  @override
  DataException({super.message = "Dado inválido."});
}

class BadRequestJackException extends IBasExceptions {
  @override
  BadRequestJackException({
    super.message = "Falha ao tentar acessar. Por favor tente mais tarde",
  });
}

class WithoutAccountException extends IBasExceptions {
  @override
  WithoutAccountException({
    super.message = "Não encontramos seu cadastro no Tá na escola.",
  });
}

class EmailOrPasswordException extends IBasExceptions {
  @override
  EmailOrPasswordException({super.message = "Email ou senha estão incorretos"});
}

class InvalidPasswordException extends IBasExceptions {
  @override
  InvalidPasswordException({super.message = "Senha informada não confere"});
}

class DisabledUserException extends IBasExceptions {
  @override
  DisabledUserException({
    super.message = "A conta do usuário foi desativada pelo administrador.",
  });
}

class InactiveUserException extends IBasExceptions {
  @override
  InactiveUserException({
    super.message =
        "A conta do usuário ainda não foi ativada pelo administrador.",
  });
}

class DisabledClientException extends IBasExceptions {
  @override
  DisabledClientException({
    super.message = "A sua empresa está inativa. Fale com o administrador",
  });
}
