require 'test_helper'

module Elasticsearch
  module Test
    class BulkTest < ::Test::Unit::TestCase

      context "Bulk" do
        subject { FakeClient.new(nil) }

        should "post correct payload to the endpoint" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_bulk', url
            assert_equal Hash.new, params
            assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), body
            {"index":{"_index":"myindexA","_type":"mytype","_id":"1"}}
            {"title":"Test"}
            {"update":{"_index":"myindexB","_type":"mytype","_id":"2"}}
            {"doc":{"title":"Update"}}
            {"delete":{"_index":"myindexC","_type":"mytypeC","_id":"3"}}
            PAYLOAD
            true
          end.returns(FakeResponse.new)

          subject.bulk :body => [
            { :index =>  { :_index => 'myindexA', :_type => 'mytype', :_id => '1', :data => { :title => 'Test' } } },
            { :update => { :_index => 'myindexB', :_type => 'mytype', :_id => '2', :data => { :doc => { :title => 'Update' } } } },
            { :delete => { :_index => 'myindexC', :_type => 'mytypeC', :_id => '3' } }
          ]
        end

        should "post payload to the correct endpoint" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal 'myindex/_bulk', url
            true
          end.returns(FakeResponse.new)

          subject.bulk :index => 'myindex', :body => []
        end

        should "post a string payload" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal "foo\nbar", body
            true
          end.returns(FakeResponse.new)

          subject.bulk :body => "foo\nbar"
        end

        should "encode URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_bulk', url
            assert_equal({:refresh => true}, params)
            true
          end.returns(FakeResponse.new)

          subject.bulk :refresh => true, :body => []
        end

      end

    end
  end
end