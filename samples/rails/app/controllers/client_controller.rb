class ClientController < ApplicationController
  before_filter :oauth_authentication, :except => :logout  
  rescue_from   OAuth::Unauthorized, :with => :show_api_error
  verify        :method => :post, :only => [:readings, :top_up]

  API_SITE = "https://suppliertest.youdo.co.nz"
  API_KEY = "api key goes here"
  API_SECRET = "api secret goes here"


  def index
    @customer = api_call(:get, "customer").result
    @property_data = @customer.properties.each_with_object({}) do |property, o|
      o[property.icp_number] = {
        :products => api_call(:get, "products", :icp_number => property.icp_number).result,
        :readings => api_call(:get, "meter_readings", :icp_number => property.icp_number, :start_date => 90.days.ago.to_date, :end_date => Date.today).result,
        :top_up   => property.unit_balance < 0 && api_call(:get, "top_up", :icp_number => property.icp_number).result}
    end
  end
  
  def readings
    result = api_call(:post, "meter_readings", :icp_number => params[:id], :readings => params[:readings]).result
    flash[:notice] = result.result == "success" ? "Successfully updated." : "Error updating: #{result.message}"
    redirect_to :action => 'index'
  end
  
  def top_up
    result = api_call(:post, "top_up", :icp_number => params[:id], :offer_key => params[:key]).result
    flash[:notice] = result.result == "success" ? "Successfully purchased." : "Error purchasing: #{result.message}"
    redirect_to :action => 'index'
  end
  
  def logout
    session[:request_token] = session[:access_token] = nil
    redirect_to :action => 'index'
  end
  
  protected
  def oauth_authentication
    @consumer = OAuth::Consumer.new(API_KEY, API_SECRET, {
        :site               => API_SITE,
        :scheme             => :header,
        :http_method        => :get,
        :request_token_path => "/external_api/oauth/request_token",
        :access_token_path  => "/external_api/oauth/access_token",
        :authorize_path     => "/external_api/oauth/authorize"})

    if access_token.nil?
      if request_token.nil? || params[:oauth_token].nil?
        token = @consumer.get_request_token(:oauth_callback => "#{request.protocol}#{request.host_with_port}#{request.request_uri}")        
        session[:request_token] = [token.token, token.secret]
        redirect_to token.authorize_url
      else
        token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
        session[:access_token] = [token.token, token.secret]
      end
    end    
  end

  def request_token
    @request_token ||= session[:request_token] && OAuth::RequestToken.new(@consumer, *session[:request_token])
  end
  
  def access_token
    @access_token ||= session[:access_token] && OAuth::AccessToken.new(@consumer, *session[:access_token])
  end
  
  def api_call(http_method, call, opts = {})
    uri = "/external_api/v1/#{call}.js"
    query_string = opts.is_a?(Hash) ? opts.to_query : opts
    if !query_string.blank?
      # TODO : for some reason, OAuth on the server end only likes validating params passed in from the URL.
      if true # http_method == :get
        uri << "?#{query_string}"
      else
        data = query_string
      end
    end
    response = access_token.request(http_method, uri, data)
    raise OAuth::Unauthorized, response if response.code.to_i != 200
    RecursiveStruct.new ActiveSupport::JSON.decode(response.body)
  end
  
  def show_api_error(e)
    render :text => "API server responds #{e.message}: #{e.request.body}", :status => e.request.code.to_i
  end
end
