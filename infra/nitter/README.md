# README

## Introduction
In order to have a running means of providing Twitter data to our system, we will programmatically 

From the Nitter documentation: 
>A free and open source alternative Twitter front-end focused on privacy and performance. Inspired by the Invidious project.
>>    No JavaScript or ads
>>    All requests go through the backend, client never talks to Twitter
>>    Prevents Twitter from tracking your IP or JavaScript fingerprint
>>    Uses Twitter's unofficial API (no developer account required)
>>    Lightweight (for @nim_lang, 60KB vs 784KB from twitter.com)
>>    RSS feeds
>>    Themes
>>    Mobile support (responsive design)
>>    AGPLv3 licensed, no proprietary instances permitted

From Sekai-Soft's ["A guide for self-hosting a Nitter Instance"](https://github.com/sekai-soft/guide-nitter-self-hosting)
>Nitter is a fantastic alternative frontend for Twitter. Instead of using Twitter's official web interface or app, which contains ads or algorithmic contents that you may not like, Nitter enables you to browse Twitter content without those potential distractions. Nitter also exposes Twitter contents as RSS feeds so that you can 1) view them in an RSS reader 2) manipulate them programatically, such as crossposting to Mastodon, filtering and archiving.


## Pre-Requisites
You must have the following
- A working twitter account and password, with 2FA turned off
- Docker and Docker Compose running on your choice of Operating System

## Setup
This installation of Nitter is running using the [instructions from Sekai-Soft](https://github.com/sekai-soft/guide-nitter-self-hosting). 

Note: The provided dockerfile is modified version of the one provided by Sekai-Soft.

First to get it running we must have a working pair of credentials to Twitter. Place these credentials in a file at `nitter-data/twitter-credentials.json` like the following
```JSON
[
    {
        "username": "hello",
        "password": "world"
    },
    {
        "username": "second",
        "password": "pair"
    }
]
```
This array can support multiple pairs of working credentials to Twitter. For more information on supporting more than one working pair of credentials please see [Nitter's Developer](https://github.com/zedeus/nitter)

After adding credentials to that file, create an empty file called `nitter-data/guest_accounts.json`, or run the following command.

```bash
touch nitter-data/guest_accounts.json
```

Finally, check if your installation works properly by running the following command
```bash
docker-compose up -d
curl http://0.0.0.0:8080/$A_Twitter_Handle/rss
```
If the cURL works, you will see a text in RSS format in the console. The RSS will contain many copies of the URL provided to cURL

## Troubleshooting
Currently the best way to debug or troubleshoot this component is to use the resources available at either 
- [Nitter](https://github.com/zedeus/nitter)
- [Sekai-Soft Nitter](https://github.com/sekai-soft/guide-nitter-self-hosting)