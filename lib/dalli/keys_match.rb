# frozen_string_literal: true
require 'net/telnet'
require 'dalli'
require 'dalli/keys_match/configuration'
require 'dalli/keys_match/version'

module Dalli
  module KeysMatch

    def config
      @config ||= Configuration.new
    end
    module_function :config

    module Server
      # Memcached does not implement binary protocol for cachedump key. Using telnet as workaround
      # https://github.com/memcached/memcached/wiki/BinaryProtocolRevamped#stat
      def stats_cachedump(id, size, pattern = nil)
        [].tap do |keys|
          telnet.cmd("String" => "stats cachedump #{id} #{size}").split("\n").each do |line|
            if /ITEM (.+) \[\d+ b; \d+ s\]/ =~ line
              case pattern.class.name
              when 'NilClass'
                keys << $1
              when 'Regexp'
                cache_key = $1
                keys << cache_key if cache_key =~ pattern
              else
                keys << $1 if $1[pattern.to_s]
              end
            end
          end
        end
      end

      def close_telnet!
        return unless @telnet
        @telnet.close
        @telnet = nil
      end

      def telnet
        @telnet ||= begin
          configs = Dalli::KeysMatch.config.telnet(
            'Host' => hostname,
            'Port' => port
          )
          Net::Telnet.new(configs)
        end
      end
    end

    module Client
      def keys(pattern = nil)
        result = []
        ring.servers.each do |server|
          next unless server.alive?
          items = server.request(:stats, 'items')
          slabs = items.inject({}) do |r, (k,v)|
            r[$1] = v if k =~ /items:(\d+):number/
            r
          end
          slabs.each do |id, size|
            result.push(*server.stats_cachedump(id, size, pattern))
          end
          server.close_telnet!
        end
        result
      end

      def delete_matched(pattern)
        return 0 if pattern.nil?

        matches = keys(pattern)
        matches.map { |k| delete(k) }.select { |r| r }.size
      end
    end
  end
end

Dalli::Server.send(:include, Dalli::KeysMatch::Server)
Dalli::Client.send(:include, Dalli::KeysMatch::Client)
