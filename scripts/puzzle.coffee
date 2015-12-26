# Description:
#  play puzzle.
#
# Dependencies:
#
#
# Configuration:
#
# Commands:
#  goribot puzzle         - 現在のパズルの状態を表示
#  goribot shuffle        - パズルをシャッフル
#  goribot reset (gorilla|cat)  - パズルをリセット。引数で絵柄を指定
#  goribot (↓|下|down|d)  - 下に移動
#  goribot (←|左|left|l)  - 左に移動
#  goribot (→|右|right|r) - 右に移動
#  goribot (↑|上|up|u))   - 上に移動
#
_ = require 'lodash'
async = require 'async'
config = require 'config'


class Puzzle
  constructor: (setting) ->
    @width = setting.width
    @height = setting.height
    @images = setting.images
    @current = [1...(@width * @height)].concat 0

  toString: ->
    _.chain(@current).map((e) => @images[e]).chunk(@width).map((e) -> e.join '').join("\n").value()

  shuffle: ->
    for i in [1..1000]
      @move ['u', 'l', 'd', 'r'][Math.floor(Math.random() * 4)]

  move: (command) ->
    spaceIndex = _.indexOf @current, 0

    if command.match /(↓|下|down|d)/
      if spaceIndex < @width
        return false
      newSpaceIndex = spaceIndex - @width

    else if command.match /(←|左|left|l)/
      if spaceIndex % @height == @width - 1
        return false
      newSpaceIndex = spaceIndex + 1

    else if command.match /(→|右|right|r)/
      if spaceIndex % @height == 0
        return false
      newSpaceIndex = spaceIndex - 1

    else if command.match /(↑|上|up|u)/
      if spaceIndex >= @width * (@height - 1)
        return false
      newSpaceIndex = spaceIndex + @width

    @current[spaceIndex] = @current[newSpaceIndex]
    @current[newSpaceIndex] = 0
    return true


module.exports = (robot) ->
  puzzles = {}
  getPuzzle = (msg) ->
    room = msg.envelope.room
    if puzzles[room]
      return puzzles[room]
    return puzzles[room] = new Puzzle config.gorilla

  puzzleAnim = (msg, iteratee, iterator) ->
    puzzle = getPuzzle msg

    chid = robot.adapter.client.getChannelGroupOrDMByName(msg.envelope.room)?.id
    robot.adapter.client._apiCall 'chat.postMessage',
      channel: chid
      text: puzzle.toString()
      as_user: true
    , (res) ->
      oldMove = -1
      async.eachSeries iteratee
      , (i, done) ->
        try
          iterator puzzle, i
        catch e
          return done e
        robot.adapter.client._apiCall 'chat.update',
          channel: chid
          text: puzzle.toString()
          ts: res.ts
        , (res) -> done null
      , (err) ->

  robot.respond /reset\s*(.*)/, (msg) ->
    msg.finish()

    if config[msg.match[1]]?
      puzzles[msg.envelope.room] = new Puzzle config[msg.match[1]]
    else if msg.match[1] is ''
      msg.send "次のいずれかを指定 #{Object.keys(config).join(', ')}"
      return
    else
      msg.send "自分で作れ"
      return

    msg.send getPuzzle(msg).toString()


  robot.respond /shuffle/, (msg) ->
    msg.finish()

    oldMove = -1
    puzzleAnim msg, [0...10], (puzzle, i) ->
      rand = Math.floor(Math.random() * 4)
      for i in [0..3]
        move = (i + rand) % 4
        continue if oldMove is (move + 2) % 4
        if puzzle.move ['u', 'l', 'd', 'r'][move]
          break
      oldMove = move

  robot.respond /((↓|下|down|d|←|左|left|l|→|右|right|r|↑|上|up|u)+)/i, (msg) ->
    msg.finish()
    puzzleAnim msg
    , msg.match[1].match(/(↓|下|down|d|←|左|left|l|→|右|right|r|↑|上|up|u)/ig)
    , (puzzle, command) ->
      unless puzzle.move command
        msg.send 'そっちには移動できないよ'
        throw new Error


  robot.respond /puzzle\s*(.*)/, (msg) ->
    msg.send getPuzzle(msg).toString()
