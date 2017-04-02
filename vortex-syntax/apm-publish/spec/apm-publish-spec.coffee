publisher = require '../lib/apm-publish'

version = 'major'
repo =
  getWorkingDirectory: -> "~/some/repository"
otherRepo =
  getWorkingDirectory: -> "~/some/other/repository"

describe "apm-publish", ->
  beforeEach ->
    spyOn(publisher, 'spawn')

  describe "::publish", ->
    describe "when there is no repository open in atom", ->
      beforeEach ->
        spyOn(atom.project, 'getRepositories').andReturn []

      it "won't try to publish anything", ->
        waitsForPromise -> publisher.publish version
        runs ->
          expect(publisher.spawn).not.toHaveBeenCalled()

    describe "when there is only one repository open in atom", ->
      beforeEach ->
        spyOn(atom.project, 'getRepositories').andReturn [repo]

      it "will try to publish that project", ->
        waitsForPromise -> publisher.publish(version)
        runs ->
          expect(publisher.spawn).toHaveBeenCalledWith version, repo.getWorkingDirectory()
