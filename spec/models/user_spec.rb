require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    user = build(:user)
    expect(user).to be_valid
  end

  describe 'associations' do
    it 'has many lessons' do
      assoc = described_class.reflect_on_association(:lessons)
      expect(assoc.macro).to eq(:has_many)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end
  end

  describe 'validations' do
    it 'requires email presence' do
      u = build(:user, email: nil)
      expect(u).not_to be_valid
      expect(u.errors[:email]).to include("can't be blank")
    end

    it 'requires email format' do
      u = build(:user, email: 'not-an-email')
      expect(u).not_to be_valid
      expect(u.errors[:email]).to include('is invalid')
    end

    it 'validates email uniqueness' do
      existing = create(:user, email: 'unique@example.com')
      u = build(:user, email: existing.email)
      expect(u).not_to be_valid
      expect(u.errors[:email]).to include('has already been taken')
    end

    it 'validates email length maximum 255' do
      long = "#{'a' * 256}@example.com"
      u = build(:user, email: long)
      expect(u).not_to be_valid
      expect(u.errors[:email]).to include('is too long (maximum is 255 characters)')
    end

    it 'validates password presence and length' do
      u = build(:user, password: nil, password_confirmation: nil)
      expect(u).not_to be_valid
      u2 = build(:user, password: 'short', password_confirmation: 'short')
      expect(u2).not_to be_valid
      expect(u2.errors[:password]).to include('is too short (minimum is 8 characters)')
    end

    it 'requires password confirmation' do
      u = build(:user, password: 'password123', password_confirmation: nil)
      expect(u).not_to be_valid
      expect(u.errors[:password_confirmation]).to include("can't be blank")
    end
  end
end
