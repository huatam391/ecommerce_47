class OrderItemsController < ApplicationController
  before_action :load_order, only: :index

  def index
    @order_items = OrderItem.find_by_order_id params[:order_id]
  end

  private

  def load_order
    @order = Order.find_by id: params[:order_id]
    valid_object @order
  end
end
