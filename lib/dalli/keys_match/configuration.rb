module Dalli
  module KeysMatch
    class Configuration
      TELNET_DEFAULS = {
        'Prompt' => /(^END$)/,
        'Timeout' => 20
      }.freeze

      def initialize(options = {})
        @telnet = TELNET_DEFAULS.merge options.fetch(:telnet, {})
      end

      def telnet(args = {})
        @telnet.merge args
      end
    end
  end
end
