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
    assert_equal [1, 4, 5],               get_quotes.quotes.map(&:id)

    assert_empty                          search_for('[test]').quotes

    update_quote(5, ['test', 'tags'])

    assert_equal 1,                       search_for('[test]').quotes.count
  end

  private

  def search_for(query)
    call_use_case(:Quotes, :Search,
      :query => query
    )
  end

  def create_quotes(number_of_quotes)
    number_of_quotes.times do |i|
      call_use_case(:Quotes, :CreateQuote,
        :quote => {
          :author   => "Author for Quote ##{i+1}",
          :title    => "Title for Quote ##{i+1}",
          :content  => "Content for Quote ##{i+1}"
        }
      )
    end
  end

  def update_quote(id, tags)
    quote = get_quote(id).quote

    call_use_case(:Quotes, :UpdateQuote,
      :quote => {
        :id       => id,
        :author   => quote.author,
        :title    => quote.title,
        :content  => quote.content,
        :tags     => tags
      }
    )
  end


  def delete_quote(id)
    call_use_case(:Quotes, :DeleteQuote,
      :id => id
    )
  end

  def get_quotes
    call_use_case(:Quotes, :GetQuotes)
  end

  def get_quote(id)
    call_use_case(:Quotes, :GetQuote,
      :id => id
    )
  end

end
