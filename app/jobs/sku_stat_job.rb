class SkuStatJob < ApplicationJob
  queue_as :default

  def perform(sku)
    skus.each do |sku|
      calculate(sku)
    end
  end

  def calculate(sku)
    summary = {}
    1.upto(4) do |i|
      week_start = (Time.current.beginning_of_week - 1.weeks)
      week_key = week_start.strftime('%G-W%V')
      week_end = week_start.end_of_week

      line_items = LineItem.joins(:order).where(sku: sku, original: true)
                                         .where(orders: {placed_at: week_start..week_end})
      total = line_items.sum(:quantity)
      summary[week_key] = total
    end

    summary.each do |week, total_quantity|
      SkuStat.upsert({sku: sku, week: week, total_quantity: total_quantity},
      unique_by: %i[sku week])
    end
  end
end
