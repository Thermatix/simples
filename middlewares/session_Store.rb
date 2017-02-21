require 'jwt'

class Sessions

    Encryption_Key_Type = ['prime256v1', 'ES256'].freeze

    class << self

      def encryt_hash full_hash
        deal_with_hash full_hash, :encrypt
      end

      def decode_hash full_hash
        deal_with_hash full_hash, :decode
      end



      def encrypt item_hash,type
        deal_with item_hash, :encrypt, type
      end

      def decode item_hash,type
        deal_with item_hash, :decode, type
      end
      private
      def deal_with_hash full_hash, action
        case action
        when :decode
          send(:"#{action}_this",full_hash,instance_variable_get("@hash_#{action}_key")).first.inject({}) do |hash,(type,item_hash)|
            hash[type] = deal_with(item_hash,action,type).first
            hash
          end
        when :encrypt
          send(:"#{action}_this",full_hash.inject({}) do |hash,(type,item_hash)|
            hash[type] = deal_with item_hash,action,type
            hash
          end,instance_variable_get("@hash_#{action}_key"))
        end

      end

      def deal_with item_hash, action, type
        raise "This function only takes encrypt, decode actions, you provided(#{action})" unless [:encrypt,:decode].include?(action)
        send(:"#{action}_this", item_hash, instance_variable_get("@#{type}_#{action}_key"))
      end

      def generate_private_key
        ::OpenSSL::PKey::EC.new(Encryption_Key_Type.first).generate_key
      end

      def generate_public_key_with private_key
        ::OpenSSL::PKey::EC.new private_key
      end

      def encrypt_this value, key
        JWT.encode(value, key, Encryption_Key_Type.last)
      end

      def decode_this value, key
        JWT.decode(value, key)
      end

    end

    @user_encrypt_key = generate_private_key
    @user_decode_key = generate_public_key_with(@user_encrypt_key)

    @important_encrypt_key = generate_private_key
    @important_decode_key = generate_public_key_with(@important_encrypt_key)

    @details_encrypt_key = generate_private_key
    @details_decode_key = generate_public_key_with(@details_encrypt_key)

    @hash_encrypt_key = generate_private_key
    @hash_decode_key = generate_public_key_with(@hash_encrypt_key)

end
