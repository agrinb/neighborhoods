class NeighborhoodsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    if params[:q].present?
      @results = Search.new(params[:q])
      @neighborhoods = @results.map do |result|
        if result.class == Review
          result.neighborhood
        else
          result
        end
      end
      @neighborhoods.uniq!

      @neighborhoods = Kaminari.paginate_array(@neighborhoods).page(params[:page]).per(10)
    else
      @neighborhoods = Neighborhood.all.page(params[:page])
    end
  end

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    @neighborhood = current_user.neighborhoods.build(neighborhood_params)

    if @neighborhood.save
      NeighborhoodMailer.new_neighborhood_email(@neighborhood).deliver
      flash[:notice] = "Success! Your neighborhood is pending approval."
      redirect_to neighborhood_path(@neighborhood)
    else
      flash[:alert] = "Could not save."
      render :new
    end
  end

  def show
    @neighborhood = Neighborhood.find(params[:id])
    @reviews = @neighborhood.reviews.order(upvotes: :desc)
    if !current_user
      flash[:alert] = 'Please sign in to vote on reviews.'
    end
  end

  private

  def neighborhood_params
    params.require(:neighborhood).permit(:name, :description)
  end
end
