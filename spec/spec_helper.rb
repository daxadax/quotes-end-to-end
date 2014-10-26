require 'bundler'
Bundler.setup

require 'minitest/autorun'
require 'minitest/spec'

require 'quotes'
require 'users'

ENV['test'] = '1'
ENV['DATABASE_URL'] = 'mysql2://dax:dax@localhost/quotes_test'

# require all support files
Dir.glob('./spec/support/*.rb')  { |f| require f }

class FeatureTest < Minitest::Spec
  include Quotes

  before do
    clean_database
    run_migrations
  end

  def call_use_case(domain, use_case, input_hash = nil)
    use_case = eval("#{domain.to_s}::UseCases::#{use_case}.new(#{input_hash})")

    use_case.call
  end

  def assert_kind_of(expected, actual)
    actual = actual.class.name.split('::').last

    assert_equal expected.to_s, actual
  end

  def clean_database
    existing_tables       = database.tables
    tables_to_preserve    = [:schema_info, :schema_migrations]
    tables_to_be_emptied  = existing_tables - tables_to_preserve

    tables_to_be_emptied.each { |table| database << "TRUNCATE #{table}" }
  end

  def run_migrations
    Sequel.extension :migration

    Sequel::Migrator.apply(database, migration_directory)
  end

  def database
    @database ||= Sequel.connect(ENV.fetch("DATABASE_URL"))
  end

  def migration_directory
    "../persistence/migrations/"
  end


end