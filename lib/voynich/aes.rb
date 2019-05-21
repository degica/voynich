require 'yaml'
require 'base64'

module Voynich
  class AES
    AUTH_TAG_BITS = 128
    CIPHER_MODE = 'aes-256-gcm'
    DEFAULT_SERIALIZER = Marshal

    def initialize(secret, adata, serializer:)
      @secret = secret
      @auth_data = adata
      @serializer = serializer || DEFAULT_SERIALIZER
    end

    def encrypt(plaintext)
      cipher = OpenSSL::Cipher.new(CIPHER_MODE)
      cipher.encrypt
      cipher.key = @secret
      iv = cipher.random_iv
      cipher.auth_data = @auth_data
      encrypted_data = cipher.update(serialize(plaintext)) + cipher.final
      tag = cipher.auth_tag(AUTH_TAG_BITS / 8)
      {
        content: Base64.strict_encode64(encrypted_data),
        tag:     Base64.strict_encode64(tag),
        iv:      Base64.strict_encode64(iv),
        auth_data: @auth_data
      }
    end

    def decrypt(content, iv:, tag:)
      cipher = OpenSSL::Cipher.new(CIPHER_MODE)
      cipher.decrypt
      cipher.key = @secret
      cipher.iv = Base64.decode64(iv)
      cipher.auth_tag = Base64.decode64(tag)
      cipher.auth_data = @auth_data
      decrypted_data = cipher.update(Base64.decode64(content)) + cipher.final
      deserialize(decrypted_data)
    end

    def serialize(data)
      @serializer.dump(data)
    end

    def deserialize(data)
      @serializer.load(data)
    end
  end
end
