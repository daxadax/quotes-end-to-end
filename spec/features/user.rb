require 'spec_helper'

class FeaturesUser < FeatureTest

  it "successfully calls all use_cases from the users domain" do
    user_uid = create_test_user(:auth_key => 'auth_key').uid

    run_CRUD_tests(user_uid)
    run_authentication_tests(user_uid)

    publication = create_publication_for_user user_uid
    created_quote = create_quote_for_user user_uid, publication.uid

    assert_equal 1, user.uid
    assert_equal 'updated nickname', user.nickname
    assert_equal 'updated email', user.email
    assert_empty user.favorites
    assert_includes user.added_quotes, created_quote.uid
    assert_includes user.added_publications, publication.uid
    assert_equal false, user.terms_accepted

    delete_quote created_quote.uid
    assert_empty user.added_quotes

    delete_publication publication.uid
    assert_empty user.added_publications

    toggle_favorite_status_of_quote_for_user(2, created_quote.uid)

    # this should fail.  how can a user favorite a quote which does not exist?

    user_with_favorite_quote = get_user(2).user
    assert_includes user_with_favorite_quote.favorites, created_quote.uid
    refute_includes user.favorites, created_quote.uid

    toggle_favorite_status_of_quote_for_user(2, created_quote.uid)

    user_with_favorite_quote = get_user(2).user
    refute_includes user_with_favorite_quote.favorites, created_quote.uid
    refute_includes user.favorites, created_quote.uid

    ## ## Can quotes be deleted?  How to handle this?  ## ##
    # publication = create_publication_for_user user_uid
    # quote_one = create_quote_for_user user_uid, publication.uid
    # quote_two = create_quote_for_user user_uid, publication.uid
    #
    # toggle_favorite_status_of_quote_for_user(2, quote_one.uid)
    # toggle_favorite_status_of_quote_for_user(3, quote_two.uid)
    #
    # user_two = get_user(2).user
    # user_three = get_user(3).user
    #
    # assert_includes user_two.favorites, quote_one.uid
    # assert_includes user_three.favorites, quote_two.uid
    #
    # delete_quote quote_one.uid
    # assert_empty user_two.favorites
    # assert_includes user_three.favorites, quote_two.uid
    #
    # delete_publication publication.uid
    # assert_empty user_three.favorites
  end

  private

  def run_CRUD_tests(user_uid)
    assert_equal 1, user.uid
    assert_equal 'nickname', user.nickname
    assert_equal 'email', user.email
    assert_empty user.favorites
    assert_empty user.added_quotes
    assert_equal false, user.terms_accepted

    duplicate_registration = create_test_user(:auth_key => 'bootybuttshake')

    assert_equal :duplicate_user, duplicate_registration.error
    assert_nil duplicate_registration.uid

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

    assert_equal 1, user.uid
    assert_equal 'updated nickname', user.nickname
    assert_equal 'updated email', user.email
    assert_empty user.favorites
    assert_empty user.added_quotes
    assert_equal false, user.terms_accepted
    assert_nil user.last_login_time
    assert_nil user.last_login_address
    assert_equal 0, user.login_count
  end

  def run_authentication_tests(user_uid)
    authenticate =  authenticate_user(:auth_key => 'incorrect auth_key')
    assert_equal :auth_failure, authenticate.error
    assert_nil authenticate.uid

    assert_nil user.last_login_time
    assert_nil user.last_login_address
    assert_equal 0, user.login_count

    authenticate =  authenticate_user :nickname => 'unknown user',
                                                         :auth_key => 'some key'
    assert_equal :user_not_found, authenticate.error
    assert_nil authenticate.uid

    authenticate =  authenticate_user(:auth_key => 'updated auth_key')
    assert_nil authenticate.error
    assert_equal user_uid, authenticate.uid

    refute_nil user.last_login_time
    assert_equal  '23.0.2.5', user.last_login_address
    assert_equal 1, user.login_count
  end

  def user
    get_user(1).user
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
      :auth_key => args[:auth_key] || raise('You must call with an :auth_key'),
      :updates => args[:updates] || updates_for_user
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
    call_use_case :authenticate_user,
      :nickname => args[:nickname] || 'updated nickname',
      :auth_key => args[:auth_key] || raise('You must call with an :auth_key'),
      :login_data => {
        :ip_address => args[:ip] || '23.0.2.5'
      }
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

  def toggle_favorite_status_of_quote_for_user(uid, quote_uid)
    call_use_case(:toggle_favorite,
      :uid => uid,
      :quote_uid => quote_uid
    )
  end

  def create_quote_for_user(user_uid, publication_uid)
    call_use_case(:create_quote,
      :user_uid => user_uid,
      :quote => {
        :content => "Content for Quote",
        :publication_uid => publication_uid
      }
    )
  end

  def delete_quote(uid)
    call_use_case :delete_quote,
      :user_uid => user.uid,
      :uid => uid
  end

  def delete_publication(uid)
    call_use_case :delete_publication,
      :user_uid => user.uid,
      :uid => uid
  end

  def create_publication_for_user(user_uid)
    call_use_case :create_publication,
      :user_uid => user_uid,
      :publication => {
        :author => 'author',
        :title => 'title',
        :publisher => 'publisher',
        :year => 1999
      }
  end

  def create_more_users
    create_test_user(:nickname => 'user_two',   :auth_key => 'weak_sauce')
    create_test_user(:nickname => 'user_three', :auth_key => 'jesus_bros')
    create_test_user(:nickname => 'user_four',  :auth_key => '420_4_ever')
    create_test_user(:nickname => 'user_five',  :auth_key => 'lewinsky_m')
  end

end
