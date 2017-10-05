require 'spec_helper'

RSpec.describe Dalli::KeysMatch do

  before(:all) do
    @client = Dalli::Client.new('localhost:11211', expires_in: 300)
    @all_keys = %w[foo bar 123 987654]
    @all_keys.each do |key|
      @client.set("dalli:keys_match:#{key}", key)
    end
  end

  subject(:client) { @client }

  it { is_expected.to respond_to(:keys) }
  it { is_expected.to respond_to(:delete_matched) }

  describe 'Dalli::KeysMatch.config' do
    subject { Dalli::KeysMatch.config }

    it { is_expected.to be_an_instance_of(Dalli::KeysMatch::Configuration) }
  end

  describe '.keys' do
    it 'returns all keys from all servers' do
      keys = client.keys
      expect(keys).not_to be nil
      @all_keys.each do |key|
        expect(keys).to include "dalli:keys_match:#{key}"
      end
    end

    it 'returns all keys which matches the regexp' do
      keys = client.keys(/keys_match:\d+/)
      expect(keys).not_to be nil
      expect(keys.size).to eq(2)
    end

    it 'returns all keys which matches with string' do
      keys = client.keys('keys_match:foo')
      expect(keys).not_to be nil
      expect(keys.size).to eq(1)
    end

    it 'returns all keys which matches with symbol' do
      keys = client.keys(:'keys_match:foo')
      expect(keys).not_to be nil
      expect(keys.size).to eq(1)
    end
  end

  describe '.keys' do
    before(:each) do
      @client.set('dalli:keys_match:baz', 1)
      @client.set('dalli:keys_match:qux', 2)
    end

    it 'does NOT remove anything with nil' do
      expect(client.delete_matched(nil)).to eq(0)
    end

    it 'deletes using regexp matched keys' do
      expect(client.delete_matched(/dalli:keys_match:(baz|qux)/)).to eq(2)
    end

    it 'deletes using string matched keys' do
      expect(client.delete_matched('baz')).to eq(1)
    end
  end
end
