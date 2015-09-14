require 'sinatra'
require 'json'
require 'twilio-ruby'
require 'iron_worker_ng'

put '/:template/:to' do
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
    worker_params = {
      from: "+#{ENV['TWILIO_NUMBER']}",
      to:   "+#{to}",
      message: s
    }
    iron_client = IronWorkerNG::Client.new
    iron_client.tasks.create('twilio', worker_params)
  rescue => e
    STDERR.puts e.backtrace
  end
end

post '/twiml' do
  s = params[:s]
  response = Twilio::TwiML::Response.new do |r|
    r.Say s
  end
  response.text
end
