require 'spec_helper'

class FeaturesUser < FeatureTest

  it "does user stuff" do
    user_uid = create_test_user(:auth_key => 'auth_key').uid
    user = get_user(user_uid).user

    assert_equal 1, user.uid
    assert_equal 'nickname', user.nickname
    assert_equal 'email', user.email
    assert_empty user.favorites
    assert_empty user.added_quotes
    assert_equal false, user.terms_accepted

    create_more_users
    assert_equal 5, get_users.users.count

    update = update_user( :uid => user_uid, :auth_key => 'wrong_auth_key')
    assert_equal :auth_failure, update.error
    assert_nil update.uid

    update = update_user(:uid => user_uid, :auth_key => 'auth_key')
    assert_nil update.error

    user = get_user(user_uid).user

    assert_equal 1, user.uid
    assert_equal 'updated nickname', user.nickname
    assert_equal 'updated email', user.email
    assert_empty user.favorites
    assert_empty user.added_quotes
    assert_equal false, user.terms_accepted

    assert_equal user_uid, authenticate_user(:auth_key => 'updated auth_key').uid

    create_quote_for_user user_uid
    user = get_user(user_uid).user

    assert_equal 1, user.uid
    assert_equal 'updated nickname', user.nickname
    assert_equal 'updated email', user.email
    assert_empty user.favorites
    assert_empty user.added_quotes
    assert_equal false, user.terms_accepted
  end

  def create_test_user(options = {})
    call_use_case(Users, :CreateUser,
      :user => {
        :nickname   => options[:nickname]   ||'nickname',
        :email      => options[:email]      ||'email',
        :auth_key   => options[:auth_key]   ||'auth_key'
      }
    )
  end

  def authenticate_test_user(options = {})
    call_use_case(Users, :AuthenticateUser,
      :nickname => options[:nickname] || 'test_user',
      :auth_key => options[:auth_key] || 'auth_key'
    )
  end

  def get_user(uid)
    call_use_case(Users, :GetUser,
      :uid => uid
    )
  end

  def create_quote_for_user(user_uid)
    call_use_case(Quotes, :CreateQuote,
      :added_by   => user_uid,
      :quote      => {
        :author   => "Author",
        :title    => "Title",
        :content  => "Content"
      }
    )
  end

  def create_more_users
    create_test_user(:nickname => 'user_two',   :auth_key => 'weak_sauce')
    create_test_user(:nickname => 'user_three', :auth_key => 'jesus_bros')
    create_test_user(:nickname => 'user_four',  :auth_key => '420_4_ever')
    create_test_user(:nickname => 'user_five',  :auth_key => 'lewinsky_m')
  end

end
