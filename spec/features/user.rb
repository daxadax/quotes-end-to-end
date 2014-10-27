require 'spec_helper'

class FeaturesUser < FeatureTest

  it "registers new users" do
    user = create_test_user

    assert_equal '1',             user.uid
    assert_equal 'test_user',     user.nickname
    assert_nil                    user.email
    assert_empty                  user.favorites
    assert_empty                  user.added
    assert_equal false,           user.terms_accepted

    create_more_users
    assert_equal 5,               get_users.users.count

    user = get_user(user.uid)

    assert_denied update_user(:uid      => user.uid,
                              :nickname => 'user_two')

    update_user(:uid      => user.uid,
                :nickname => 'new_user_one',
                :email    => 'user@mail.com')

    user = get_user(user.uid)

    assert_equal '1',             user.uid
    assert_equal 'new_user_one',  user.nickname
    assert_equal 'user@mail.com', user.email
    assert_empty                  user.favorites
    assert_empty                  user.added
    assert_equal true,            user.terms_accepted

    assert_equal user.uid, authenticate_test_user
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
        :author   => "Author for Quote ##{i+1}",
        :title    => "Title for Quote ##{i+1}",
        :content  => "Content for Quote ##{i+1}"
      }
    )
  end

  def create_more_users
    create_test_user(:nickname => 'user_two',   :password => 'weak_sauce')
    create_test_user(:nickname => 'user_three', :password => 'jesus_bros')
    create_test_user(:nickname => 'user_four',  :password => '420_4_ever')
    create_test_user(:nickname => 'user_five',  :password => 'lewinsky_m')
  end

end
