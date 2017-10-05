require 'spec_helper'

RSpec.describe Dalli::KeysMatch::Configuration do

  describe '.telnet' do
    it 'allows overwrite defaults during initialization' do
      config = described_class.new(telnet: { 'Timeout' => 2 })
      expect(config.telnet['Timeout']).to eq(2)
    end

    it 'allows overwrite using arguments' do
      config = described_class.new
      expect(config.telnet('Timeout' => 3)['Timeout']).to eq(3)
    end
  end
end
