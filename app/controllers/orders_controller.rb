class OrdersController < ApplicationController
  before_action :find_order, only: :cancel
  before_action :load_orders, only: %i(cancel index)
  before_action :check_cart_empty, only: :create
  before_action :current_cart, :quantity_in_cart, only: %i(new create)

  def index; end

  def new
    @order = Order.new
  end

  def create
    ActiveRecord::Base.transaction do
      @order = Order.new order_params
      if @order.save!
        producs_of_current_cart = Product.load_product_by_ids session[:cart].keys
        producs_of_current_cart.each do |product|
          product.quantity_in_cart = session[:cart][product.id.to_s]
          unit_price = (product.price).to_i
          total_price = product.quantity_in_cart * unit_price
          order_item = @order.order_items.new(order_id: @order.id, product_id: product.id,
            quantity: product.quantity_in_cart, unit_price: unit_price,
            total_price: total_price)
          order_item.save!
        end
        create_order_success
      end
    end
  rescue
    flash[:danger] = t ".order_fail"
    render :new
  end

  def cancel
    @order.cancelled!
    rollback_quantity @order
    respond_to do |format|
      format.json {}
      format.js {}
    end
  end

  private

  def order_params
    params.require(:order).permit :user_id, :total_price, :customer_name, :customer_phone,
      :customer_address, :customer_city, :customer_country
  end

  def redirect_if_cart_empty
    flash[:danger] = t ".empty_cart"
    redirect_to carts_url
  end

  def update_product_quantity order
    order.order_items.each do |detail|
      detail.product.decrement!(:quantity, detail.quantity) if detail.persisted?
    end
  end

  def find_order
    @order = Order.find_by id: params[:id_order]
    valid_object @order
  end

  def rollback_quantity order
    order.order_items.each do |detail|
      detail.product.increment!(:quantity, detail.quantity) if detail.persisted?
    end
  end

  def load_orders
    @orders = current_user.orders.newest
      .paginate page: params[:page], per_page: Settings.paginate.per_page
  end

  def check_cart_empty
    return redirect_if_cart_empty if (session[:cart].empty? || session[:cart].size == Settings.quantity.zero)
  end

  def create_order_success
    flash[:success] = t ".order_success"
    session[:cart] = {}
    redirect_to root_url
  end
end
