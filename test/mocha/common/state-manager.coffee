helpers = require '../../helpers'
helpers.setupBrowserEnvironment()

StateManager = requirejs 'common/views/state-manager'

describe "StateManager", ->
  describe "StateManager constructor", ->
    it "should exist", ->
      should.exist StateManager

  describe "instance of StateManager", ->
    # Instance of StateManager.
    sm = null

    before ->
      sm = new StateManager ["atom", "trees", "rocks"]

    it "should allow adding a new state", ->
      sm.newState "0", {}
      sm.getState("0").should.eql {atom: [], trees: [], rocks: []}

      state = {atom: [{x: 1}], trees: [{color: "red"}, {color: "green"}], rocks: [{size: "big"}]}
      sm.newState "1", state
      sm.getState("1").should.eql state

      state = {atom: [{x: 2}], trees: [{color: "blue"}, {color: "black"}]}
      sm.newState "2", state
      sm.getState("2").should.eql {atom: [{x: 2}], trees: [{color: "blue"}, {color: "black"}], rocks: []}

    it "should allow extending the last state", ->
      # Note that trees are untouched. They are defined, but no option is actually updated.
      state = {atom: [{x: 3}], trees: [{}, {}]}
      sm.extendLastState "3", state
      sm.getState("3").should.eql {atom: [{x: 3}], trees: [{color: "blue"}, {color: "black"}], rocks: []}

      # Remove one tree, add new property to atom.
      state = {atom: [{y: 4}], trees: [{}]}
      sm.extendLastState "3.5", state
      sm.getState("3.5").should.eql {atom: [{x: 3, y: 4}], trees: [{color: "blue"}], rocks: []}

      # There is no definition of trees anymore, so it will be deleted!
      state = {atom: [{x: 4}]}
      sm.extendLastState "4", state
      sm.getState("4").should.eql {atom: [{x: 4, y: 4}], trees: [], rocks: []}

    it "should evaluate all functions in state during getState() operation", ->
      test = 2
      state = {atom: [{y: -> 15 + test}]}
      sm.extendLastState "5", state

      sm.getState("5").should.eql {atom: [{x: 4, y: 17}], trees: [], rocks: []}