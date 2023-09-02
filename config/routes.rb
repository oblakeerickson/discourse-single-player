# frozen_string_literal: true

SinglePlayerModule::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::SinglePlayerModule::Engine, at: "single-player" }
