# Description:
#   ドラミングするゴリ
# Commands:
#   ドラミング - ウホウホホ

module.exports = (robot) ->
  robot.hear /ドラミング/i, (msg) ->
    msg.send msg.random [
      "http://img.gifmagazine.net/gifmagazine/images/34803/original.gif",
      "http://stream1.gifsoup.com/view1/3218586/baby-ape-o.gif",
      "http://i.giflike.com/tnrUnr0.gif",
      "https://media.giphy.com/media/eBXnKCB7ZjXiw/giphy.gif",
      "https://media.giphy.com/media/eBXnKCB7ZjXiw/giphy.gif",
      "https://metrouk2.files.wordpress.com/2015/02/monkey-3.gif",
      "http://img.gifmagazine.net/gifmagazine/images/137850/original.gif",
      "http://img.gifmagazine.net/gifmagazine/images/138096/original.gif"
    ]
