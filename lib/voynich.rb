require "voynich/version"
require "voynich/active_record"
require "voynich/active_model/model"
require "voynich/kms_data_key"
require "voynich/storage"
require "voynich/aes"

require 'aws-sdk'
require 'active_support/core_ext/module/attribute_accessors'

module Voynich
  mattr_accessor :kms_cmk_id
  mattr_accessor :auto_data_key_count
  mattr_accessor :aws_access_key_id
  mattr_accessor :aws_secret_access_key
  mattr_accessor :aws_region

  DEFAULT_CONFIG = {
    auto_data_key_max_count: 50,
    aws_region: 'us-east-1' # KMS is only available in us-east-1
  }

  def self.configure(config = {})
    config = DEFAULT_CONFIG.merge(config)
    self.kms_cmk_id = config[:kms_cmk_id]
    self.auto_data_key_count = config[:auto_data_key_max_count]
    self.aws_access_key_id = config[:aws_access_key_id]
    self.aws_secret_access_key = config[:aws_secret_access_key]
    self.aws_region = config[:aws_region]
  end

  def self.kms_client
    if self.aws_access_key_id.present?
      credentials = Aws::Credentials.new(self.aws_access_key_id, self.aws_secret_access_key)
      Aws::KMS::Client.new(region: self.aws_region, credentials: credentials)
    else
      Aws::KMS::Client.new(region: self.aws_region)
    end
  end

  # Re-encrypts all existing data keys
  # this should be executed when KMS CMK is rotated to
  # have the data keys encrypted by the latest CMK
  def reencrypt_all_data_keys
    ActiveRecord::DataKey.find_each do |data_key|
      data_key.reencrypt!
      sleep 0.1 # KMS limits API access up to 100 calls/sec
    end
  end

  self.configure
end
