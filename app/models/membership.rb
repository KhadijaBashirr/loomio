class Membership < ActiveRecord::Base
  ACCESS_LEVELS = ['request', 'member', 'admin']
  MEMBER_ACCESS_LEVELS = ['member', 'admin']

  #
  # VALIDATIONS
  #

  class MemberOfParentGroupValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      if object.group_parent.present? && !object.group_parent.users_include?(value)
        object.errors.add attribute, "must be a member of this group's parent"
      end
    end
  end

  validates :user, member_of_parent_group: true
  validates_presence_of :group, :user
  validates_inclusion_of :access_level, :in => ACCESS_LEVELS
  validates_uniqueness_of :user_id, :scope => :group_id

  #
  # ASSOCIATIONS
  #

  belongs_to :group
  belongs_to :user

  #
  # ATTRIBUTES / SCOPES / DELEGATES
  #

  attr_accessible :group_id, :access_level

  scope :for_group, lambda {|group| where(:group_id => group)}
  scope :with_access, lambda {|access| where(:access_level => access)}

  delegate :name, :email, :to => :user, :prefix => true
  delegate :parent, :to => :group, :prefix => true, :allow_nil => true

  #
  # CALLBACKS
  #

  after_initialize :set_defaults
  before_destroy :remove_open_votes

  #
  # PUBLIC METHODS
  #

  def can_be_made_admin_by?(user)
    group.admins.include? user
  end

  def can_be_made_member_by?(user)
    group.users.include? user
  end

  def can_be_deleted_by?(user)
    # Admins can delete everyone except admins
    return false if group.admins.include?(self.user)
    return true if group.admins.include?(user)

    return true if self.user == user
    return true if (access_level == 'request' && group.users.include?(user))
  end

  #
  # PRIVATE METHODS
  #

  private
    def remove_open_votes
      user.votes.each do |vote|
        motion = Motion.find(vote.motion_id)
        if motion.voting?
          vote.destroy
        end
      end
    end
    def set_defaults
      self.access_level ||= 'request'
    end
end
