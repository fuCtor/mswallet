require 'rspec'

describe Rack::MswalletRack do

  let(:serial) { '1' }
  let(:update_path) { "/v1/walletitems/#{serial}" }
  let(:auth_token) {"3c0adc9ccbcf3e733edeb897043a4835"}

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
  let :pass do
    p = Mswallet::Pass.new wallet
    [99, 159, 336].each do |size|
      p.add_file name: "Logo#{size}x#{size}.png", content: ''
    end
    p
  end

  context 'find id' do
    let(:wallet_rack) {Rack::MswalletRack.new nil}
    shared_examples_for 'id that can handle non wallet urls' do
      context 'incomplete wallet api path' do
        subject {wallet_rack.find_id('/1/walletitems/')}
        it {should eq nil}
      end
      context 'no version api path' do
        subject {wallet_rack.find_id('/walletitems/123')}
        it {should eq nil}
      end
    end

    context 'device update pass' do
      context 'a valid path' do
        subject {wallet_rack.find_id(update_path)}
        it {should eq(serial) }
      end
      it_behaves_like 'id that can handle non wallet urls'
    end
  end

  context 'rack middleware' do
    let(:result) { nil }
    before do
      expect(Mswallet::Handler).to receive(:update).with(serial_number: serial).and_return (result)
      get update_path
    end
    subject { last_response.status }

    context 'get update pass with exist serial' do
      context 'with MSwallet::Pass result' do
        let(:result) { pass }
        it { should eq 200 }
      end

      context 'with string result' do
        let(:result) { '' }
        it { should eq 200 }
      end

      context 'with IO result' do
        let(:result) { StringIO.new '' }
        it { should eq 200 }
      end


    end

    context 'get update pass with wrong serial' do
      it { should eq 401 }
    end

    context 'get update for unchanged pass' do
      let(:result) { false }
      it { should eq 304 }
    end

  end

end


require 'rack/test'
include Rack::Test::Methods
def app
  test_app = lambda do |env|
    [200, {}, 'test app']
  end
  Rack::MswalletRack.new test_app
end

class Mswallet::Handler
  def self.update(options)

  end
end