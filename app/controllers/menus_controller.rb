class MenusController < ApplicationController
  before_filter :user_logedin?, :only => "checkout"

  def user_logedin?
	  redirect_to menus_url, notice: 'Please select atleast one pizza to checkout' and return if session[:order_ids].nil?
	  redirect_to :sign_in if !user_signed_in?
  end

  def logout
	  redirect_to :sign_out
  end


  def index

    @menus = Menu.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @menus }
    end
  end

  def show
    @menu = Menu.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @menu }
    end
  end

  def new
    @menu = Menu.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @menu }
    end
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def create
	  params[:menu]["image"] = params[:menu]["image"].tempfile.read
    @menu = Menu.new(params[:menu])

    respond_to do |format|
      if @menu.save
        format.html { redirect_to @menu, notice: 'Menu was successfully created.' }
        format.json { render json: @menu, status: :created, location: @menu }
      else
        format.html { render action: "new" }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @menu = Menu.find(params[:id])

    respond_to do |format|
      if @menu.update_attributes(params[:menu])
        format.html { redirect_to @menu, notice: 'Menu was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy

    respond_to do |format|
      format.html { redirect_to menus_url }
      format.json { head :no_content }
    end
  end

  def order
	  (session[:order_ids].blank?) ? (session[:order_ids] = [params[:id]]) : (session[:order_ids] << params[:id] )
	  respond_to do |format|
	  	if session[:order_ids].size.eql?(0)
			format.html { redirect_to menus_url, notice: 'Failed to place an order.' }
	  	else
			format.html { redirect_to menus_url, notice: "Successfully added to cart"}
	       	end
	  end
  end

  def update_address
	  User.find(params[:id]).update_attributes!(:address => params[:addr]) 
	  session[:order_ids] = nil
	  respond_to do |format|
		  format.html { redirect_to menus_url, notice: "Successfully placed order at #{params[:addr]} by #{current_user.email}" }
		  format.json { head :no_content }
	  end   
  end

  def checkout
	  if current_user.address.nil?
	  	  @user = current_user
		  render :get_address
	  else
		  session[:order_ids]=nil
		  redirect_to menus_url, notice: "Successfully placed pick up order at #{current_user.address} by #{current_user.email}"
	  end
  end
end
