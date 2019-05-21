module Voynich
  class Encrypter
    class V1
      attr_accessor :encrypter

      def initialize(encrypter)
        @encrypter = encrypter
      end

      def encrypt(plaintext)
        enc = AES.new(secret[0..31], encrypter.auth_data, serializer: encrypter.serializer).
                encrypt(plaintext)
        {
          v:  version,
          c:  enc[:content],
          t:  enc[:tag],
          iv: enc[:iv],
          ad: enc[:auth_data]
        }
      end

      def decrypt(enc)
        AES
          .new(secret[0..31], encrypter.auth_data, serializer: encrypter.serializer)
          .decrypt(enc["c"], iv: enc["iv"], tag: enc["t"])
      end

      def version
        1
      end

      def secret
        # For backward compatibility, we need to encode secret before passing it to the openssl lib.
        # See https://github.com/degica/voynich/pull/11
        Base64.strict_encode64(encrypter.secret)
      end
    end

    class V2 < V1
      def version
        2
      end

      def secret
        encrypter.secret
      end
    end

    attr_accessor :secret, :auth_data, :serializer

    def initialize(secret, adata, serializer: nil)
      @secret = secret
      @auth_data = adata
      @serializer = serializer
    end

    def encrypt(plaintext, version: 2)
      impl(version).encrypt(plaintext).to_json
    end

    def decrypt(enc_str)
      enc = JSON.parse(enc_str)
      impl(enc["v"]).decrypt(enc)
    end

    private

    def impl(version)
      case version
      when 1, nil
        V1.new(self)
      when 2
        V2.new(self)
      end
    end
  end
end
