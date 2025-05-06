class OrdersController < ApplicationController

    def create
        order = Order.find_by(external_id: params[:external_id]) if params[:external_id]

        if order&.present?
            unless order.editable?
                return render json: { error: "LockedForEdit" }, status: :unprocessable_entity
            end

            order.line_items.original.update_all(original: false)
        else
            order = Order.new(external_id: params[:external_id], placed_at: params[:placed_at] )
        end

        Order.transaction do
            order.save!
            params[:line_items].each do |li|
                order.line_items.create(sku: li[:sku], quantity: li[:quantity])
            end
        end

        SkuStatJob.perform_later(order.line_items.pluck(:sku).uniq)

        render json: { status: 'ok'}
    end

    def lock
        order = Order.find(params[:id])
        order.update!(locked_at: Time.current)

        SkuStatJob.perform_later(order.line_items.pluck(:sku).uniq)
        render json: {status: 'locked'}
    end

    def sku_summary
        summary = SkuStat.where(sku: params[:sku]).select(:week, :total_quantity)

        render json: {sku: params[:sku], summary: summary}

    end
end