class OrdersController < ApplicationController
  before_filter :initialize_cart

  def create
    @order_form = OrderForm.new(
      user: User.new(order_params[:user]),
      cart: @cart
      )

    if @order_form.save
      notify_user
      redirect_to root_path, notice: "Thank you for placing the order."
    else
      render "carts/checkout"
    end
  end

  private

  def notify_user
    @order_form.user.send_reset_password_instructions # method available in user class; send email regarding password reset
  end

  def order_params
    params.require(:order_form).permit(
      user: [ :name, :phone, :address, :city, :country, :postal_code, :email ]
      )
  end

end