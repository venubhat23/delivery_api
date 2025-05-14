module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: [:show, :update, :destroy]
      
      # GET /api/v1/products
      def index
        products = Product.all
        render json: products, status: :ok
      end
      
      # GET /api/v1/products/:id
      def show
        render json: @product, status: :ok
      end
      
      # POST /api/v1/products
      def create
        @product = Product.new(product_params)
        
        if @product.save
          render json: @product, status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT/PATCH /api/v1/products/:id
      def update
        if @product.update(product_params)
          render json: @product, status: :ok
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/products/:id
      def destroy
        @product.destroy
        head :no_content
      end
      
      private
      
      def set_product
        @product = Product.find(params[:id])
      end
      
      def product_params
        params.permit(:name, :description, :unit_type, :available_quantity)
      end
      
      def ensure_admin
        unless current_user.admin?
          render json: { error: "Only administrators can manage products" }, status: :unauthorized
        end
      end
    end
  end
end