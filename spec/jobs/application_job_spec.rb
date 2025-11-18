require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it 'is a subclass of ActiveJob::Base' do
    expect(ApplicationJob < ActiveJob::Base).to be true
  end

  it 'can be instantiated and performs no-op' do
    job = ApplicationJob.new
    expect(job).to be_a(ApplicationJob)
  end
end
