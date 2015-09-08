require 'sinatra'
require 'json'
require 'twilio-ruby'

TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID']
TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
TWILIO_CLIENT = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)

put '/:template/:from/:to' do
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
    TWILIO_CLIENT.calls.create(
      from: "+{from}",
      to:   "+{to}",
      url:  "http://t2dtwilio.herokuapp.com/twiml?s=#{s}"
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
  puts response.text
end