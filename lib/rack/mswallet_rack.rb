module Rack
  class MswalletRack

    def initialize(app)
      @app = app
      @parameters = {}
    end

    def call(env)
      @parameters['authToken'] = env['HTTP_AUTHENTICATIONTOKEN'] if env['HTTP_AUTHENTICATIONTOKEN']
      @parameters.merge!(Rack::Utils.parse_nested_query(env['QUERY_STRING']))
      @parameters['path'] = env['PATH_INFO']
      @parameters['host'] = env['HOST']
      serial_number = find_id @parameters['path']
      @parameters['serialNumber'] = serial_number
      if serial_number
        handler = Mswallet.custom_rack_handler || Mswallet::Handler
        response = handler.update(@parameters)
        header = {'Content-Type' => 'application/vnd.ms.wallet',
                  'Content-Disposition' => 'attachment',
                  'filename' => "#{serial_number}.mswallet"}
        case response
          when Mswallet::Pass
            [200, header, [response.stream.string]]
          when String
            [200, header, [response]]
          when File, StringIO, Zip::OutputStream, Tempfile
            [200, header, [response.read]]
          when false
            [304, {}, {}]
          else
            [401, {}, {}]
        end

      else
        @app.call env
      end
    end

    def append_parameter_separator url
    end

    def each(&block)
    end

    def find_id(path)
      return nil unless path =~ /\/#{Mswallet::RACK_API_VERSION}\/walletitems\/([\d\w]+)/
      $1
    end

  end
end

