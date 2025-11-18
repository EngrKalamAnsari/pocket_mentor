require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  it 'has default from address set' do
    expect(ApplicationMailer.default[:from]).to eq('from@example.com')
  end

  it 'uses mailer layout' do
    expect(ApplicationMailer._layout).to eq('mailer')
  end
end
