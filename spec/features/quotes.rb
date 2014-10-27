require 'spec_helper'

class FeaturesQuotes < FeatureTest

  it "successfully calls all use_cases from the quotes domain" do
    assert_equal 0, get_quotes.quotes.count

    create_quotes(5)

    assert_equal 5,                       get_quotes.quotes.count
    assert_equal "Title for Quote #1",    get_quote(1).quote.title
    assert_equal "Content for Quote #1",  get_quote(1).quote.content

    delete_quote(2)
    delete_quote(3)

    assert_equal 3,                       get_quotes.quotes.count
    assert_equal [1, 4, 5],               get_quotes.quotes.map(&:uid)

    assert_empty                          search_for('[test]').quotes

    update_quote(5, ['test', 'tags'])

    assert_equal 1,                       search_for('[test]').quotes.count
  end

  private

  def search_for(query)
    call_use_case(Quotes, :Search,
      :query => query
    )
  end

  def create_quotes(number_of_quotes)
    number_of_quotes.times do |i|
      call_use_case(Quotes, :CreateQuote,
        :quote => {
          :author   => "Author for Quote ##{i+1}",
          :title    => "Title for Quote ##{i+1}",
          :content  => "Content for Quote ##{i+1}"
        }
      )
    end
  end

  def update_quote(uid, tags)
    quote = get_quote(uid).quote

    call_use_case(Quotes, :UpdateQuote,
      :quote => {
        :uid       => uid,
        :author   => quote.author,
        :title    => quote.title,
        :content  => quote.content,
        :tags     => tags
      }
    )
  end


  def delete_quote(uid)
    call_use_case(Quotes, :DeleteQuote,
      :uid => uid
    )
  end

  def get_quotes
    call_use_case(Quotes, :GetQuotes)
  end

  def get_quote(uid)
    call_use_case(Quotes, :GetQuote,
      :uid => uid
    )
  end

end
