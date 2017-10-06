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
              if pattern.nil?
                keys << $1
              else
                cache_key = $1
                keys << cache_key if cache_key =~ pattern
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

      protected

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
      def keys_with_namespace(pattern = nil)
        re = stats_pattern_regexp(pattern)
        result = []
        ring.servers.each do |server|
          next unless server.alive?
          items = server.request(:stats, 'items')
          slabs = items.inject({}) do |r, (k,v)|
            r[$1] = v if k =~ /items:(\d+):number/
            r
          end
          slabs.each do |id, size|
            result.push(*server.stats_cachedump(id, size, re))
          end
          server.close_telnet!
        end
        result
      end

      def keys(pattern = nil)
        keys_with_namespace(pattern).map do |key|
          key_without_namespace(key)
        end
      end

      def delete_matched(pattern)
        return 0 if pattern.nil?

        matches = keys(pattern)
        matches.map { |k| delete(k) }.select { |r| r }.size
      end

      protected

      def stats_pattern_regexp(pattern)
        return if namespace.nil? && pattern.nil?

        if namespace
          if pattern.is_a?(Regexp)
            opts, source = pattern.to_s.scan(/^\(\?([a-z\-]{3,4})\:(.*)\)$/m).flatten
            source_with_namespace = \
              if source.sub!(/^\^/,'')
                "^#{namespace}:#{source}"
              else
                "^#{namespace}:.*#{source}"
              end
            Regexp.new("(?#{opts}:#{source_with_namespace})")
          else
            Regexp.new("#{namespace}:.*#{pattern}")
          end
        else
          Regexp.new(pattern.to_s)
        end
      end
    end
  end
end

Dalli::Server.send(:include, Dalli::KeysMatch::Server)
Dalli::Client.send(:include, Dalli::KeysMatch::Client)
