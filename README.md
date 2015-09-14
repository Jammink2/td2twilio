# td2slack

Treasure Data to Twilio Bridge.

## What is this?

This is a little Sinatra app that bridges between Treasure Data's [HTTP PUT](http://docs.treasuredata.com/articles/result-into-web) result output functionality and Twilio.
So, it's like

```
 ---------------------   HTTP(S) PUT               -----------                      ------------         --------
| Treasure Data table |-------------------------->| td2twilio |------------------->| Iron Worker|------>| Twilio |
 ---------------------  abc.com/hello/16502212232  -----------   render hello.erb   ------------         --------
```

## How does it work?

- Set the env variable `TWILIO_NUMBER` to be a Twilio number that you want to call from.
- The path of the app corresponds to the ERB template under `/views`. So, if you specify the path `/daily_stats`, the template `/views/daily_stats.erb` is rendered as a Slack message.
- The special variable `@td` holds the table data as a JSON whose keys are column names and values are column values. Ex: if the result output is
    
    |col1|col2|
    |----|-----|
    |100 |hello|
    |200 |world|
    
    Then, `@td` is
    
    ```ruby
    {"col1" => [100,200], "col2" => ["hello","world"]}
    ```


## Easy Deploy on Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

After you deploy, you need to run the following

```shell
bundle install
bundle exec iron_worker upload
```

## License

Apache 2.0 License
