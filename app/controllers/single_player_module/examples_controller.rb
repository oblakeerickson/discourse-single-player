# frozen_string_literal: true

module ::SinglePlayerModule
  class ExamplesController < ::ApplicationController
    requires_plugin SINGLE_PLAYER

    def index
      render json: { hello: "world" }
    end
  end
end
