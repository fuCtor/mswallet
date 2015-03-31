[![Build Status](https://travis-ci.org/fuCtor/mswallet.svg)](https://travis-ci.org/fuCtor/mswallet)

# Mswallet

[English version](https://github.com/fuCtor/mswallet/blob/master/README.md)

Гем для генерации mswallet файлов для приложения Кошелек на платформе WP8+.

## Установка

Для установки добавьте в ваш Gemfile:

    gem 'mswallet'

И выполните:

    $ bundle

Или можете установить вручную:

    $ gem install mswallet

## Конфигурирование
Если вы хотиет поддерживать запросы на обновление карточек, вы можете добавить Rack::PassbookRack к вашим middleware. В Rails это будет выглядеть так:

    config.middleware.use Rack::PassbookRack

По-умолчанию для обработки запросов используется класс Mswallet::handler, но вы можете установить свой:

    Mswallet.custom_rack_handler  = MyCustomHandler

    # или

    Mswallet.configure do |m|
      m.custom_rack_handler  = MyCustomHandler
    end

## Использование

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

    # Или потоком

    mswallet = pass.stream
    send_data mswallet.string, type: 'application/vnd.ms.wallet', disposition: 'attachment', filename: "pass.mswallet"

## Внесение изменений

1. Fork it ( http://github.com/fuCtor/mswallet/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
