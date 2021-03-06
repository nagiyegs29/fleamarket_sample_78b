class ItemsController < ApplicationController
  before_action :move_to_index, except: [:index, :show]
  before_action :set_item, except: [:index, :new, :create, :get_category_children, :get_category_grandchildren]
  before_action :get_category_parents, only: [:index, :new, :show]

  def index
    @new_items = Item.where(status: true).order("created_at DESC").limit(5)
  end

  def show
  end

  def new
    @item = Item.new
    @item.images.new
    #データベースから、親カテゴリーのみ抽出し、配列化
    @category_parent_array = Category.where(ancestry: nil)
  end

  # 以下全て、formatはjsonのみ
  # 親カテゴリーが選択された後に動くアクション
  def get_category_children
    #選択された親カテゴリーに紐付く子カテゴリーの配列を取得
    @category_children = Category.find(params[:parent_id]).children
  end

  # 子カテゴリーが選択された後に動くアクション
  def get_category_grandchildren
    #選択された子カテゴリーに紐付く孫カテゴリーの配列を取得
    @category_grandchildren = Category.find(params[:child_id]).children
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to item_path(@item.id)
    else
      flash[:notice] = '商品の出品に失敗しました。登録内容を確認してください。'
      redirect_to new_item_path
    end 
  end

  def edit
    unless current_user.id == @item.user_id
      redirect_to root_path
    end
  end

  def update
    if @item.update(item_update_params)
      redirect_to item_path(@item.id)
    else
      flash[:notice] = '商品情報の更新に失敗しました。登録内容を確認してください。'
      @item = Item.find(params[:id])
      render :edit
    end
  end

  def destroy
    if @item.destroy
      redirect_to root_path
    else
      render :edit
    end
  end

  def purchase_confirm
    card = get_my_payjp_token
    if card.present?
      Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
      customer = Payjp::Customer.retrieve(card.customer_id)
      @card = customer.cards.retrieve(card.card_id)
    end
  end

  def purchase
    begin
      card = get_my_payjp_token
      Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
      Payjp::Charge.create(
        amount: @item.price,
        customer: card.customer_id,
        currency: 'jpy',
      )
    rescue StandardError => e
      flash[:notice] = '申し訳ありません。商品の購入でエラーが発生しました。カスタマーサービスまでお問い合わせください。'
      redirect_to confirm_item_path(@item.id)
    end

    if @item.update_attribute(:status, 0)
      render "purchase_completed"
    else
      redirect_to confirm_item_path(@item.id)
    end
end

  private
  def item_params
    params.require(:item).permit(
      :name, 
      :price, 
      :description, 
      :size_id, 
      :category_id, 
      :brand, 
      :condition_id, 
      :shipping_fee_id, 
      :handling_time_id, 
      :prefecture_id, 
      :status, 
      images_attributes: [:image]
    ).merge(user_id: current_user.id)
  end

  def item_update_params
    params.require(:item).permit(
      :name, 
      :price, 
      :description, 
      :size_id, 
      :category_id, 
      :brand, 
      :condition_id, 
      :shipping_fee_id, 
      :handling_time_id, 
      :prefecture_id, 
      :status, 
      images_attributes: [:image, :_destroy, :id]
    ).merge(user_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def move_to_index
    unless user_signed_in?
      redirect_to action: :index
    end
  end

  def get_my_payjp_token
    CreditCard.find_by(user_id: current_user.id)
  end

  def get_category_parents
    @category_parent_array = Category.where(ancestry: nil)
  end
end
