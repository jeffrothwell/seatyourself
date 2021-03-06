class BookingsController < ApplicationController
  before_action :ensure_logged_in, only: [:create, :index]

  def index
    @user = User.find(session[:user_id])
    @bookings = @user.bookings.sort_by{|booking| booking[:day]}
  end

  def create
    @restaurant = Restaurant.find(params[:restaurant_id])
    @booking = @restaurant.bookings.new(booking_params)
    @booking.time = convert_time_string_to_integer(params[:booking][:time])
    @booking.user = current_user

    if @booking.save
      points = @booking.user.increment(:loyalty_points, by = 100)
      points.save
      flash[:notice] = ["Reservation made at #{@restaurant.name} on #{@booking.day.strftime("%B %d, %Y")} at #{time_to_am_pm(@booking.time)}"]
      redirect_to user_bookings_path(current_user)
    else
      @booking_times_array = booking_times_array(@restaurant)
      render "restaurants/show"
    end
  end

  def booking_params
    params.require(:booking).permit(:day, :n_people)
  end

  private

  def ensure_logged_in
    unless current_user
      flash[:alert] = ["You must be logged in to create or view reservations"]
      redirect_to restaurant_path(params[:restaurant_id])
    end
  end

  def convert_time_string_to_integer(time_string)
    mini_array = time_string.split(":00")
    if mini_array[1] == "PM" && mini_array[0] != 12
      return mini_array[0].to_i + 12
    else
      return mini_array[0].to_i
    end
  end

end
