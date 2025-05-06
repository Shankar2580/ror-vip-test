require 'rails_helper'

RSpec.describe Order, type: :model do
  it "check editibility" do
    order = Order.create!(external_id: 'TEST222', placed_at: Time.current)
    expect(order.editable?).to be true

    order.update!(created_at: 20.minutes.ago)
    expect(order.editable?).to be false
  end
end
