Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict
  #removed when upgrading

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false
  
  config.eager_load = false

  # Expands the lines which load the assets
  # config.assets.debug = true

  # Enable SQL debugging
  enable_sql_debugging = false # Set this to false if you don't want it
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true

    Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Subject", :association => :chapter
    Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Subject", :association => :section
    Bullet.add_whitelist :type => :unused_eager_loading, :class_name => "Subject", :association => :exercise
  end if enable_sql_debugging
  
  # Personalized logs 
  config.log_tags = [ lambda { |req| Time.now}, :remote_ip ] # Include IP address in the logs
  config.log_level = :debug # Set to :debug for more information (not sure it works with lograge)
  
  # lograge is a gem for 'better' logs
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    { params: event.payload[:params].except('controller', 'action', 'format', 'utf8') } # Include the form parameters
  end
  
  config.lograge.custom_payload do |controller|
    if controller.action_methods.include? "current_user"
      { current_user: controller.current_user.try(:id) } # Include the current_user.id
    end
  end

  # Do not eager load code on boot.
  config.eager_load = false

  # -- Stuff added when upgrading to rails 5.2.0 --
  # Show full error reports.
  #config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  #if Rails.root.join('tmp', 'caching-dev.txt').exist?
  #  config.action_controller.perform_caching = true

  #  config.cache_store = :memory_store
  #  config.public_file_server.headers = {
  #    'Cache-Control' => "public, max-age=#{2.days.to_i}"
  #  }
  #else
  #  config.action_controller.perform_caching = false

  #  config.cache_store = :null_store
  #end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  #config.action_mailer.raise_delivery_errors = false

  #config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  #config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  #config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  #config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  #config.assets.debug = true

  # Suppress logger output for asset requests.
  #config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  #config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
