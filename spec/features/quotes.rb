require 'spec_helper'

class FeaturesQuotes < FeatureTest

  it "successfully calls all use_cases from the quotes domain" do
    test_CRUD_functions
    test_search_function

    #test_kindle_imports_with_autotag
    publication = create_publication(
      :author => "Ernest Becker",
      :title => "The Denial of Death"
    )

    quote = create_quote(publication.uid, "Example quote which has been edited")
    update_quote quote.uid, :tags => ['example', 'quote']

    file = File.read('./spec/support/kindle_clippings.txt')
    result_of_import = import_from_kindle(file)
    assert_nil result_of_import.error

    #ensure_existing_publication_is_used
    expected_publication = get_publication(publication.uid).publication
    last_quote_imported = get_quotes.quotes.first

    assert_equal last_quote_imported.publication_uid, expected_publication.uid
    assert_equal last_quote_imported.author, expected_publication.author
    assert_equal last_quote_imported.title, expected_publication.title
    assert_equal last_quote_imported.publisher, expected_publication.publisher
    assert_equal last_quote_imported.year, expected_publication.year

    #ensure_possible_duplicates
    refute_empty result_of_import.possible_duplicates
    assert_equal 1, result_of_import.possible_duplicates.size

    #ensure_added_quotes_are_returned
    refute_empty result_of_import.added_quotes
    assert_equal 2, result_of_import.added_quotes.size

    #ensure_appropriate_tags
    quotes_that_should_have_tags = get_quotes.quotes.select do |quote|
      quote.content =~ /example/i
    end

    assert_equal 2, quotes_that_should_have_tags.size
    quotes_that_should_have_tags.each do |quote|
      assert_equal ['example', 'quote'], quote.tags
    end
  end

  private

  def test_CRUD_functions
    assert_equal 0, all_quotes.count

    publication_uid = create_publication.uid

    create_quotes_for_publication publication_uid
    assert_equal 5, all_quotes.count

    quote = get_quote(1).quote

    assert_equal 23, quote.added_by
    assert_equal "Content for Quote #1",  quote.content
    assert_equal publication_uid, quote.publication_uid
    assert_equal 'author', quote.author
    assert_equal 'title', quote.title
    assert_equal 'publisher', quote.publisher
    assert_equal 1999, quote.year

    update_publication(23, publication_uid, :author => 'updated author')

    quote = get_quote(1).quote

    assert_equal 23, quote.added_by
    assert_equal "Content for Quote #1",  quote.content
    assert_equal publication_uid, quote.publication_uid
    assert_equal 'updated author', quote.author

    delete_quote(2)
    delete_quote(3)

    assert_equal 3, all_quotes.count
    assert_equal [5, 4, 1], all_quotes.map(&:uid)

    wrong_user_uid = 22
    result = delete_quote(5, wrong_user_uid)

    assert_equal :invalid_user, result.error
    assert_equal 3, all_quotes.count
  end

  def test_search_function
    assert_empty search_for('[test]').quotes

    update_quote 5, :tags => ['test', 'tags']

    search_result = search_for('[test]').quotes

    assert_equal 1, search_result.size
    assert_includes search_result.first.tags, 'test'

    search_result = search_for('author')

    assert_equal 'author', search_result.query
    assert_empty search_result.tags
    assert_equal 3, search_result.quotes.size
  end

  def all_quotes
    get_quotes.quotes
  end

  def search_for(query)
    call_use_case(:search,
      :query => query
    )
  end

  def import_from_kindle(file)
    call_use_case :import_from_kindle,
      :user_uid => 23,
      :file => file
  end

  def create_publication(options = {})
    call_use_case :create_publication,
      :user_uid => 23,
      :publication => {
        :author => options[:author] || 'author',
        :title => options[:title] ||'title',
        :publisher => 'publisher',
        :year => 1999
      }
  end

  def create_quote(publication_uid, content)
    call_use_case(:create_quote,
      :user_uid => 23,
      :quote => {
        :content => content,
        :publication_uid => publication_uid
      }
    )
  end

  def create_quotes_for_publication(publication_uid)
    5.times do |i|
      create_quote(publication_uid, "Content for Quote ##{i+1}")
    end
  end

  def update_quote(uid, updates, user_uid = 23)
    quote = get_quote(uid).quote

    call_use_case :update_quote,
      :user_uid => user_uid,
      :uid => uid,
      :updates => updates
  end

  def update_publication(user_uid , uid, updates = {})
    call_use_case :update_publication,
      :user_uid => user_uid,
      :uid => uid,
      :updates => updates
  end

  def delete_quote(uid, user_uid = 23)
    call_use_case :delete_quote,
      :user_uid => user_uid,
      :uid => uid
  end

  def get_quotes
    call_use_case :get_quotes
  end

  def get_quote(uid)
    call_use_case :get_quote,
      :uid => uid
  end

  def get_publication(uid)
    call_use_case :get_publication,
      :uid => uid
  end

end
