module Admin
  class ProductsController < ApplicationController
    before_action :find_product, except: %i(index new create)
    before_action :load_category, except: %i(index destroy)

    def index
      @products = Product.load_product.order_by_id
        .paginate page: params[:page], per_page: Settings.paginate.per_page
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new product_params
      if @product.save
        flash[:success] = t ".create_success"
      else
        render :new
      end
    end

    private

    def product_params
      params.require(:product).permit :category_id, :name, :image, :price, :quantity
    end

    def find_product
      @product = Product.find_by id: params[:id]
      valid_object @product
    end

    def load_category
      @categories = Category.all.map {|x| x.name}
    end
  end
end
