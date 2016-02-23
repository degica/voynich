module Voynich
  class KMSDataKeyClient
    Result = Struct.new(:plaintext, :ciphertext)

    attr_reader :cmk_id

    def initialize(cmk_id)
      @cmk_id = cmk_id
    end

    def decrypt(ciphertext)
      response = kms_client.decrypt(ciphertext_blob: decode(ciphertext))
      Result.new(encode(response.plaintext), ciphertext)
    end

    def generate
      response = kms_client.generate_data_key(key_id: cmk_id, key_spec: 'AES_256')
      Result.new(encode(response.plaintext), encode(response.ciphertext_blob))
    end

    def reencrypt(ciphertext)
      response = kms_client.re_encrypt(
        ciphertext_blob: decode(ciphertext),
        destination_key_id: cmk_id
      )
      Result.new(nil, encode(response.ciphertext_blob))
    end

    private

    def encode(data)
      Base64.strict_encode64(data)
    end

    def decode(data)
      Base64.decode64(data)
    end

    def kms_client
      @kms_client ||= Voynich.kms_client
    end
  end
end
