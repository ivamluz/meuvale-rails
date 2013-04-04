FactoryGirl.define do
  factory :card do
    card_type 
    sequence(:number) { |n| 1234567890123450 + n }
    sequence(:available_balance) { 260 - n }
    last_charged_at 1.months.ago
    next_charge = 1.months.from_now
    last_charge_amount 260
    next_charge_amount 260
  end

  factory :card_transaction do
    sequence(:date) { |n| n.days.ago }
    sequence(:description) { |n| "Restaurant #{n}" }
    sequence(:amount) { |n| n * 2.25 }

    card
  end
end