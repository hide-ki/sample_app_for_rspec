require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }
  describe 'ログイン前' do
    describe 'ユーザー新規登録' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          expect {
            visit root_path
            click_link "SignUp"
            fill_in "Email", with: "test@example.com"
            fill_in "Password", with: "password"
            fill_in "Password confirmation", with: "password"
            click_button "SignUp"
            expect(page).to have_content "User was successfully created."
          }.to change(User, :count).by(1)
          expect(current_path).to eq login_path
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          expect {
            visit root_path
            click_link "SignUp"
            fill_in "Email", with: ""
            fill_in "Password", with: "password"
            fill_in "Password confirmation", with: "password"
            click_button "SignUp"
            expect(page).to have_content "Email can't be blank"
          }.to change(User, :count).by(0)
        end
      end
      context '登録済みのメールアドレス' do
        it 'ユーザーの新規作成が失敗する' do
          # 無駄なコードが多い
          duplicate_email_user = create(:user)
          expect {
            visit root_path
            click_link "SignUp"
            fill_in "Email", with: duplicate_email_user.email
            fill_in "Password", with: "password"
            fill_in "Password confirmation", with: "password"
            click_button "SignUp"
            expect(page).to have_content "Email has already been taken"
          }.to change(User, :count).by(0)
          expect(page).to have_field "Email", with: duplicate_email_user.email
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit users_path(user)
          expect(page).to have_content "Login required"
          expect(page).to have_current_path login_path
        end
      end
    end

    describe 'ユーザー編集' do
      context 'ログインしていない状態' do
        it 'ユーザー編集ページに遷移できないこと' do
          visit edit_user_path(user)
          expect(page).to have_content "Login required"
          expect(current_path).to eq login_path
        end
      end
    end

    describe 'ログイン後' do
      before { login_as user }
      describe 'ユーザー編集' do
        context 'フォームの入力値が正常' do
          it 'ユーザーの編集が成功する' do
            visit edit_user_path(user)
            fill_in "Email", with: 'test@example.com'
            click_button "Update"
            expect(page).to have_content "User was successfully updated."
            expect(current_path).to eq user_path(user)
          end
        end
        context 'メールアドレスが未入力' do
          it 'ユーザーの編集が失敗する' do
            visit edit_user_path(user)
            fill_in "Email", with: ""
            click_button "Update"
            expect(page).to have_content "Email can't be blank"
            expect(current_path).to eq user_path(user)
          end
        end
        context '登録済みのメールアドレスを使用' do
          it 'ユーザーの編集が失敗する' do
            duplicate_email_user = create(:user)
            visit edit_user_path(user)
            fill_in "Email", with: duplicate_email_user.email
            click_button "Update"
            expect(page).to have_content "Email has already been taken"
            expect(current_path).to eq user_path(user)
          end
        end
        context '他のユーザーの編集ページにアクセス' do
          it '編集ページへのアクセスが失敗する' do
            other_user = create(:user)
            visit edit_user_path(other_user)
            expect(page).to have_content "Forbidden access."
            expect(current_path).to eq user_path(user)
          end
        end
      end
      describe 'マイページ' do
        context 'タスクを作成' do
          it '新規作成したタスクが表示される' do
            task = create(:task, title: "test_title", user: user)
            visit user_path(user)
            expect(page).to have_content task.title
            expect(page).to have_content "You have 1 task."
            expect(page).to have_link "Show"
            expect(page).to have_link "Edit"
            expect(page).to have_link "Destroy"
          end
        end
      end
    end
  end
end
