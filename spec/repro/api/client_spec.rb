require 'spec_helper'
require 'json'

RSpec.describe Repro::Api::Client do

  before do
    WebMock.enable!
  end

  it 'has a version number' do
    expect(Repro::Api::Client::VERSION).not_to be nil
  end

  it 'can set token' do
    client = Repro::Api::Client.new('token')
    expect(client.token).to eq 'token'
  end

  describe '#push_deliver' do
    context 'when request success' do
      it 'receives status accepted' do
        client = Repro::Api::Client.new('token')
        response = {body: JSON.generate(status: 'accepted')}
        stub_request(:post, 'https://marketing.repro.io/v1/push/test/deliver')
          .to_return(response)
        expect(client.push_deliver('test', [], {body: 'test'}).body).to eq({'status' => 'accepted'})
      end
    end
  end
end
