# frozen_string_literal: true

module ::SinglePlayerModule
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace SinglePlayerModule
    config.autoload_paths << File.join(config.root, "lib")
  end
end
