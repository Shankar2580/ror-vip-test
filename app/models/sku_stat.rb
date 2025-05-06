class SkuStat < ApplicationRecord

    validates :sku, :week, :total_quantity, presence: true
end
