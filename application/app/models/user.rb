class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :trackable

  validates :name,
            length: { minimum: 1, maximum: 20 }
end
