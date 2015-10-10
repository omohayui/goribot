# Description:
#   定期的に野球ニュースを投下するゴリ

cronJob = require('cron').CronJob
to_json = require('xmljson').to_json
request = require 'request'
module.exports = (robot) ->
  new cronJob '00 10 * * * *', () =>
    url = "http://feed.rssad.jp/rss/nikkansports/professional/atom.xml"
    options =
      url: url
      timeout: 2000
      headers: {'user-agent': 'node title fetcher'}
    request options, (error, response, body) ->
      to_json body, (err, data) =>
        article = "今日の野球ニュースだぜ！！\n"
        limit   = 3
        for id, entry of data["feed"].entry when id < limit
          title = entry.title
          link  = entry.id
          article += "#{link}\n" unless /^PR.*/.test(title)
        robot.send {room:"#baseball"}, article
  , null, true, "Asia/Tokyo"
