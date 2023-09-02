# frozen_string_literal: true

# name: discourse-single-player
# about: All new users will only have access to their own private category and groupx
# version: 0.0.1
# authors: Blake Erickson
# url: https://github.com/oblakeerickson/discourse-single-player
# required_version: 2.7.0

enabled_site_setting :single_player_enabled

module ::MyPluginModule
  PLUGIN_NAME = "discourse-single-player"
end

require_relative "lib/single_player_module/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
