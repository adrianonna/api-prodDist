require "rails_helper"

RSpec.describe RegistriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/registries").to route_to("registries#index")
    end

    it "routes to #show" do
      expect(get: "/registries/1").to route_to("registries#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/registries").to route_to("registries#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/registries/1").to route_to("registries#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/registries/1").to route_to("registries#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/registries/1").to route_to("registries#destroy", id: "1")
    end
  end
end
