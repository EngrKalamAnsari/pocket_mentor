require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  it 'is defined and is a Module' do
    expect(defined?(ApplicationHelper)).to eq('constant')
    expect(ApplicationHelper).to be_a(Module)
  end

  it 'can be included into a class' do
    klass = Class.new { include ApplicationHelper }
    expect(klass.ancestors).to include(ApplicationHelper)
  end
end
