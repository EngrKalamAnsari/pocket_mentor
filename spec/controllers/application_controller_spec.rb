require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include Devise::Test::ControllerHelpers

  controller do
    def index
      render plain: 'ok'
    end

    def access
      raise CanCan::AccessDenied, 'nope'
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end

    def standard
      raise StandardError, 'boom'
    end
  end

  describe 'route_not_found' do
    it 'redirects to root with alert' do
      routes.draw { get 'route_not_found' => 'anonymous#route_not_found' }
      allow(controller).to receive(:authenticate_user!).and_return(true)
      get :route_not_found
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('The requested page was not found.')
    end
  end

  describe 'invalid auth token handler' do
    it 'resets session and redirects with alert' do
      allow(controller).to receive(:reset_session).and_return(true)
      controller.instance_variable_set(:@_response, response)
      controller.send(:handle_invalid_auth_token)
      expect(controller).to have_received(:reset_session)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Your session has expired. Please try again.')
    end
  end

  describe 'rescue handlers' do
    before do
      routes.draw do
        get 'index' => 'anonymous#index'
        get 'access' => 'anonymous#access'
        get 'not_found' => 'anonymous#not_found'
        get 'standard' => 'anonymous#standard'
      end
      allow(controller).to receive(:authenticate_user!).and_return(true)
    end

    it 'allows normal action' do
      get :index
      expect(response.body).to eq('ok')
    end

    it 'handles access denied' do
      get :access
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('nope')
    end

    it 'handles record not found' do
      get :not_found
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('The requested resource was not found.')
    end

    it 'handles standard error' do
      allow(Rails.logger).to receive(:error)
      exception = StandardError.new('boom')
      exception.set_backtrace(['spec backtrace'])
      controller.instance_variable_set(:@_response, response)
      controller.send(:handle_standard_error, exception)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('An unexpected error occurred. Please try again later.')
    end
  end
end
