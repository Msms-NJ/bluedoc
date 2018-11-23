class Reaction < ApplicationRecord
  belongs_to :subject, polymorphic: true, required: false
  belongs_to :user, required: false

  ALLOW_NAMES = %w[+1 -1 grin confetti_ball confused heart bouquet]

  before_validation :validate_name
  def validate_name
    if Twemoji.find_by_text(self.text).blank?
      self.errors.add(:name, "is an invalid emoji name")
    end
  end

  def self.allow_reactions
    return @allow_reactions if defined? @allow_reactions
    @allow_reactions = []
    ALLOW_NAMES.each do |name|
      @allow_reactions << Reaction.new(name: name)
    end
    @allow_reactions
  end

  def self.create_reaction(name, subject, user: nil)
    user ||= Current.user
    Reaction.find_or_create_by!(subject: subject, name: name.strip, user: user)
  rescue ActiveRecord::RecordNotUnique
    Reaction.where(subject: subject, name: name.strip, user: user).first
  end

  def self.destroy_reaction(name, subject, user:)
    Reaction.where(subject: subject, name: name.strip, user: user).destroy_all
  end

  def self.grouped
    joins(:user)
      .group(:name)
      .select("min(reactions.id) as id, reactions.name as name, array_agg(users.slug) as group_user_slugs")
      .order("id asc")
      .to_a
  end

  def group_user_slugs
    self[:group_user_slugs] || []
  end

  def group_count
    group_user_slugs.length
  end

  def url
    @url ||= "/twemoji/svg/#{Twemoji.find_by_text(text)}.svg"
  end

  def unicode
    @unicode ||= Twemoji.render_unicode(text)
  end

  def text
    @emoji_text ||= ":#{self.name}:"
  end
end
