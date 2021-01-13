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
          expect(current_path).to eq login_path
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

    describe 'ユーザー編集' do
      context 'ログインしていない状態' do
        it 'ユーザー編集ページに遷移できないこと' do
          user = create(:user)
          visit edit_user_path(user)
          expect(page).to have_content "Login required"
          expect(current_path).to eq login_path
        end
      end
    end

    describe 'ログイン後' do
      describe 'ユーザー編集' do
        context 'フォームの入力値が正常' do
          it 'ユーザーの編集が成功する' do
            user = create(:user)
            login_as user
            click_link "Mypage"
            click_link "Edit"
            fill_in "Email", with: 'test@example.com'
            click_button "Update"
            expect(page).to have_content "User was successfully updated."
            expect(current_path).to eq user_path(user)
          end
        end
        context 'メールアドレスが未入力' do
          it 'ユーザーの編集が失敗する' do
            user = create(:user)
            login_as user
            click_link "Mypage"
            click_link "Edit"
            fill_in "Email", with: ""
            click_button "Update"
            expect(page).to have_content "Email can't be blank"
            expect(current_path).to eq user_path(user)
          end
        end
        context '登録済みのメールアドレスを使用' do
          it 'ユーザーの編集が失敗する' do
            user = create(:user)
            duplicate_email_user = create(:user)
            login_as duplicate_email_user
            click_link "Mypage"
            click_link "Edit"
            fill_in "Email", with: user.email
            click_button "Update"
            expect(page).to have_content "Email has already been taken"
          end
        end
        context '他のユーザーの編集ページにアクセス' do
          it '編集ページへのアクセスが失敗する' do
            user = create(:user)
            other_user = create(:user)
            login_as user
            visit edit_user_path(other_user)
            expect(page).to have_content "Forbidden access."
            expect(current_path).to eq user_path(user)
          end
        end
      end
      describe 'マイページ' do
        context 'タスクを作成' do
          it '新規作成したタスクが表示される' do
            user = create(:user)
            login_as user
            task1 = create(:task, user: user)
            task2 = create(:task, user: user)
            visit user_path(user)
            expect(page).to have_content task1.title
            expect(page).to have_content task2.title
          end
        end
      end
    end
  end
end
