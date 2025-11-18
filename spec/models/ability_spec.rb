require 'rails_helper'

RSpec.describe Ability do
  let(:user) { build(:user) }
  let(:persisted_user) { create(:user) }
  let(:other_user) { create(:user) }

  context 'for guest user' do
    it 'cannot create lessons' do
      ability = Ability.new(nil)
      expect(ability.can?(:create, Lesson)).to be false
    end
  end

  context 'for new but not persisted user' do
    it 'cannot create lessons' do
      ability = Ability.new(user)
      expect(ability.can?(:create, Lesson)).to be false
    end
  end

  context 'for persisted user' do
    it 'can create lessons' do
      ability = Ability.new(persisted_user)
      expect(ability.can?(:create, Lesson)).to be true
    end

    it 'can read own lessons' do
      ability = Ability.new(persisted_user)
      own_lesson = build(:lesson, user: persisted_user)
      expect(ability.can?(:read, own_lesson)).to be true
    end

    it "cannot read someone else's lesson" do
      ability = Ability.new(persisted_user)
      other_l = build(:lesson, user: other_user)
      expect(ability.can?(:read, other_l)).to be false
    end
  end
end
