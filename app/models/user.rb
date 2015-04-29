class User < ActiveRecord::Base
  #enum role: [:user, :vip, :admin]
  enum role: [:guest, :user, :admin, :mulettista, :agenzia_booking]
  after_initialize :set_default_role, :if => :new_record?

  scope :extjs_default_scope, -> {}

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         

  #per current_user nei models
  def self.current=(user)
    Thread.current[:current_user] = user
  end

  def self.current
    Thread.current[:current_user]
  end         
         
end
