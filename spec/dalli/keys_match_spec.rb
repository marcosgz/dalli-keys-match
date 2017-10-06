require 'spec_helper'

RSpec.describe Dalli::KeysMatch do

  before do
    @global_client = Dalli::Client.new('localhost:11211', expires_in: 300)
    @namespace_client = Dalli::Client.new('localhost:11211', expires_in: 300, namespace: 'dalli/keys_match')
    @all_keys = %w[foo bar 123 987654]
    @all_keys.each do |key|
      @global_client.set("dalli:keys_match:#{key}", key)
      @namespace_client.set("dalli:keys_match:#{key}", key)
    end
  end

  describe 'Dalli::KeysMatch.config' do
    subject { Dalli::KeysMatch.config }

    it { is_expected.to be_an_instance_of(Dalli::KeysMatch::Configuration) }
  end

  describe 'dalli without namespace' do
    subject(:global_client) { @global_client }

    it { is_expected.to respond_to(:keys) }
    it { is_expected.to respond_to(:delete_matched) }

    describe '.keys_with_namespace' do
      it 'returns all keys from all servers' do
        keys = global_client.keys_with_namespace
        expect(keys).not_to be nil
        @all_keys.each do |key|
          expect(keys).to include "dalli/keys_match:dalli:keys_match:#{key}"
        end
      end

      it 'returns all keys which matches the regexp' do
        keys = global_client.keys_with_namespace(/keys_match:\d+/)
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:123
          dalli:keys_match:987654
          dalli/keys_match:dalli:keys_match:123
          dalli/keys_match:dalli:keys_match:987654
        ])
      end

      it 'returns all keys which matches the regexp with a caret' do
        keys = global_client.keys_with_namespace(/^dalli:keys_match:\d+/)
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:123
          dalli:keys_match:987654
        ])
      end

      it 'returns all keys which matches with string' do
        keys = global_client.keys_with_namespace('keys_match:foo')
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:foo
          dalli/keys_match:dalli:keys_match:foo
        ])
      end

      it 'returns all keys which matches with symbol' do
        keys = global_client.keys_with_namespace(:'keys_match:foo')
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:foo
          dalli/keys_match:dalli:keys_match:foo
        ])
      end
    end

    describe '.keys' do
      it 'returns all keys from all servers' do
        keys = global_client.keys
        expect(keys).not_to be nil
        @all_keys.each do |key|
          expect(keys).to include "dalli:keys_match:#{key}"
        end
      end

      it 'returns all keys which matches the regexp' do
        keys = global_client.keys(/keys_match:\d+/)
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:123
          dalli:keys_match:987654
          dalli/keys_match:dalli:keys_match:123
          dalli/keys_match:dalli:keys_match:987654
        ])
      end

      it 'returns all keys which matches the regexp with a caret' do
        keys = global_client.keys(/^dalli:keys_match:\d+/)
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:123
          dalli:keys_match:987654
        ])
      end

      it 'returns all keys which matches with string' do
        keys = global_client.keys('keys_match:foo')
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:foo
          dalli/keys_match:dalli:keys_match:foo
        ])
      end

      it 'returns all keys which matches with symbol' do
        keys = global_client.keys(:'keys_match:foo')
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:foo
          dalli/keys_match:dalli:keys_match:foo
        ])
      end
    end

    describe '.delete_matched' do
      before(:each) do
        @global_client.set('dalli:keys_match:baz', 1)
        @global_client.set('dalli:keys_match:qux', 2)
        @namespace_client.set('dalli:keys_match:baz', 1)
        @namespace_client.set('dalli:keys_match:qux', 2)
      end

      it 'does NOT remove anything with nil' do
        expect(global_client.delete_matched(nil)).to eq(0)
      end

      it 'deletes using regexp matched keys' do
        expect(global_client.delete_matched(/keys_match:(baz|qux)/)).to eq(4)

        expect(global_client.get('dalli:keys_match:baz')).to be nil
        expect(global_client.get('dalli:keys_match:qux')).to be nil
        expect(@namespace_client.get('dalli:keys_match:baz')).to be nil
        expect(@namespace_client.get('dalli:keys_match:qux')).to be nil
      end

      it 'deletes using regexp with a caret' do
        expect(global_client.delete_matched(/^dalli:keys_match:(baz|qux)/)).to eq(2)

        expect(global_client.get('dalli:keys_match:baz')).to be nil
        expect(global_client.get('dalli:keys_match:qux')).to be nil
        expect(@namespace_client.get('dalli:keys_match:baz')).not_to be nil
        expect(@namespace_client.get('dalli:keys_match:qux')).not_to be nil
      end

      it 'deletes using string matched keys' do
        expect(global_client.delete_matched('keys_match:baz')).to eq(2)

        expect(global_client.get('dalli:keys_match:baz')).to be nil
        expect(@namespace_client.get('dalli:keys_match:baz')).to be nil
      end
    end
  end

  describe 'dalli with namespace' do
    subject(:namespace_client) { @namespace_client }

    it { is_expected.to respond_to(:keys) }
    it { is_expected.to respond_to(:delete_matched) }

    describe '.keys_with_namespace' do
      it 'returns all keys from all servers' do
        keys = namespace_client.keys_with_namespace
        expect(keys).not_to be nil
        @all_keys.each do |key|
          expect(keys).to include "dalli/keys_match:dalli:keys_match:#{key}"
        end
      end

      it 'returns all keys which matches the regexp' do
        keys = namespace_client.keys_with_namespace(/keys_match:\d+/)
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli/keys_match:dalli:keys_match:123
          dalli/keys_match:dalli:keys_match:987654
        ])
      end

      it 'returns all keys which matches the regexp with a caret' do
        keys = namespace_client.keys_with_namespace(/^dalli:keys_match:\d+/)
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli/keys_match:dalli:keys_match:123
          dalli/keys_match:dalli:keys_match:987654
        ])
      end

      it 'returns all keys which matches with string' do
        keys = namespace_client.keys_with_namespace('keys_match:foo')
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli/keys_match:dalli:keys_match:foo
        ])
      end

      it 'returns all keys which matches with symbol' do
        keys = namespace_client.keys_with_namespace(:'keys_match:foo')
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli/keys_match:dalli:keys_match:foo
        ])
      end
    end

    describe '.keys' do
      it 'returns all keys from all servers' do
        keys = namespace_client.keys
        expect(keys).not_to be nil
        @all_keys.each do |key|
          expect(keys).to include "dalli:keys_match:#{key}"
        end
      end

      it 'returns all keys which matches the regexp' do
        keys = namespace_client.keys(/keys_match:\d+/)
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:123
          dalli:keys_match:987654
        ])
      end

      it 'returns all keys which matches the regexp with a caret' do
        keys = namespace_client.keys(/^dalli:keys_match:\d+/)
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:123
          dalli:keys_match:987654
        ])
      end

      it 'returns all keys which matches with string' do
        keys = namespace_client.keys('keys_match:foo')
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:foo
        ])
      end

      it 'returns all keys which matches with symbol' do
        keys = namespace_client.keys(:'keys_match:foo')
        expect(keys).not_to be nil
        expect(keys).to match_array(%w[
          dalli:keys_match:foo
        ])
      end
    end

    describe '.delete_matched' do
      before(:each) do
        @global_client.set('dalli:keys_match:baz', 1)
        @global_client.set('dalli:keys_match:qux', 2)
        @namespace_client.set('dalli:keys_match:baz', 1)
        @namespace_client.set('dalli:keys_match:qux', 2)
      end

      it 'does NOT remove anything with nil' do
        expect(namespace_client.delete_matched(nil)).to eq(0)
      end

      it 'deletes using regexp matched keys' do
        expect(namespace_client.delete_matched(/keys_match:(baz|qux)/)).to eq(2)

        expect(namespace_client.get('dalli:keys_match:baz')).to be nil
        expect(namespace_client.get('dalli:keys_match:qux')).to be nil
        expect(@global_client.get('dalli:keys_match:baz')).not_to be nil
        expect(@global_client.get('dalli:keys_match:qux')).not_to be nil
      end

      it 'deletes using regexp with a caret' do
        expect(namespace_client.delete_matched(/^dalli:keys_match:(baz|qux)/)).to eq(2)

        expect(namespace_client.get('dalli:keys_match:baz')).to be nil
        expect(namespace_client.get('dalli:keys_match:qux')).to be nil
        expect(@global_client.get('dalli:keys_match:baz')).not_to be nil
        expect(@global_client.get('dalli:keys_match:qux')).not_to be nil
      end

      it 'deletes using string matched keys' do
        expect(namespace_client.delete_matched('keys_match:baz')).to eq(1)

        expect(namespace_client.get('dalli:keys_match:baz')).to be nil
        expect(@global_client.get('dalli:keys_match:baz')).not_to be nil
      end
    end
  end
end
