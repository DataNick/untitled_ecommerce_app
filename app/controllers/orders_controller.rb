class OrdersController < ApplicationController
  before_filter :initialize_cart

  def index
    @orders = Order.order(created_at: :desc).all
  end

  def create
    @order_form = OrderForm.new(
      user: User.new(order_params[:user]),
      cart: @cart
      )

    if @order_form.save
      notify_user
      if charge_user
        redirect_to root_path, notice: "Thank you for placing the order."
      else
        flash[:warning] = <<EOF
We have stored your order with the id of #{@order_form.order.id}.
You should receive an email with the order details and password change.<br/>
However, something went wrong with your credit card, please add another one.
EOF
        redirect_to new_payment_order_path(@order_form.order)
    else
      render "carts/checkout"
    end
  end

  def update
    @order = Order.find(params[:id])
    @previous_state = @order.state
    if @order.update(state_order_params)
      notify_user_about_state
      redirect_to orders_path, notice: "Order was updated."
    end
  end

  def new_payment #form to enter new credit card
    @order = Order.find(params[:id]) #create a form that respects this order object
    @client_token = Braintree::ClientToken.generate
  end

  def pay #same function as the charge user method
    @order = Order.find(params[:id])
    transaction = OrderTransaction.new(@order, params[:payment_method_nonce])
    transaction.execute
    if transaction.ok?
      redirect_to root_path, notice: "Thank you for placing the order."
    else
      render "orders/new_payment"
    end
  end

  private

  def notify_user
    @order_form.user.send_reset_password_instructions # method available in user class; send email regarding password send_reset_password_instructions
    OrderMailer.order_confirmation(@order_form.order).deliver
  end

  def notify_user_about_state
    OrderMailer.state_changed(@order, @previous_state).deliver
  end

  def order_params
    params.require(:order_form).permit(
      user: [ :name, :phone, :address, :city, :country, :postal_code, :email ]
      )
  end

  def state_order_params
    params.require(:order).permit(:state) #order only contains state variable
  end

  def charge_user
    transaction = OrderTransaction.new(@order, params[:payment_method_nonce])
    transaction.execute
    transaction.ok?
  end

end