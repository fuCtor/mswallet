require 'rspec'

describe Mswallet do

  it 'should be wallet version eq 1' do
    expect(Mswallet::WALLET_VERSION).to be_eql('1')
  end
end