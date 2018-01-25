class BookingsController < ApplicationController
  before_action :ensure_logged_in, only: [:create, :index]

  def index
    @user = User.find(session[:user_id])
    @bookings = @user.bookings
  end

  def create
    @restaurant = Restaurant.find(params[:restaurant_id])
    @booking = @restaurant.bookings.new(booking_params)
    @booking.user = current_user

    if @booking.save
      points = @booking.user.increment(:loyalty_points, by = 100)
      points.save
      flash[:notice] = ["Reservation made at #{@restaurant.name} on #{@booking.day.strftime("%B %d, %Y")} at #{@booking.time_to_am_pm}"]
      redirect_to user_bookings_path(current_user)
    else
      render "restaurants/show"
    end
  end

  def booking_params
    params.require(:booking).permit(:day, :n_people, :time)
  end

  private

  def ensure_logged_in
    unless current_user
      flash[:alert] = ["You must be logged in to create or view reservations"]
      redirect_to restaurant_path(params[:restaurant_id])
    end
  end



end
