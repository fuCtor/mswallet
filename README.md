[![Build Status](https://travis-ci.org/fuCtor/mswallet.svg)](https://travis-ci.org/fuCtor/mswallet)
[![Code Climate](https://codeclimate.com/github/fuCtor/mswallet/badges/gpa.svg)](https://codeclimate.com/github/fuCtor/mswallet)
[![Test Coverage](https://codeclimate.com/github/fuCtor/mswallet/badges/coverage.svg)](https://codeclimate.com/github/fuCtor/mswallet)

# Mswallet

[Русская версия](https://github.com/fuCtor/mswallet/blob/master/README.ru.md)

This gem let's you [create a mswallet for Wallet app in WP8+](https://msdn.microsoft.com/en-us/library/dn631256.aspx).

## Installation

Include the passbook gem in your project.
IE in your Gemfile

    gem 'mswallet'

and execute:

    $ bundle

Or manual install:

    $ gem install mswallet

## Configuration
If you want to also support the update endpoint you will also need to include the Rack::MswalletRack middleware. In rails your config will look something like this.

    config.middleware.use Rack::MswalletRack

Mswallet::Handler are used by default for update request handle. You can set custom class.

    Mswallet.custom_rack_handler  = MyCustomHandler

    # или

    Mswallet.configure do |m|
      m.custom_rack_handler  = MyCustomHandler
    end

## Usage

    pass = Mswallet::Pass.new

    pass['Kind'] = 'General'
    pass['Id'] = '00001'

    pass['DisplayName'] = 'Test wallet'
    pass['IssuerDisplayName'] = 'Test wallet'
    pass['HeaderColor'] = '#0000FF'
    pass['BodyColor']   = '#FFFFFF'
    properties = {}
    properties['Header'] = {
            'Property' => [
                {
                    'Key' => 'Hd1',
                    'Name' => 'Header Text',
                    'Value' => 'Name'
                },
                {
                    'Key' => 'Hd2',
                    'Name' => 'Header Text2',
                    'Value' => nil        #empty value: &#160;
                }
            ]
        }
    pass['DisplayProperties'] = properties

    pass.add_file name: 'file1', content: 'fileContent1'
    pass.add_file name: 'file2', content: 'fileContent2'

    pass.add_locale 'ru-RU', { 'hello_world' => 'Привет мир' }

    pass['WebServiceUrl'] = "http://localhost:3000/api"
    pass['AuthenticationToken'] = 'secret_token'

    mswallet = pass.file
    send_file mswallet.path, type: 'application/vnd.ms.wallet', disposition: 'attachment', filename: "pass.mswallet"

    # Or a stream

    mswallet = pass.stream
    send_data mswallet.string, type: 'application/vnd.ms.wallet', disposition: 'attachment', filename: "pass.mswallet"

## Contributing

1. Fork it ( http://github.com/fuCtor/mswallet/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
