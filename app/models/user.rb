class User < ApplicationRecord 
  has_many :challenges

  def name 
    [first_name, last_name].join(' ') 
  end 
  
  def update_dynamic_attributes(auth) 
    self.first_name = auth.info.first_name 
    self.last_name = auth.info.last_name 
    self.email = auth.info.email 
  end 
  
  class << self 
    def find_or_create_with_omniauth(auth) 
      user = find_by(auth.slice(:provider, :uid)) || initialize_from_omniauth(auth) 
      user.update_dynamic_attributes(auth) 
      user.save! 
      user 
    end 

    def initialize_from_omniauth(auth) 
      new do |user| 
        user.provider = auth.provider 
        user.uid = auth.uid 
      end 
    end
  end 
end