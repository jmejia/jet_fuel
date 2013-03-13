current_path = File.expand_path('app')
$LOAD_PATH.push(current_path) unless $LOAD_PATH.include?($LOAD_PATH)
Bundler.require

require 'jet_fuel'
run Server
