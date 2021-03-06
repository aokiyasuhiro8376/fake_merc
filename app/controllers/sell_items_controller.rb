class SellItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :destroy, :update]
  before_action :sell_item, only: [:show, :edit, :destroy]
  before_action :item_present?, only: [:show]
  before_action :redirect_save_item, only: [:new, :create, :edit, :update]
  after_action :redirect_save_item, only: [ :create, :update]

  def new
    @item = Item.new
    @item.images.new
    @sellItem = SellItem.new
    @mainCategory = Category.where(ancestry: '1')
  end

  def create
    @item = Item.new(item_params)
    if @item.images.empty?
      @item.images.new
      render :new
    elsif @item.save
      @sellItem = SellItem.create(item_id: @item.id, user_id: current_user.id)
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    if @sell_item[:user_id] == current_user.id
      redirect_back(fallback_location: root_path)
    end
    @personal = PersonalUser.find_by(user_id: current_user.id)
    if @personal&.prefecture_address_id
      @address = PrefectureAddress.find(@personal.prefecture_address_id)
    else
      @address = nil
    end
    @card = Card.where(user_id: current_user.id).first
    if @card.present?
      Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
      customer = Payjp::Customer.retrieve(@card.customer_id)
      @default_card_information = customer.cards.retrieve(@card.card_id)
      @exp_month = @default_card_information.exp_month.to_s
      @exp_year = @default_card_information.exp_year.to_s.slice(2, 3)
    end
  end

  def edit
    if @sell_item[:user_id] != current_user.id
      redirect_back(fallback_location: main_show_path(@item.id))
    end
  end

  def update
    respond_to do |format|
      if @item.update(item_params)
          format.html { redirect_to main_show_path(@item.id) }
          format.json { render :show, status: :created, location: @item}
      else
          format.html { redirect_to action:  :edit}
      end
    end
  end

  def destroy
    if @sell_item.destroy and @item.destroy
      redirect_to root_path
      flash[:notice] = '商品を削除しました'
    else
      redirect_back(fallback_location: root_url)
      flash[:notice] = '商品情報の削除に失敗しました'
    end
  end

  private
  def item_params
    params.require(:item).permit(:name, :money, :description, :exhibition, :soldout, :during_transaction, :category_id, :size_id, :item_condition_id, :shipping_fee_id, :brand_name, :shipping_method_id, :prefecture_address_id, :ship_date_id, images_attributes: [:image_url, :_destroy, :id])
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def item_present?
    @item = Item.find(params[:id])
    if @item.soldout
      redirect_to root_path
      flash[:notice] = '商品は存在しません'
    end
  end

  def redirect_save_item
    @mainCategory = Category.where(ancestry: '1')
  end

  def sell_item
    @sell_item = SellItem.find(params[:id])
  end
end
