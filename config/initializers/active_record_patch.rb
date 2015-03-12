class ActiveRecord::Base
  
  before_create :set_created_user_id
  before_save :set_updated_user_id

  def set_created_user_id
    begin
      self.updated_user_id = User.current.id
      self.created_user_id = User.current.id
    rescue
    end
  end
  
  def set_updated_user_id
    begin
      self.updated_user_id = User.current.id
    rescue
    end
  end
  
end