class User < ActiveRecord::Base
  
  
  ###################################### login by username ############################################
  #https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  attr_accessor :login
  
  validates :username,
    :presence => true,
    :uniqueness => {
      :case_sensitive => false
    }
  validate :validate_username
  
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end  
  
  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end
  
  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end  
  #####################################################################################################
  
  
  #enum role: [:user, :vip, :admin]
  enum role: [:guest, :user, :admin, :mulettista, :agenzia, :sottobordo, :officina, :terminal, :customer]
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
 
  
 #gestione permessi
  def can?(model, op)

    #admin puo' fare tutto
    if self.admin?
      return true
    end
    
    if self.agenzia? && (op == :view || model == :booking) 
      return true
    end
    
    #prezzi fornitore riparazioni
    if (model == :repair and op == :price_provider)
      return true if [1,2,4,25].include?(self.id) #solo Gianma/Michela/Violini
      return false
    end
    
    
    #default
    return false
  end
  
  
  #gestione permessi speciali per admin
   def admin_can?(model, op)
 
     #esco se non admin
     if !self.admin?
       return false
     end
     
     if (model == :repair and op == :price)
       return true if [1,2,4].include?(self.id) #solo Gianma/Michela
       return false
     end
     
     #solo alcuni possono vedere/manutenere le tabelle repair
     if [1,2,4,38].include?(self.id) 
       return true
     end
     
     #default
     return false
   end

end
