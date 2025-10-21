import bcrypt


def bcrypt_encode_string(input_str: str):
    bytes_str = input_str.encode('utf-8')
    salt = bcrypt.gensalt()
    result = bcrypt.hashpw(bytes_str, salt)
    return result
