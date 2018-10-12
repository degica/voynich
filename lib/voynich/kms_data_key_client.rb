module Voynich
  class KMSDataKeyClient
    Result = Struct.new(:plaintext, :ciphertext)

    attr_reader :cmk_id

    def initialize(cmk_id)
      @cmk_id = cmk_id
    end

    def decrypt(ciphertext)
      response = kms_client.decrypt(ciphertext_blob: ciphertext)
      Result.new(response.plaintext, ciphertext)
    end

    def generate
      response = kms_client.generate_data_key(key_id: cmk_id, key_spec: 'AES_256')
      Result.new(response.plaintext, response.ciphertext_blob)
    end

    def reencrypt(ciphertext)
      response = kms_client.re_encrypt(
        ciphertext_blob: ciphertext,
        destination_key_id: cmk_id
      )
      Result.new(nil, response.ciphertext_blob)
    end

    private

    def kms_client
      @kms_client ||= Voynich.kms_client
    end
  end
end
