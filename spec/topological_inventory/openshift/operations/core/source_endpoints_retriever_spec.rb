require "topological_inventory/openshift/operations/core/source_endpoints_retriever"

module TopologicalInventory
  module Openshift
    module Operations
      module Core
        RSpec.describe SourceEndpointsRetriever do
          let(:subject) { described_class.new(123) }

          describe "#process" do
            let(:url) { "http://localhost:3000/r/insights/platform/topological-inventory/v0.1/sources/123/endpoints" }
            let(:headers) { {"Content-Type" => "application/json"} }
            let(:dummy_response) { {"data" => [{"host" => "dummy"}]} }

            before do
              stub_request(:get, url).with(:headers => headers).to_return(:body => dummy_response.to_json, :headers => headers)
            end

            around do |e|
              url = ENV["TOPOLOGICAL_INVENTORY_URL"]
              ENV["TOPOLOGICAL_INVENTORY_URL"] = "http://localhost:3000"
              uri = URI.parse(ENV["TOPOLOGICAL_INVENTORY_URL"])
              TopologicalInventoryApiClient.configure do |config|
                config.scheme = uri.scheme || "http"
                config.host = "#{uri.host}:#{uri.port}"
              end

              e.run

              ENV["TOPOLOGICAL_INVENTORY_URL"] = url
            end

            it "returns the list of endpoints based on the source" do
              endpoints = subject.process
              expect(endpoints.class).to eq(TopologicalInventoryApiClient::EndpointsCollection)
              expect(endpoints.data.first.class).to eq(TopologicalInventoryApiClient::Endpoint)
              expect(endpoints.data.first.host).to eq("dummy")
            end
          end
        end
      end
    end
  end
end
