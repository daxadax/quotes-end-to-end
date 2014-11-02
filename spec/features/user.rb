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

    delete_user_with_uid(4)
    assert_equal 4, get_users.users.count
    refute_includes get_users.users.map(&:uid), 4

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

    created_quote = create_quote_for_user user_uid
    user = get_user(user_uid).user

    assert_equal 1, user.uid
    assert_equal 'updated nickname', user.nickname
    assert_equal 'updated email', user.email
    assert_empty user.favorites
    assert_includes user.added_quotes, created_quote.uid
    assert_equal false, user.terms_accepted
  end

  def create_test_user(args = {})
    call_use_case(:create_user,
      :nickname => args[:nickname] || 'nickname',
      :email => args[:email] || 'email',
      :auth_key => args[:auth_key] || raise('You must call with an :auth_key')
    )
  end

  def update_user(args)
    call_use_case(:update_user,
      :uid => args[:uid] || raise('You must call with a :uid'),
      :updates => args[:updates] || updates_for_user,
      :auth_key => args[:auth_key] || raise('You must call with an :auth_key')
    )
  end

  def updates_for_user
    {
      :nickname => 'updated nickname',
      :email => 'updated email',
      :auth_key => 'updated auth_key'
    }
  end

  def authenticate_user(args = {})
    call_use_case(:authenticate_user,
      :nickname => args[:nickname] || 'updated nickname',
      :auth_key => args[:auth_key] || raise('You must call with an :auth_key')
    )
  end

  def get_user(uid)
    call_use_case(:get_user,
      :uid => uid
    )
  end

  def get_users
    call_use_case(:get_users)
  end

  def delete_user_with_uid(uid)
    call_use_case(:delete_user,
      :uid => uid
    )
  end

  def create_quote_for_user(user_uid)
    call_use_case(:create_quote,
      :user_uid   => user_uid,
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
