require 'rspec'

describe Mswallet::Pass do

  let :fields do
    {
        'Version' => ['Format Version missing', '1' ],
        'Kind' => ['Pass Kind Identifier missing', 'General' ],
        'Id' => ['Id missing', '1'],
        'DisplayName' => ['Display Name missing' ],
        'IssuerDisplayName' => ['Issuer Display Name missing'],
        'HeaderColor' => ['Header Color missing', %W(#000000 #AABBCC)],
        'BodyColor' => ['Body Name missing', %W(#000000 #AABBCC)]
    }
  end

  let :wallet do
    w = Mswallet::Pass.init
    fields.each  do |*args|
      tag, msg, *value = args.flatten.map(&:to_s)
      el = XML::Node.new(tag)
      w.root << el

      case value
        when Array
          el.content = value.first.to_s
        when nil

        else
          el.content = value
      end
    end
    w
  end
  let :pass do Mswallet::Pass.new wallet end

  it '#init' do
    expect { wallet } .to_not raise_error
    expect( wallet ).to be_instance_of(XML::Document)
    expect( wallet.root.name ).to be_eql 'WalletItem'
    expect( wallet.root.find('Version').empty? ).to be_falsey
    expect( wallet.root.find('Version').first.content ).to be_eql(Mswallet::WALLET_VERSION)
  end

  it '#add_file' do
    expect { pass } .to_not raise_error
    expect( pass.files ).to be_empty
    expect { pass.add_file name: 'Logo336x336.png', content: ''  } .to_not raise_error
    expect( pass.files ).to_not be_empty
  end

  context 'locale' do
    it '#add_locale' do

      expect { pass } .to_not raise_error
      expect( pass.locales ).to be_empty
      expect { pass.add_locale 'ru-RU', ''  } .to_not raise_error
      expect { pass.add_locale 'ru-RU', {}  } .to_not raise_error
      expect { pass.add_locale 'ru-RU', File.new(__FILE__, 'r')  } .to_not raise_error
      expect { pass.add_locale 'ru-RU', true  } .to_not raise_error

      expect( pass.locales ).to_not be_empty
      expect( pass.locales['ru-RU'] ).to be_truthy
    end

    context 'serialize' do
      before do
        [99, 159, 336].each do |size|
          pass.add_file name: "Logo#{size}x#{size}.png", content: ''
        end

        pass.add_locale 'ru-RU', locale
      end

      context 'from string' do
        let(:locale) { '' }
        it do
          expect { pass.stream } .to_not raise_error
        end
      end

      context 'from file' do
        let(:locale) { File.new(__FILE__, 'r') }
        it do
          expect { pass.stream } .to_not raise_error
        end
      end

      context 'from hash' do
        let(:locale) { {} }
        it do
          expect { pass.stream } .to_not raise_error
        end
      end

      context 'from other' do
        let(:locale) { nil }
        it do
          expect { pass.stream } .to raise_error 'wrong locale object'
        end
      end
    end
  end


  it '#pass_check' do
    expect { pass } .to_not raise_error

    [99, 159, 336].each do |size|
      expect { pass.stream } .to raise_error /Logo#{size}x#{size}/
      expect { pass.add_file name: "Logo#{size}x#{size}.png", content: ''  } .to_not raise_error
    end

    fields.keys.reverse  do |tag|
      msg, *value = fields[tag].map(&:to_s)
      expect { pass.stream } .to_not raise_error msg

      el = wallet.root.find(tag).first

      if value
        el.content = ''
        expect { pass.stream } .to raise_error /#{tag}/
      end

      el.remove!
      expect { pass.stream } .to raise_error msg
    end
  end


  context '#[]=' do
    let(:key) {'key'}
    after do
      expect(wallet.root.find(key).first).to be_nil

      expect{ pass[key] = value }.to_not raise_error

      expect(wallet.root.find(key).first).to_not be_nil
      expect(pass[key]).to be_instance_of XML::Node
    end

    context 'string value' do
      let(:value) { 'content' }
      it do; end
    end

    context 'hash value' do
      let(:value) { { 'key2' => 'content', key3: 'content'} }
      it do; end
    end

    context 'string array value' do
      let(:value) { %w(a b c) }
      it do; end
    end

    context 'hash array value' do
      let(:value) { [{a: 1},{b: 2}] }
      it do; end
    end

    context 'nil value' do
      let(:value) { nil }
      it do; end
    end

  end

  context 'valid pass' do
    before do
      [99, 159, 336].each do |size|
        pass.add_file name: "Logo#{size}x#{size}.png", content: ''
      end

      pass.add_locale 'ru-RU', ''
    end

    it '#stream' do
      expect { pass.stream } .to_not raise_error
      expect( pass.stream.string.empty? ) .to be_falsey
    end

    it '#file' do
      expect { pass.file } .to_not raise_error
    end
  end

end