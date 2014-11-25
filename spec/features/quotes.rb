require 'spec_helper'

class FeaturesQuotes < FeatureTest

  it "successfully calls all use_cases from the quotes domain" do
    assert_equal 0, get_quotes.quotes.count

    publication_uid = create_publication.uid

    create_quotes_for_publication publication_uid
    assert_equal 5, get_quotes.quotes.count

    quote = get_quote(1).quote

    assert_equal 23, quote.added_by
    assert_equal "Content for Quote #1",  quote.content
    assert_equal publication_uid, quote.publication_uid
    assert_equal 'author', quote.author
    assert_equal 'title', quote.title
    assert_equal 'publisher', quote.publisher
    assert_equal 1999, quote.year

    delete_quote(2)
    delete_quote(3)

    assert_equal 3, get_quotes.quotes.count
    assert_equal [5, 4, 1], get_quotes.quotes.map(&:uid)

    assert_empty search_for('[test]').quotes

    update_quote(5, ['test', 'tags'])

    search_result = search_for('[test]').quotes

    assert_equal 1, search_result.size
    assert_includes search_result.first.tags, 'test'

    search_result = search_for('author')

    assert_equal 'author', search_result.query
    assert_empty search_result.tags
    assert_equal 3, search_result.quotes.size
  end

  private

  def search_for(query)
    call_use_case(:search,
      :query => query
    )
  end

  def create_publication
    call_use_case :create_publication,
      :publication => {
        :author => 'author',
        :title => 'title',
        :publisher => 'publisher',
        :year => 1999
      }
  end

  def create_quotes_for_publication(publication_uid)
    5.times do |i|
      call_use_case(:create_quote,
        :user_uid => 23,
        :quote => {
          :content => "Content for Quote ##{i+1}",
          :publication_uid => publication_uid
        }
      )
    end
  end

  def update_quote(uid, tags)
    quote = get_quote(uid).quote

    call_use_case :update_quote,
      :user_uid => quote.added_by,
      :quote => {
        :uid => uid,
        :added_by => quote.added_by,
        :content => quote.content,
        :publication_uid => quote.publication_uid,
        :tags => tags
      }
  end

  def delete_quote(uid)
    call_use_case(:delete_quote,
      :uid => uid
    )
  end

  def get_quotes
    call_use_case(:get_quotes)
  end

  def get_quote(uid)
    call_use_case(:get_quote,
      :uid => uid
    )
  end

end
