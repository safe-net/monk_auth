class User < ActiveRecord::Base
  acts_as_authentic

  def valid_password?(pw)
    return self.password == pw
  end
end
