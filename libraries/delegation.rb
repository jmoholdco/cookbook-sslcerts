require 'forwardable'

module SSLCertsCookbook
  module Utils
    module Delegation
      def self.included(base)
        base.send(:extend, Forwardable)
      end

      def method_missing(meth, *args)
        if ssl.respond_to?(meth)
          ssl.send(meth, *args)
        else
          super
        end
      end

      def respond_to?(meth)
        ssl.respond_to?(meth)
      end

      def respond_to_missing?(meth, include_private = false)
        ssl.respond_to?(meth) || super(meth, include_private)
      end
    end
  end
end
