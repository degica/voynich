require 'spec_helper'

describe Voynich do
  it 'has a version number' do
    expect(Voynich::VERSION).not_to be nil
  end

  describe '#kms_client' do
    before do
      allow(Aws::KMS::Client).to receive(:new) { double("kms client") }
      Voynich.configure(retion: 'ap-northeast-1')
    end

    it 'should initialize Aws::KMS:Client once' do
      expect(Aws::KMS::Client).to receive(:new).once
      client1 = Voynich.kms_client
      client2 = Voynich.kms_client
      expect(client1).to eq(client2)
    end

    it 'should re-initialize Aws::KMS:Client after #configure' do
      expect(Aws::KMS::Client).to receive(:new).twice
      client1 = Voynich.kms_client
      client2 = Voynich.kms_client
      Voynich.configure(retion: 'ap-northeast-1')
      client3 = Voynich.kms_client
      expect(client1).to eq(client2)
      expect(client1).not_to eq(client3)
    end
  end
end
