class TabConfig < ActiveRecord::Base
  scope :extjs_default_scope, -> {}
    
  def self.get_notes(tab, sez1, sez2 = nil)
    r = self.where(tab: tab, sez1: sez1, sez2: sez2).first
    return r.notes if r
  end
end
