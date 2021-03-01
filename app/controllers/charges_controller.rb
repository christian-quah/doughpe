class ChargesController < ApplicationController
  def new
    @basket = Basket.find(params[:basket_id])
    session[:basket_id] = @basket.id
  end

  def create
  # Amount in cents
  @basket = Basket.find(params[:basket_id])
  @orders = Order.where(basket: @basket)
  total_qty = 0
  total = 0

  @orders.each do |order|
    total_qty += order.quantity
    # total += order.subtotal
  end

  if @basket.nil?
    redirect_to root_path
    return
  end

  @session = Stripe::Checkout::Session.create(
    payment_method_types: ['card'],
    line_items: [
      {
        name: 'Total',
        amount: (@basket.total * 100).to_i,
        currency: 'sgd',
        quantity: 1
      }
    ],
    success_url: charges_success_url + '?session_id={CHECKOUT_SESSION_ID}',
    cancel_url: charges_cancel_url
    )

  respond_to do |format|
      format.js # renders create.js.erb
    end
  end

  def success
    @basket = Basket.find(params[:basket_id])
    @orders = Order.where(basket: @basket)
    if !params[:session_id].nil?
      @session = Stripe::Checkout::Session.retrieve(params[:session_id])
      @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)
    #   render json: {
    #   :forward => "success.html.erb"
    # }
    render 'success', locals: { order: @orders, user: current_user, basket: @basket}
    Order.where(basket: @basket).first.basket.update(completed: true)
    session[:basket_id] = nil

    @orders.each do |order|
      @slot = Slot.where(id: order.slot.id)
      available_quantity = @slot.first.available_quantity
      @slot.update(available_quantity: available_quantity - 1)
      order.update(delivered: true)
    end

  else
    @orders = @orders.where(delivered: true)
    render 'success', locals: { order: @orders, user: current_user, basket: @basket}
  end
end
end
