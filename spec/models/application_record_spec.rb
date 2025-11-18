require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  it 'is an abstract class' do
    expect(ApplicationRecord.abstract_class?).to be true
  end

  it 'can be subclassed for models' do
    klass = Class.new(ApplicationRecord)
    expect(klass < ApplicationRecord).to be true
  end
end
