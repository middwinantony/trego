class Payment < ApplicationRecord
  belongs_to :ride

  # Calculate total payment including tip
  def total_amount
    amount.to_f + tip_amount.to_f
  end
end
