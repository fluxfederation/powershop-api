# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_powershop-client_session',
  :secret      => '41c4e6dc8415ad57784c0c805b2af39ca10920b0239d92d565e65eb096f0ece43ab73b64bb1598c13ea344489b7a1e2d14305bfa331a8c3874f81adc4a506996'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
