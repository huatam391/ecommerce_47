class CartsController < ApplicationController
  before_action :logged_in_user, only: :index
  before_action :set_cart
  before_action :find_product, except: :index
  before_action :current_cart, only: :index

  def index; end

  def add_cart
    if session[:cart].key?(@product.id.to_s)
      session[:cart][@product.id.to_s] += Settings.quantity.default
    else
      session[:cart][@product.id.to_s] = Settings.quantity.default
    end
      respond_to do |format|
        format.html { render "static_pages/home" }
        format.json {}
        format.js
      end
  end

  def current_cart
    @producs_of_current_cart = Product.load_product_by_ids session[:cart].keys
    @producs_of_current_cart.each do |item|
      item.quantity_in_cart = session[:cart][item.id.to_s]
    end
  end

  def remove_cart
    session[:cart].delete @product.id.to_s if session[:cart].key?(@product.id.to_s)
    redirect_to carts_url
  end

  def update_hard_cart
    return render_validate_fail unless validate_quantity_cart @product, params[:quantity].to_i, true
    session[:cart][@product.id.to_s] = params[:quantity].to_i if session[:cart].key?(@product.id.to_s)
    redirect_to carts_url
  end

  private

  def validate_quantity_cart product, quantity, update_hard = false
    if update_hard || !session[:cart].key?(@product.id.to_s)
      product.quantity >= quantity
    else
      product.quantity >= (quantity + session[:cart][@product.id.to_s])
    end
  end

  def render_validate_fail
    flash[:danger] = t ".validate_quantity_fail"
    redirect_to carts_url
  end

  def find_product
    @product = Product.find_by id: params[:id_product]
    valid_object @product
  end
end
