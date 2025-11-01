class Ride < ApplicationRecord
  belongs_to :rider , class_name: "User"
  belongs_to :driver, class_name: "User"
end
