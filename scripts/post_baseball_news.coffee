# Description:
#   定期的に野球ニュースを投下するゴリ
#   "baseball news" でも反応するゴリ
# Commands:
#   baseball news - Nikkanプロ野球ニュースを #baseball にpostするゴリ

cronJob = require('cron').CronJob
to_json = require('xmljson').to_json
request = require 'request'
limit   = 3
post_news = (robot, limit) ->
  url = "http://feed.rssad.jp/rss/nikkansports/professional/atom.xml"
  options =
    url: url
    timeout: 2000
    headers: {'user-agent': 'node title fetcher'}
  request options, (error, response, body) ->
    to_json body, (err, data) =>
      article = "今日の野球ニュースだぜ！！\n"
      for id, entry of data["feed"].entry when id < limit
        title = entry.title
        link  = entry.id
        article += "#{link}\n" unless /^PR.*/.test(title)
      robot.send {room:"#baseball"}, article
module.exports = (robot) ->
  new cronJob '00 00 10 * * 1-5', () =>
    post_news(robot, limit)
  , null, true, "Asia/Tokyo"
  robot.hear /baseball news/i, () ->
    post_news(robot, limit)
