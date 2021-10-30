from typing import Optional

from service.Requests import RequestType
from service.RequestConstructor import RequestConstructor
from service.ResponseParser import ResponseParser
from service.Responses import ResponseType
from service.network import Network
from service.Security import Security


class AuthorizationDispatcher:
    __network = Network()
    __server_message = None
    __server_message: Optional[str]
    __default_server_message = 'Неизвестная ошибка.'

    __server_error = False

    @classmethod
    def get_server_message(cls):
        msg = cls.__server_message if cls.__server_message else cls.__default_server_message
        cls.__server_message = None
        return msg

    @classmethod
    def server_error_occurred(cls):
        return cls.__server_error

    @classmethod
    def __receive(cls):
        try:
            answer = ResponseParser.extract_response(cls.__network.receive())
            cls.__set_server_message(answer)
            return ResponseType(answer.type) == ResponseType.ACCEPT
        except IOError as e:
            cls.__server_message = e
            cls.__server_error = True
            return False

    @classmethod
    def __set_server_message(cls, answer):
        if answer.type == ResponseType.ERROR:
            cls.__server_error = True
        else:
            cls.__server_error = False
        cls.__server_message = answer.data.message


    @classmethod
    def authentication(cls, login, email, password):
        Security.update_encryption_key(cls.encryption_key())
        cls.__network.send(
            RequestConstructor.create(
                request_type=RequestType.AUTHENTICATION,
                login=login,
                password=Security.encrypt(password),
                email=email
            ))
        return cls.__receive()

    @classmethod
    def registration(cls, login, password, first_name, last_name, email):
        Security.update_encryption_key(cls.encryption_key())
        cls.__network.send(
            RequestConstructor.create(
                request_type=RequestType.REGISTRATION,
                login=login,
                password=Security.encrypt(password),
                first_name=first_name,
                last_name=last_name,
                email=email
            ))
        return cls.__receive()

    @classmethod
    def email_verification(cls, email, login):
        cls.__network.send(
            RequestConstructor.create(
                request_type=RequestType.EMAIL_VERIFICATION,
                email=email,
                login=login
            ))
        return cls.__receive()

    @classmethod
    def code_verification(cls, email, code):
        cls.__network.send(
            RequestConstructor.create(
                request_type=RequestType.CODE_VERIFICATION,
                email=email,
                code=code
            ))
        return cls.__receive()

    @classmethod
    def encryption_key(cls):
        cls.__network.send(RequestConstructor.create(
            request_type=RequestType.ENCRYPTION_KEY
        ))
        answer = ResponseParser.extract_response(cls.__network.receive())
        if ResponseType(answer.type) != ResponseType.KEY:
            cls.__set_server_message(answer)
            raise TypeError("Ошибка при получении ключа шифрования!")
        return answer.data.key

    @classmethod
    def available_email(cls, email):
        cls.__network.send(RequestConstructor.create(
            request_type=RequestType.AVAILABLE_EMAIL,
            email=email
        ))
        return cls.__receive()

    @classmethod
    def available_login(cls, login):
        cls.__network.send(RequestConstructor.create(
            request_type=RequestType.AVAILABLE_LOGIN,
            login=login
        ))
        return cls.__receive()


    @classmethod
    def recovery_email_verification(cls, email, login):
        cls.__network.send(RequestConstructor.create(
            request_type=RequestType.RECOVERY_EMAIl_VERIFICATION,
            login=login,
            email=email
        ))
        return cls.__receive()

    @classmethod
    def recovery_code_verification(cls, email, login, code):
        cls.__network.send(RequestConstructor.create(
            request_type=RequestType.RECOVERY_CODE_VERIFICATION,
            login=login,
            email=email,
            code=code
        ))
        return cls.__receive()

    @classmethod
    def new_password(cls, email, login, password):
        Security.update_encryption_key(cls.encryption_key())
        cls.__network.send(RequestConstructor.create(
            request_type=RequestType.NEW_PASSWORD,
            login=login,
            email=email,
            password=Security.encrypt(password)
        ))
        return cls.__receive()
