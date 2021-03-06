class UsersController < ApplicationController

  def show
    if current_user.kind == "owner"
      @loyalty = {}
      @restaurant = current_user.restaurant
      @bookings = @restaurant.bookings.sort_by{|booking_sort| booking_sort[:day]}
      @bookings.each do |booking|
        @loyalty[booking.user.email] = booking.user.loyalty_points
      end
      @loyalty = @loyalty.sort_by {|key, value| value}.reverse.to_h
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.kind = params[:kind]

    if @user.save
      session[:user_id] = @user.id
      if @user.kind == "owner"
        redirect_to new_user_restaurant_url(@user)
      else
        redirect_to root_url
      end
    else
      flash.now[:alert] = @user.errors.full_messages
      render :new
    end
  end

end
