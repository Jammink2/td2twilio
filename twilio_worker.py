from twilio.rest import TwilioRestClient
import os
import urllib2
import iron_worker as iron
import json

account = os.environ["TWILIO_ACCOUNT_SID"]
token = os.environ["TWILIO_AUTH_TOKEN"]
payload = iron.IronWorker.payload()

client = TwilioRestClient(account, token)
to_num = payload["to"]
from_num = payload["from"]
message = payload["message"]
quoted_message = urllib2.quote(message)
call = client.calls.create(to=to_num,
                           from_=from_num,
                           url="http://td2twilio.herokuapp.com/twiml?s=%s"%quoted_message)