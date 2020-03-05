class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.digest(password)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(password, cost: cost)
  end
end
