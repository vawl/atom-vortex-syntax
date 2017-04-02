InputView = require '../lib/input-view'

describe "InputView", ->
  describe "when there is no input", ->
    it "should not try to publish anything", ->
      spawn = jasmine.createSpy()

      view = new InputView('repo', spawn)
      view.finish()
      expect(spawn).not.toHaveBeenCalled()

  describe "when there is input", ->
    it "should try to publish the given version", ->
      spawn = jasmine.createSpy()

      view = new InputView('repo', spawn)
      view.versionEditor.setText '1.x.x'
      view.finish()
      expect(spawn).toHaveBeenCalledWith '1.x.x', 'repo'
