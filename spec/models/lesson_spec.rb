require 'rails_helper'

RSpec.describe Lesson, type: :model do
	it 'has a valid factory' do
		lesson = build(:lesson)
		expect(lesson).to be_valid
	end

	describe 'associations' do
		it 'belongs to a user' do
			assoc = described_class.reflect_on_association(:user)
			expect(assoc.macro).to eq(:belongs_to)
		end
	end

	describe 'validations' do
		it 'validates presence of topic' do
			lesson = build(:lesson, topic: nil)
			expect(lesson).not_to be_valid
			expect(lesson.errors[:topic]).to include("can't be blank")
		end

		it 'validates presence of level' do
			lesson = build(:lesson, level: nil)
			expect(lesson).not_to be_valid
			expect(lesson.errors[:level]).to include("can't be blank")
		end

		it 'validates topic length maximum 150' do
			lesson = build(:lesson, topic: 'a' * 151)
			expect(lesson).not_to be_valid
			expect(lesson.errors[:topic]).to include('is too long (maximum is 150 characters)')
		end

		it 'validates level inclusion in Levels' do
			expect(Lesson::Levels).to include('beginner', 'intermediate', 'advanced')
			lesson = build(:lesson, level: 'expert')
			expect(lesson).not_to be_valid
			expect(lesson.errors[:level]).to include('is not included in the list')
		end
	end
end
