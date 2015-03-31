require 'mswallet/version'
require 'rack/mswallet_rack'

module Mswallet
  autoload :Pass, 'mswallet/pass'

  class << self
    attr_accessor :custom_rack_handler
    def configure
      yield self
    end
  end

end
