class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.newest
      .paginate page: params[:page], per_page: Settings.paginate.per_page
  end

  def new
    @order = Order.new
  end

  def create
    ActiveRecord::Base.transaction do
      @order = Order.new order_params
      if @order.save
        return redirect_if_cart_empty unless session[:cart].present?
        @producs_of_current_cart = Product.load_product_by_ids session[:cart].keys
        @producs_of_current_cart.each do |product|
          product.quantity_in_cart = session[:cart][product.id.to_s]
          unit_price = (product.price).to_i
          total_price = product.quantity_in_cart * unit_price
          @order.order_items.save!(product_id: product.id,
            quantity: product.quantity_in_cart,
            unit_price: unit_price,
            total_price: total_price)
        end
        flash[:success] = t ".order_success"
        session[:cart] = nil
        redirect_to root_url
      else
        flash[:danger] = t ".order_fail"
        render :new
      end
    end
  end

  private

  def order_params
    params.require(:order).permit :user_id, :customer_name, :customer_phone,
      :customer_address, :customer_city, :customer_country
  end

  def redirect_if_cart_empty
    flash[:danger] = t ".empty_cart"
    redirect_to carts_url
  end
end
