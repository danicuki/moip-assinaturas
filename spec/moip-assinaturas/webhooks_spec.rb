# coding: utf-8
require 'spec_helper'
require 'json'

describe Moip::Assinaturas::Webhooks do

  let!(:json) do

    {
      'event' => 'model.event',
      'date' => '28/12/2012 15:38:46',
      'env' => 'generic_env',
      'resource' => {
        'test' => 'test generic resource'
      }
    }
  end

  describe '.listen(request, &block)' do
    let!(:request) { {} }
    let!(:block) { lambda { |hook| } }
    let!(:hook) { Moip::Assinaturas::Webhooks.build(json) }

    before(:each) do
      request.stub_chain(:body) { {} }
      JSON.stub(:load).with({}) { json }
      Moip::Assinaturas::Webhooks.stub(:build) { hook }
    end

    it 'should call build' do
      Moip::Assinaturas::Webhooks.should_receive(:build).with(json)
      Moip::Assinaturas::Webhooks.listen(request, &block)
    end

    it 'should yield block' do
      Moip::Assinaturas::Webhooks.should_receive(:listen).and_yield(block)
      Moip::Assinaturas::Webhooks.listen(request, &block)
    end

    it 'should call run' do
      hook.should_receive(:run).once
      Moip::Assinaturas::Webhooks.listen(request, &block)
    end
  end

  describe '.build(json)' do
    subject(:hook) { Moip::Assinaturas::Webhooks.build(json) }

    its(:model) { should eq('model') }
    its(:event) { should eq('event') }
    its(:events) { should eq({}) }

    its(:date) { should eq('28/12/2012 15:38:46') }

    its(:env) { should eq('generic_env') }
    its(:resource) { should eq({ 'test' => 'test generic resource' }) }
  end

  describe '#on(model, event, &block)' do
    let!(:model) { 'model' }
    let!(:event) { 'event' }
    let!(:block) { lambda { } }

    subject(:hook) { Moip::Assinaturas::Webhooks.build(json) }

    it "should adding this block to events" do
      hook.on(model, event, &block)
      hook.events[model][event].should eq([block])
    end
  end

  describe '#run' do
    let!(:model) { 'model' }
    let!(:event) { 'event' }
    let!(:block) { lambda { } }

    subject(:hook) { Moip::Assinaturas::Webhooks.build(json) }

    it 'should call block once' do
      hook.on(model, event, &block)

      block.should_receive(:call).once

      hook.run
    end
  end
end