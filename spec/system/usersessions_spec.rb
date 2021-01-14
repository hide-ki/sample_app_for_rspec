require 'rails_helper'

RSpec.describe "Usersessions", type: :system do
  let(:user) { create(:user) }
  describe 'ログイン前' do
    context 'フォームの入力値が正常' do
      it 'ログイン処理が成功する' do
        login_as user
        expect(page).to have_content "Login successful"
        expect(current_path).to eq root_path
      end
    end
    context 'フォームが未入力' do
      it 'ログイン処理が失敗する' do
        # ここの書き方は合っているのか？フォーム未入力の場合
        visit login_path
        fill_in "Email", with: ""
        fill_in "Password", with: ""
        click_button "Login"
        expect(page).to have_content "Login failed"
      end
    end
  end
  
  describe 'ログイン後' do
    context 'ログアウトボタンをクリック' do
      it 'ログアウト処理が成功する' do
        login_as user
        click_link "Logout"
        expect(page).to have_content "Logged out"
        expect(current_path).to eq root_path
      end
    end
  end
end
