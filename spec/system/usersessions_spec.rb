require 'rails_helper'

RSpec.describe "Usersessions", type: :system do
  describe 'ログイン前' do
    context 'フォームの入力値が正常' do
      it 'ログイン処理が成功する' do
        user = create(:user)
        login_as(user)
        expect(page).to have_content "Login successful"
      end
    end
  end
end
