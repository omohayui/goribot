# Description:
#   定期的に野球ニュースを投下するゴリ

cronJob = require('cron').CronJob
to_json = require('xmljson').to_json
request = require 'request'
module.exports = (robot) ->
  new cronJob '00 * * * * *', () =>
    url = "http://news.google.com/news/section?hl=ja&ned=us&ie=UTF-8&oe=UTF-8&output=rss&q=%E9%87%8E%E7%90%83&num=3"
    options =
      url: url
      timeout: 2000
      headers: {'user-agent': 'node title fetcher'}
    request options, (error, response, body) ->
      to_json body, (err, data) =>
        article = "今日の野球ニュースだぜ！！¥n"
        for id, item of data["rss"].channel.item
          title = item.title
          link  = item.link
          article += "#{title} #{link}¥n"
        robot.send {room:"#baseball"}, article
  , null, true, "Asia/Tokyo"
