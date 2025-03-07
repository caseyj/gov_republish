# GovRepublish

This repository hosts the GovRepublish tool. GovRepublish was designed to solve a problem where local governments only post updates to the former bird site and if you were not logged in you are out of luck. GovRepublish will read an RSS feed for a configured source, and then post that same data to BlueSky. GovRepublish is extensible, and easy to add more feeds to read from, and more accounts to post to, and update the schedule for jobs that will run.

GovRepublish requires a single working pair of credentials to "that former bird site", and one or more accounts on BlueSky. 

## Installation

### Elixir and the Erlang Runtime

This project is built using Elixir 1.16.1

You may find installation instructions for the Elixir Language and the runtime environment [here](https://elixir-lang.org/install.html)

### Using the repository
Not currently available on Hexdocs. Installation instructions are as follows

1. Clone this repository
```bash
git clone https://github.com/caseyj/gov_republish.git
```
2. Open the directory this is cloned to
```bash
cd gov_republish
```
3. Install Dependencies
```bash
mix deps.get
```
4. Follow instructions to set up the minimum infrastructure in `infra/nitter`


## Configuration

### Configure Data Ingestion
Currently the implementation for the worker responsible for ingesting data into the system is located at [lib/gov_republish/workers/](lib/gov_republish/workers/rss_read_worker.ex). 

This worker takes in a single configuration item which a JSON file containing the url or filepath of a data ingestion location and should recieve data in RSS format from that location. This must be delivered in a JSON file, where the key-value pair is at the root of the root object as defined in the examples below titled Configuration JSON File.

Once this configuration file is created you are able to add a job to the schedule. Go to the main configuration file at [config/config.exs](config/config.exs). Add a new entry in the element called "crontab" of the cron schedule you would like the app to follow like so:
```elixir
config :gov_republish, Oban,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"*/15 * * * *", GovRepublish.Workers.RssReadWorker, # this will attempt to read RSS from the configured location every 15th minute 
        max_attempts: 1, args: %{"settings_file" => "some/directory/configuration_you_wrote.json"}},
        ... # more scheduled workers here
     ]
    }
  ]
```
#### Examples
##### Configuration JSON File
```JSON
//with URL
{
  "twitter-endpoint": "0.0.0.0:8080/TwitterHandle/rss"
}
```
```JSON
//with filepath
{
  "twitter-endpoint": "/tmp/TwitterHandle.rss"
}
```

### Configure Posting
Currently the implementation for the worker responsible for posting data to BlueSky is located at [lib/gov_republish/workers/bluesky_post_worker.ex](lib/gov_republish/workers/bluesky_post_worker.ex). 

This worker takes in a single configuration item which a JSON file contains the author's Twitter handle of a feed they would like to pust to BlueSky, as well as the credential pair for BlueSky.  This must be delivered in a JSON file, where the key-value pairs are at the root of the root object as defined in the examples below titled Configuration JSON File.

Once this configuration file is created you are able to add a job to the schedule. Go to the main configuration file at [config/config.exs](config/config.exs). Add a new entry in the element called "crontab" of the cron schedule you would like the app to follow like so:
```elixir
config :gov_republish, Oban,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"*/15 * * * *", GovRepublish.Workers.BlueskyPostWorker, # this will attempt to post to Bluesky using the configuration file provided every 15th minute 
        max_attempts: 1, args: %{"settings_file" => "some/directory/configuration_you_wrote.json"}},
        ... # more scheduled workers here
     ]
    }
  ]
```
#### Examples
##### Configuration JSON File
```JSON
{
  "author":"@PostAuthor!",
  "bluesky-pw": "hunter2",
  "bluesky-handle": "<YOUR HANDLE HERE>.bsky.social",
}
```

## How to run

When running the following instructions, two activities will commence:
1. The Nitter server will launch at `http://0.0.0.0:8080`
2. The elixir application will run and begin printing logs to stdout

```bash
mix start
```





