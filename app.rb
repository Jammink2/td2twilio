require 'sinatra'
require 'json'
require 'twilio-ruby'
require 'tilt/erb'

put '/:template/:from/:to' do
  twilio_client = Twilio::REST::Client.new(
    ENV['TWILIO_ACCOUNT_SID'],
    ENV['TWILIO_AUTH_TOKEN'])
  template = params[:template]
  from = params[:from]

  to = params[:to]
  begin
    payload = JSON.parse(request.body.read)  
    # payload is formatted like
    # { "column_names": ["foo", "bar"],
    #   "data": [[1,2,3], ['a', 'b', 'c']],
    #   "column_type": ["long", "string"]
    # }
    # See http://docs.treasuredata.com/articles/result-into-web
    @td = Hash[payload['column_names'].zip(payload['data'].transpose)]
    s = erb template.to_sym, :layout => false
    twilio_client.calls.create(
      from: "+{from}",
      to:   "+{to}",
      url:  "http://td2twilio.herokuapp.com/twiml?s=#{s}"
    )
  rescue => e
    STDERR.puts e.backtrace
  end
end

get '/twiml' do
  s = params[:s]
  response = Twilio::TwiML::Response.new do |r|
    r.Say s
  end
  response.text
end
