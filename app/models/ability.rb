# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    # Logged-in users can create lessons
    if user.present? && user.persisted?
      can :create, Lesson

      # Users can read their own lessons and manage them
      can :read, Lesson, user_id: user.id
    end

    # Optionally restrict other resources similarly
  end
end
