# require 'rails_helper'

# RSpec.describe CardsController, type: :controller do
# # describe '商品購入', type: :controller do
#   let(:user) {create(:user)}
#   let(:card) {create(:card, user_id: user.id)}
#   describe 'aaa' do
#     context 'bbbb' do
#       it 'hogehoge' do
        
#         allow(Payjp::Customer).to receive(:create).and_return(PayjpMock.prepare_customer_information)
#         item = create(:item)
#         binding.pry
#         get "transaction/buy/#{item.id}", params: {id: item.id, card: card}
#         expect(response).to render_template :show
#       end
#     end
#   end
# end
# # end
