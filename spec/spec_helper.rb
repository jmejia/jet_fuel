current_path = File.expand_path('app')
$LOAD_PATH.push(current_path) unless $LOAD_PATH.include?($LOAD_PATH)
require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
end
require 'jet_fuel'
require 'rack/test'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

end
