# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    action { "star_repo" }
    association :user
    association :actor, factory: :user
    association :target, factory: :repository
  end
end
