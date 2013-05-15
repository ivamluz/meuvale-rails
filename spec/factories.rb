FactoryGirl.define do
  factory :card do
    card_type 'visa-vale'
    sequence(:number) { |n| 1234567890123450 + n }
    sequence(:available_balance) { |n| 260 - n }
    last_charged_at 1.months.ago
    next_charge = 1.months.from_now
    last_charge_amount 260
    next_charge_amount 260
    sequence(:created_at) { |n| (n - 1).days.ago }
    sequence(:updated_at) { |n| (n - 1).days.ago }
    transactions_hash "a11a" * 10
  end

  factory :card_transaction do
    sequence(:date) { |n| n.days.ago }
    sequence(:description) { |n| "Restaurant #{n}" }
    sequence(:amount) { |n| n * 2.25 }

    card
  end
end