require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe 'ログイン前' do
    describe 'ユーザー新規登録' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          user = build(:user)
          expect {
            visit root_path
            click_link "SignUp"
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            fill_in "Password confirmation", with: user.password_confirmation
            click_button "SignUp"
            expect(page).to have_content "User was successfully created."
          }.to change(User, :count).by(1)
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          user = build(:user, email: "")
          expect {
            visit root_path
            click_link "SignUp"
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            fill_in "Password confirmation", with: user.password_confirmation
            click_button "SignUp"
            expect(page).to have_content "Email can't be blank"
          }.to change(User, :count).by(0)
        end
      end
      context '登録済みのメールアドレス' do
        it 'ユーザーの新規作成が失敗する' do
          # 無駄なコードが多い
          user = create(:user)
          duplicate_email_user = build(:user)
          expect {
            visit root_path
            click_link "SignUp"
            fill_in "Email", with: user.email
            fill_in "Password", with: duplicate_email_user.password
            fill_in "Password confirmation", with: duplicate_email_user.password_confirmation
            click_button "SignUp"
            expect(page).to have_content "Email has already been taken"
          }.to change(User, :count).by(0)
        end
      end
    end
    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          user = build(:user)
          visit users_path(user)
          expect(page).to have_content "Login required"
          expect(page).to have_current_path login_path
        end
      end
    end
  end
end
