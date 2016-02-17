module Voynich
  class KMSDataKey
    attr_reader :cmk_id

    def initialize(cmk_id:, ciphertext: nil)
      @cmk_id = cmk_id
      @ciphertext = ciphertext
    end

    def plaintext
      Base64.strict_encode64(fetch_plaintext_data_key)
    end

    def ciphertext
      @ciphertext ||= Base64.strict_encode64(generate_data_key.ciphertext_blob)
    end

    def reencrypt
      blob = Base64.decode64 @ciphertext
      resp = kms_client.re_encrypt(ciphertext_blob: blob, destination_key_id: @cmk_id)
      @ciphertext = Base64.strict_encode64(resp.ciphertext_blob)
    end

    private

    def fetch_plaintext_data_key
      decrypt_data_key || generate_data_key.plaintext
    end

    def generate_data_key
      @data_key ||= kms_client.generate_data_key(key_id: cmk_id, key_spec: 'AES_256')
    end

    def decrypt_data_key
      return if @ciphertext.nil?
      blob = Base64.decode64 @ciphertext
      kms_client.decrypt(ciphertext_blob: blob).plaintext
    end

    def kms_client
      @kms_client ||= Voynich.kms_client
    end
  end
end
