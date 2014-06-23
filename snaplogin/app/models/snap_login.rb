class SnapLogin < ActiveRecord::Base
  def to_param
    token
  end
end
